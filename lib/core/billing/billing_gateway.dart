import 'dart:async';

import 'package:flutter/services.dart';

import 'billing_models.dart';
import 'store_catalog.dart';

/// The one interface the game talks to.
///
/// Adding a fourth storefront means writing another implementation — no
/// gameplay, UI or DSL code changes.
abstract class BillingGateway {
  StoreTarget get target;

  String get id => target.id;

  String get displayName => target.displayName;

  /// True when the storefront's IAP service is installed, signed in and usable.
  Future<bool> isAvailable();

  /// Queries live pricing. Implementations must fall back to the catalog entry
  /// when the store returns nothing, so the UI is never empty.
  Future<List<StoreProduct>> loadProducts(List<String> skus);

  /// Launches the purchase flow and completes when the store returns.
  Future<PurchaseResult> purchase(String sku);

  /// Re-reads owned non-consumables and unconsumed purchases.
  Future<List<PurchaseResult>> restore();

  /// Marks a consumable as consumed / acknowledges an entitlement.
  Future<void> finish(PurchaseResult purchase);

  Future<void> dispose() async {}
}

/// Shared implementation for the three Android storefronts.
///
/// Each store has its own native plugin (AppGallery IAP, Amazon IAP, Samsung
/// IAP). Rather than depending on three third-party packages, the app talks to
/// a thin platform channel per store; the Android side implements the four
/// methods below with the vendor SDK. If the channel is missing (dev machine,
/// desktop, or a build without the store SDK) the gateway reports itself as
/// unavailable and the service falls back to the sandbox.
abstract class ChannelBillingGateway extends BillingGateway {
  ChannelBillingGateway(String channelName)
      : channel = MethodChannel(channelName);

  final MethodChannel channel;

  bool? _availability;

  @override
  Future<bool> isAvailable() async {
    if (_availability != null) return _availability!;
    try {
      final bool? result = await channel.invokeMethod<bool>('isAvailable');
      _availability = result ?? false;
    } on MissingPluginException {
      _availability = false;
    } on PlatformException {
      _availability = false;
    }
    return _availability!;
  }

  @override
  Future<List<StoreProduct>> loadProducts(List<String> skus) async {
    try {
      final List<Object?>? raw = await channel.invokeMethod<List<Object?>>(
        'loadProducts',
        <String, Object?>{'skus': skus},
      );
      if (raw == null || raw.isEmpty) return _fallbackProducts(skus);

      final List<StoreProduct> products = <StoreProduct>[];
      for (final Object? entry in raw) {
        if (entry is! Map) continue;
        final String sku = (entry['sku'] ?? '').toString();
        products.add(
          StoreProduct.fromMap(entry, template: StoreCatalog.bySku(sku)),
        );
      }
      return products.isEmpty ? _fallbackProducts(skus) : products;
    } on MissingPluginException {
      return _fallbackProducts(skus);
    } on PlatformException {
      return _fallbackProducts(skus);
    }
  }

  @override
  Future<PurchaseResult> purchase(String sku) async {
    try {
      final Map<Object?, Object?>? raw =
          await channel.invokeMethod<Map<Object?, Object?>>(
        'purchase',
        <String, Object?>{'sku': sku},
      );
      if (raw == null) {
        return PurchaseResult.cancelled(sku, id);
      }
      return PurchaseResult.fromMap(raw, provider: id, fallbackSku: sku);
    } on MissingPluginException {
      return PurchaseResult.failed(sku, id, 'Store service unavailable');
    } on PlatformException catch (error) {
      if (error.code == 'cancelled' || error.code == 'user_cancelled') {
        return PurchaseResult.cancelled(sku, id);
      }
      return PurchaseResult.failed(sku, id, error.message ?? error.code);
    }
  }

  @override
  Future<List<PurchaseResult>> restore() async {
    try {
      final List<Object?>? raw =
          await channel.invokeMethod<List<Object?>>('restore');
      if (raw == null) return const <PurchaseResult>[];
      return raw
          .whereType<Map<Object?, Object?>>()
          .map((Map<Object?, Object?> m) => PurchaseResult.fromMap(
                <Object?, Object?>{...m, 'state': 'restored'},
                provider: id,
              ))
          .toList();
    } on MissingPluginException {
      return const <PurchaseResult>[];
    } on PlatformException {
      return const <PurchaseResult>[];
    }
  }

  @override
  Future<void> finish(PurchaseResult purchase) async {
    try {
      await channel.invokeMethod<void>('finish', <String, Object?>{
        'sku': purchase.sku,
        'token': purchase.token,
        'orderId': purchase.orderId,
        'consumable': !StoreCatalog.isEntitlement(purchase.sku),
      });
    } on MissingPluginException {
      // Nothing to acknowledge without a native side.
    } on PlatformException {
      // A failed acknowledgement is retried on the next restore.
    }
  }

  List<StoreProduct> _fallbackProducts(List<String> skus) => skus
      .map(StoreCatalog.bySku)
      .whereType<StoreProduct>()
      .toList(growable: false);
}

/// Huawei AppGallery — backed by the HMS IAP SDK on the Android side.
class HuaweiBillingGateway extends ChannelBillingGateway {
  HuaweiBillingGateway() : super('between/billing/huawei');

  @override
  StoreTarget get target => StoreTarget.huawei;
}

/// Amazon Appstore — backed by the Amazon In-App Purchasing SDK.
class AmazonBillingGateway extends ChannelBillingGateway {
  AmazonBillingGateway() : super('between/billing/amazon');

  @override
  StoreTarget get target => StoreTarget.amazon;
}

/// Samsung Galaxy Store — backed by the Samsung IAP SDK.
class SamsungBillingGateway extends ChannelBillingGateway {
  SamsungBillingGateway() : super('between/billing/samsung');

  @override
  StoreTarget get target => StoreTarget.samsung;
}

/// Offline stand-in used on desktop, in tests and in QA builds.
///
/// It behaves like a real store (async, cancellable, restorable) so the store
/// UI can be exercised without any storefront installed.
class SandboxBillingGateway extends BillingGateway {
  SandboxBillingGateway({this.latency = const Duration(milliseconds: 650)});

  final Duration latency;
  final Map<String, PurchaseResult> _owned = <String, PurchaseResult>{};
  int _counter = 0;

  @override
  StoreTarget get target => StoreTarget.sandbox;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<List<StoreProduct>> loadProducts(List<String> skus) async =>
      skus.map(StoreCatalog.bySku).whereType<StoreProduct>().toList();

  @override
  Future<PurchaseResult> purchase(String sku) async {
    await Future<void>.delayed(latency);
    if (StoreCatalog.isEntitlement(sku) && _owned.containsKey(sku)) {
      return PurchaseResult(
        sku: sku,
        state: PurchaseState.alreadyOwned,
        provider: id,
      );
    }
    final PurchaseResult result = PurchaseResult(
      sku: sku,
      state: PurchaseState.purchased,
      provider: id,
      orderId: 'sandbox-${DateTime.now().millisecondsSinceEpoch}-${_counter++}',
      token: 'sandbox-token-$sku',
    );
    if (StoreCatalog.isEntitlement(sku)) _owned[sku] = result;
    return result;
  }

  @override
  Future<List<PurchaseResult>> restore() async {
    await Future<void>.delayed(latency);
    return _owned.values
        .map((PurchaseResult p) => PurchaseResult(
              sku: p.sku,
              state: PurchaseState.restored,
              provider: id,
              orderId: p.orderId,
              token: p.token,
            ))
        .toList();
  }

  @override
  Future<void> finish(PurchaseResult purchase) async {}
}
