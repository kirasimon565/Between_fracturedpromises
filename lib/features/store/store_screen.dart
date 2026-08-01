import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/billing/billing_models.dart';
import '../../core/billing/billing_service.dart';
import '../../core/providers/billing_providers.dart';
import '../../core/providers/world_providers.dart';
import '../../engine/engine.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/common.dart';
import '../phone/widgets/phone_chrome.dart';

/// The crystal store.
///
/// It renders whatever the active [BillingGateway] reports, so the exact same
/// widget serves Huawei AppGallery, Amazon Appstore and Samsung Galaxy Store —
/// only [BillingSnapshot.target] changes. Nothing here knows a store SDK.
class StoreView extends ConsumerStatefulWidget {
  const StoreView({super.key, this.onExit, this.requiredCrystals = 0});

  final VoidCallback? onExit;

  /// Set when the store was opened because a premium choice was unaffordable.
  final int requiredCrystals;

  /// Bridge used by the phone shell: `@open_store` and locked premium choices
  /// push the shortfall here before switching to the store app.
  static final ValueNotifier<int> pendingRequirement = ValueNotifier<int>(0);

  @override
  ConsumerState<StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends ConsumerState<StoreView> {
  @override
  void initState() {
    super.initState();
    if (widget.requiredCrystals > 0) {
      StoreView.pendingRequirement.value = widget.requiredCrystals;
    }
  }

  @override
  void dispose() {
    StoreView.pendingRequirement.value = 0;
    super.dispose();
  }

  Future<void> _buy(String sku) async {
    final PurchaseResult? result =
        await ref.read(billingControllerProvider.notifier).buy(sku);
    if (!mounted || result == null) return;

    final String message;
    switch (result.state) {
      case PurchaseState.purchased:
        message = 'Purchase complete.';
        StoreView.pendingRequirement.value = 0;
        break;
      case PurchaseState.restored:
        message = 'Purchase restored.';
        StoreView.pendingRequirement.value = 0;
        break;
      case PurchaseState.cancelled:
        message = 'Purchase cancelled.';
        break;
      case PurchaseState.pending:
        message = 'Waiting for the store to confirm…';
        break;
      case PurchaseState.alreadyOwned:
        message = 'You already own this.';
        break;
      case PurchaseState.failed:
        message = result.message ?? 'The store could not complete that.';
        break;
    }
    _say(message);
  }

  Future<void> _restore() async {
    final int count =
        await ref.read(billingControllerProvider.notifier).restore();
    if (!mounted) return;
    _say(count == 0
        ? 'Nothing to restore on this account.'
        : 'Restored $count purchase${count == 1 ? '' : 's'}.');
  }

  void _say(String message) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceHigh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<BillingSnapshot> async =
        ref.watch(billingControllerProvider);
    final Wallet wallet = ref.watch(walletProvider);

    return Column(
      children: <Widget>[
        AppHeader(
          title: 'Crystals',
          subtitle: async.value == null
              ? null
              : _storeLabel(async.value!.target),
          accent: AppColors.crystal,
          onBack: widget.onExit,
          actions: <Widget>[CrystalChip(amount: wallet.crystals)],
        ),
        Expanded(
          child: async.when(
            loading: () => const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.crystal,
                ),
              ),
            ),
            error: (Object error, StackTrace _) => Padding(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Icons.storefront_outlined,
                title: 'The store is unreachable',
                message: '$error',
                action: OutlinedButton(
                  onPressed: () =>
                      ref.read(billingControllerProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ),
            ),
            data: (BillingSnapshot snapshot) =>
                _content(snapshot, wallet),
          ),
        ),
      ],
    );
  }

  Widget _content(BillingSnapshot snapshot, Wallet wallet) {
    final List<StoreProduct> packs = snapshot.crystalPacks;
    final List<StoreProduct> extras = snapshot.entitlements
        .where((StoreProduct p) => p.totalCrystals == 0)
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
      children: <Widget>[
        _BalanceCard(wallet: wallet),
        ValueListenableBuilder<int>(
          valueListenable: StoreView.pendingRequirement,
          builder: (BuildContext context, int required, Widget? _) {
            if (required <= 0) return const SizedBox.shrink();
            final int short = required - wallet.crystals;
            if (short <= 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 14),
              child: _ShortfallBanner(short: short, required: required),
            );
          },
        ),
        if (!snapshot.available)
          const Padding(
            padding: EdgeInsets.only(top: 14),
            child: _OfflineNotice(),
          ),
        const SizedBox(height: 24),
        const SectionLabel('CRYSTAL PACKS'),
        const SizedBox(height: 12),
        for (final StoreProduct product in packs)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ProductCard(
              product: product,
              busy: snapshot.busySku == product.sku,
              owned: product.kind == ProductKind.nonConsumable &&
                  wallet.ownedSkus.contains(product.sku),
              onBuy: () => _buy(product.sku),
            ),
          ),
        if (extras.isNotEmpty) ...<Widget>[
          const SizedBox(height: 18),
          const SectionLabel('UNLOCKS'),
          const SizedBox(height: 12),
          for (final StoreProduct product in extras)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ProductCard(
                product: product,
                busy: snapshot.busySku == product.sku,
                owned: wallet.ownedSkus.contains(product.sku),
                onBuy: () => _buy(product.sku),
              ),
            ),
        ],
        const SizedBox(height: 22),
        OutlinedButton.icon(
          onPressed:
              snapshot.busySku == '__restore__' ? null : () => _restore(),
          icon: snapshot.busySku == '__restore__'
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.restore_rounded, size: 18),
          label: const Text('Restore purchases'),
        ),
        const SizedBox(height: 16),
        Text(
          'Crystals are stored on this device only. Restoring re-reads your '
          'receipts from ${_storeLabel(snapshot.target)} and re-applies any '
          'permanent unlocks — consumed crystals are not returned.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textFaint,
            fontSize: 11,
            height: 1.6,
          ),
        ),
        if (snapshot.error != null) ...<Widget>[
          const SizedBox(height: 14),
          Text(
            snapshot.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.danger, fontSize: 12),
          ),
        ],
      ],
    );
  }

  static String _storeLabel(StoreTarget target) {
    switch (target) {
      case StoreTarget.huawei:
        return 'Huawei AppGallery';
      case StoreTarget.amazon:
        return 'Amazon Appstore';
      case StoreTarget.samsung:
        return 'Samsung Galaxy Store';
      case StoreTarget.sandbox:
        return 'Sandbox (no charges)';
    }
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.wallet});

  final Wallet wallet;

  @override
  Widget build(BuildContext context) => GlassCard(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'BALANCE',
              style: TextStyle(
                color: AppColors.textFaint,
                fontSize: 10,
                letterSpacing: 2.4,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.diamond_outlined,
                    color: AppColors.crystal, size: 30),
                const SizedBox(width: 12),
                Text(
                  '${wallet.crystals}',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                _Stat(label: 'Earned', value: wallet.lifetimeEarned),
                _Stat(label: 'Spent', value: wallet.lifetimeSpent),
                _Stat(label: 'Bought', value: wallet.lifetimePurchased),
              ],
            ),
          ],
        ),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$value',
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textFaint,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
}

