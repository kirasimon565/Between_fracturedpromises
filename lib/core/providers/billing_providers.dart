import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../billing/billing_models.dart';
import '../billing/billing_service.dart';
import '../billing/store_catalog.dart';
import 'database_providers.dart';
import 'engine_providers.dart';

/// The storefront adapter, wired so a successful purchase credits the wallet
/// and writes a receipt in the same step.
final Provider<BillingService> billingServiceProvider =
    Provider<BillingService>((ref) {
  final BillingService service = BillingService(
    onGrant: (BillingGrant grant) async {
      final bool duplicate = await ref
          .read(playerRepositoryProvider)
          .hasReceipt(grant.receiptId);

      await ref.read(playerRepositoryProvider).recordReceipt(
            id: grant.receiptId,
            sku: grant.sku,
            provider: grant.provider,
            state: grant.restored ? 'restored' : 'purchased',
            crystals: grant.crystals,
            acknowledged: true,
          );

      final GameSessionController session =
          ref.read(gameSessionProvider.notifier);

      if (grant.entitlement) {
        await session.grantEntitlement(grant.sku);
        // Entitlements that also bundle crystals only pay out once.
        if (grant.crystals > 0 && !duplicate) {
          await session.creditCrystals(grant.crystals, sku: grant.sku);
        }
        return;
      }

      // Consumables can legitimately be bought again, but a *restore* must not
      // hand out the same crystals twice.
      if (grant.restored && duplicate) return;
      if (grant.crystals > 0) {
        await session.creditCrystals(grant.crystals, sku: grant.sku);
      }
    },
  );
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

/// Drives the store screen.
class BillingController extends AsyncNotifier<BillingSnapshot> {
  BillingService get _service => ref.read(billingServiceProvider);

  @override
  Future<BillingSnapshot> build() => _service.initialise();

  Future<PurchaseResult?> buy(String sku) async {
    final BillingSnapshot current =
        state.value ?? const BillingSnapshot();
    state = AsyncData<BillingSnapshot>(
        current.copyWith(busySku: sku, error: null, lastResult: null));

    try {
      final PurchaseResult result = await _service.buy(sku);
      state = AsyncData<BillingSnapshot>(current.copyWith(
        busySku: null,
        lastResult: result,
        error: result.state == PurchaseState.failed
            ? (result.message ?? 'Purchase failed')
            : null,
      ));
      return result;
    } catch (error) {
      state = AsyncData<BillingSnapshot>(
          current.copyWith(busySku: null, error: '$error'));
      return null;
    }
  }

  Future<int> restore() async {
    final BillingSnapshot current =
        state.value ?? const BillingSnapshot();
    state = AsyncData<BillingSnapshot>(
        current.copyWith(busySku: '__restore__', error: null));
    try {
      final List<PurchaseResult> results = await _service.restore();
      state = AsyncData<BillingSnapshot>(current.copyWith(
        busySku: null,
        lastRestoreAt: DateTime.now(),
      ));
      return results.length;
    } catch (error) {
      state = AsyncData<BillingSnapshot>(
          current.copyWith(busySku: null, error: '$error'));
      return 0;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading<BillingSnapshot>();
    state = await AsyncValue.guard(_service.initialise);
  }

  List<StoreProduct> get catalog =>
      state.value?.products ?? StoreCatalog.all;
}

final AsyncNotifierProvider<BillingController, BillingSnapshot>
    billingControllerProvider =
    AsyncNotifierProvider<BillingController, BillingSnapshot>(
        BillingController.new);
