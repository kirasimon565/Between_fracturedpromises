import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'billing_gateway.dart';
import 'billing_models.dart';
import 'store_catalog.dart';

/// What the store screen renders.
class BillingSnapshot {
  const BillingSnapshot({
    this.target = StoreTarget.sandbox,
    this.available = false,
    this.loading = true,
    this.products = const <StoreProduct>[],
    this.busySku,
    this.lastResult,
    this.error,
    this.lastRestoreAt,
  });

  final StoreTarget target;
  final bool available;
  final bool loading;
  final List<StoreProduct> products;

  /// SKU currently being purchased, used to show a spinner on one card.
  final String? busySku;
  final PurchaseResult? lastResult;
  final String? error;
  final DateTime? lastRestoreAt;

  List<StoreProduct> get crystalPacks => products
      .where((StoreProduct p) => p.totalCrystals > 0)
      .toList(growable: false);

  List<StoreProduct> get entitlements => products
      .where((StoreProduct p) => p.kind == ProductKind.nonConsumable)
      .toList(growable: false);

  BillingSnapshot copyWith({
    StoreTarget? target,
    bool? available,
    bool? loading,
    List<StoreProduct>? products,
    Object? busySku = _sentinel,
    Object? lastResult = _sentinel,
    Object? error = _sentinel,
    DateTime? lastRestoreAt,
  }) => BillingSnapshot(
    target: target ?? this.target,
    available: available ?? this.available,
    loading: loading ?? this.loading,
    products: products ?? this.products,
    busySku: identical(busySku, _sentinel) ? this.busySku : busySku as String?,
    lastResult: identical(lastResult, _sentinel)
        ? this.lastResult
        : lastResult as PurchaseResult?,
    error: identical(error, _sentinel) ? this.error : error as String?,
    lastRestoreAt: lastRestoreAt ?? this.lastRestoreAt,
  );

  static const Object _sentinel = Object();
}

/// Effects a completed purchase has on the player's account.
class BillingGrant {
  const BillingGrant({
    required this.sku,
    required this.crystals,
    required this.entitlement,
    required this.receiptId,
    required this.provider,
    required this.restored,
  });

  final String sku;
  final int crystals;
  final bool entitlement;
  final String receiptId;
  final String provider;
  final bool restored;
}

/// Picks the right storefront and turns purchases into crystal grants.
///
/// Selection order:
///   1. `--dart-define=STORE=huawei|amazon|samsung|sandbox`
///   2. the installer package that delivered the APK
///   3. the first gateway that reports itself available
///   4. the sandbox gateway
class BillingService {
  BillingService({
    List<BillingGateway>? gateways,
    this.forcedTarget,
    this.onGrant,
  }) : _gateways =
           gateways ??
           <BillingGateway>[
             HuaweiBillingGateway(),
             AmazonBillingGateway(),
             SamsungBillingGateway(),
           ];

  static const String storeFromEnvironment = String.fromEnvironment(
    'STORE',
    defaultValue: '',
  );

  final List<BillingGateway> _gateways;
  final StoreTarget? forcedTarget;

  /// Invoked whenever a purchase (or restore) should change the wallet.
  final Future<void> Function(BillingGrant grant)? onGrant;

  final SandboxBillingGateway _sandbox = SandboxBillingGateway();

  BillingGateway? _active;
  bool _initialised = false;

  BillingGateway get gateway => _active ?? _sandbox;

  StoreTarget get target => gateway.target;

  /// Resolves the storefront and loads pricing.
  Future<BillingSnapshot> initialise() async {
    if (_initialised && _active != null) {
      return _load(_active!);
    }

    final StoreTarget? explicit =
        forcedTarget ?? StoreTargetX.fromId(storeFromEnvironment);
    if (explicit != null) {
      _active = _gatewayFor(explicit);
      _initialised = true;
      return _load(_active!);
    }

    final StoreTarget? installed = await _detectFromInstaller();
    if (installed != null) {
      final BillingGateway candidate = _gatewayFor(installed);
      if (await candidate.isAvailable()) {
        _active = candidate;
        _initialised = true;
        return _load(candidate);
      }
    }

    for (final BillingGateway candidate in _gateways) {
      if (await candidate.isAvailable()) {
        _active = candidate;
        _initialised = true;
        return _load(candidate);
      }
    }

    _active = _sandbox;
    _initialised = true;
    return _load(_sandbox);
  }

  Future<BillingSnapshot> _load(BillingGateway gateway) async {
    final bool available = await gateway.isAvailable();
    final List<StoreProduct> products = await gateway.loadProducts(
      StoreCatalog.skus,
    );
    return BillingSnapshot(
      target: gateway.target,
      available: available,
      loading: false,
      products: products.isEmpty ? StoreCatalog.all : products,
    );
  }

  BillingGateway _gatewayFor(StoreTarget target) {
    for (final BillingGateway gateway in _gateways) {
      if (gateway.target == target) return gateway;
    }
    return _sandbox;
  }

  Future<StoreTarget?> _detectFromInstaller() async {
    if (kIsWeb) return null;
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      return StoreTargetX.fromInstaller(info.installerStore);
    } catch (_) {
      return null;
    }
  }

  /// Buys [sku] and, on success, hands a [BillingGrant] to [onGrant].
  Future<PurchaseResult> buy(String sku) async {
    final BillingGateway gateway = this.gateway;
    final PurchaseResult result = await gateway.purchase(sku);

    if (result.isSuccess || result.state == PurchaseState.alreadyOwned) {
      await _grant(result, restored: result.state == PurchaseState.restored);
      await gateway.finish(result);
    }
    return result;
  }

  /// Re-applies everything the player already paid for.
  Future<List<PurchaseResult>> restore() async {
    final List<PurchaseResult> results = await gateway.restore();
    for (final PurchaseResult result in results) {
      await _grant(result, restored: true);
      await gateway.finish(result);
    }
    return results;
  }

  Future<void> _grant(PurchaseResult result, {required bool restored}) async {
    final StoreProduct? product = StoreCatalog.bySku(result.sku);
    if (product == null) return;
    await onGrant?.call(
      BillingGrant(
        sku: result.sku,
        crystals: product.totalCrystals * result.quantity,
        entitlement: product.kind == ProductKind.nonConsumable,
        receiptId: result.receiptId,
        provider: result.provider,
        restored: restored,
      ),
    );
  }

  Future<void> dispose() async {
    for (final BillingGateway gateway in _gateways) {
      await gateway.dispose();
    }
    await _sandbox.dispose();
  }
}