class _ShortfallBanner extends StatelessWidget {
  const _ShortfallBanner({required this.short, required this.required});

  final int short;
  final int required;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.ember.withValues(alpha: 0.12),
          borderRadius: AppRadii.card,
          border: Border.all(color: AppColors.ember.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.lock_open_rounded,
                color: AppColors.ember, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'That choice costs $required crystals — you need $short more.',
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: AppRadii.card,
          border: Border.all(color: AppColors.outline),
        ),
        child: const Row(
          children: <Widget>[
            Icon(Icons.info_outline_rounded,
                color: AppColors.textDim, size: 18),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No storefront is connected on this build. Purchases run in '
                'sandbox mode and grant crystals locally.',
                style: TextStyle(
                  color: AppColors.textDim,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.busy,
    required this.owned,
    required this.onBuy,
  });

  final StoreProduct product;
  final bool busy;
  final bool owned;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final bool highlight = product.highlight;
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      color: highlight ? AppColors.crystal.withValues(alpha: 0.07) : null,
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: product.totalCrystals > 0
                    ? AppColors.crystalGradient
                    : AppColors.emberGradient,
              ),
              borderRadius: AppRadii.icon,
            ),
            child: Icon(
              product.totalCrystals > 0
                  ? Icons.diamond_outlined
                  : Icons.workspace_premium_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        product.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (product.badge != null) ...<Widget>[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.ember.withValues(alpha: 0.18),
                          borderRadius: AppRadii.pill,
                        ),
                        child: Text(
                          product.badge!.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.ember,
                            fontSize: 9,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: const TextStyle(
                    color: AppColors.textDim,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                if (product.bonusCrystals > 0) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    '+${product.bonusCrystals} bonus',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 92,
            child: owned
                ? const Center(
                    child: Text(
                      'OWNED',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      padding: EdgeInsets.zero,
                      backgroundColor: highlight
                          ? AppColors.crystal
                          : AppColors.surfaceHigh,
                      foregroundColor:
                          highlight ? AppColors.voidBlack : AppColors.text,
                    ),
                    onPressed: busy ? null : onBuy,
                    child: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            product.price,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Route wrapper so `/store` can be reached from the main menu too.
class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key, this.requiredCrystals = 0});

  final int requiredCrystals;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.night,
        body: NightBackdrop(
          child: SafeArea(
            child: StoreView(
              requiredCrystals: requiredCrystals,
              onExit: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      );
}
