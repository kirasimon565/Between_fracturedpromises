import 'billing_models.dart';

/// The crystal packs and non-consumables offered in the in-game store.
///
/// The same SKU ids are configured in Huawei AppGallery Connect, Amazon
/// Developer Console and Samsung Seller Portal, so a single catalog drives all
/// three storefronts. Prices shown here are fallbacks used before (or instead
/// of) a live product query.
abstract final class StoreCatalog {
  static const String skuSmall = 'crystals_small';
  static const String skuMedium = 'crystals_medium';
  static const String skuLarge = 'crystals_large';
  static const String skuHuge = 'crystals_huge';
  static const String skuStarter = 'starter_bundle';
  static const String skuAdFree = 'ad_free_forever';
  static const String skuSeasonPass = 'season_pass_1';

  static const List<StoreProduct> crystalPacks = <StoreProduct>[
    StoreProduct(
      sku: skuSmall,
      title: 'Pocket Shard',
      description: '60 crystals',
      price: '\$1.99',
      crystals: 60,
    ),
    StoreProduct(
      sku: skuMedium,
      title: 'Fractured Cluster',
      description: '180 crystals + 20 bonus',
      price: '\$4.99',
      crystals: 180,
      bonusCrystals: 20,
      badge: 'Popular',
      highlight: true,
    ),
    StoreProduct(
      sku: skuLarge,
      title: 'Midnight Vault',
      description: '400 crystals + 80 bonus',
      price: '\$9.99',
      crystals: 400,
      bonusCrystals: 80,
      badge: 'Best value',
    ),
    StoreProduct(
      sku: skuHuge,
      title: 'Whole Truth',
      description: '1000 crystals + 300 bonus',
      price: '\$19.99',
      crystals: 1000,
      bonusCrystals: 300,
    ),
  ];

  static const List<StoreProduct> specials = <StoreProduct>[
    StoreProduct(
      sku: skuStarter,
      title: 'Starter Bundle',
      description: '120 crystals and the Episode 1 art set',
      price: '\$2.99',
      crystals: 120,
      kind: ProductKind.nonConsumable,
      badge: 'One time',
    ),
    StoreProduct(
      sku: skuAdFree,
      title: 'Remove Interruptions',
      description: 'Disables sponsored pop-ups inside the in-game browser',
      price: '\$3.99',
      kind: ProductKind.nonConsumable,
    ),
    StoreProduct(
      sku: skuSeasonPass,
      title: 'Season One Pass',
      description: 'Unlocks every premium choice in Episodes 1–6',
      price: '\$14.99',
      kind: ProductKind.nonConsumable,
    ),
  ];

  static List<StoreProduct> get all => <StoreProduct>[
    ...crystalPacks,
    ...specials,
  ];

  static List<String> get skus =>
      all.map((StoreProduct p) => p.sku).toList(growable: false);

  static StoreProduct? bySku(String sku) {
    for (final StoreProduct product in all) {
      if (product.sku == sku) return product;
    }
    return null;
  }

  /// Non-consumables that grant a permanent entitlement rather than currency.
  static bool isEntitlement(String sku) =>
      bySku(sku)?.kind == ProductKind.nonConsumable;
}
