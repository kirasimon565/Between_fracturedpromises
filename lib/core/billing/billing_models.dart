/// Store-agnostic billing vocabulary.
///
/// Nothing in the game (or in the DSL) knows which storefront it is running
/// on — gameplay only ever asks for "credit N crystals".
library;

enum StoreTarget { huawei, amazon, samsung, sandbox }

extension StoreTargetX on StoreTarget {
  String get id => name;

  String get displayName {
    switch (this) {
      case StoreTarget.huawei:
        return 'Huawei AppGallery';
      case StoreTarget.amazon:
        return 'Amazon Appstore';
      case StoreTarget.samsung:
        return 'Samsung Galaxy Store';
      case StoreTarget.sandbox:
        return 'Local sandbox';
    }
  }

  /// Installer package names reported by Android for each storefront.
  static StoreTarget? fromInstaller(String? installer) {
    switch (installer) {
      case 'com.huawei.appmarket':
        return StoreTarget.huawei;
      case 'com.amazon.venezia':
      case 'com.amazon.mShop.android':
        return StoreTarget.amazon;
      case 'com.sec.android.app.samsungapps':
        return StoreTarget.samsung;
      default:
        return null;
    }
  }

  static StoreTarget? fromId(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'huawei':
      case 'appgallery':
        return StoreTarget.huawei;
      case 'amazon':
      case 'appstore':
        return StoreTarget.amazon;
      case 'samsung':
      case 'galaxy':
      case 'galaxystore':
        return StoreTarget.samsung;
      case 'sandbox':
      case 'dev':
      case 'debug':
        return StoreTarget.sandbox;
      default:
        return null;
    }
  }
}

enum ProductKind { consumable, nonConsumable, subscription }

/// A purchasable item as described by the storefront.
class StoreProduct {
  const StoreProduct({
    required this.sku,
    required this.title,
    required this.description,
    required this.price,
    this.kind = ProductKind.consumable,
    this.crystals = 0,
    this.bonusCrystals = 0,
    this.currency = '',
    this.priceMicros = 0,
    this.badge,
    this.highlight = false,
  });

  final String sku;
  final String title;
  final String description;

  /// Localised, formatted price string from the store ("€4,99").
  final String price;
  final ProductKind kind;

  /// Crystals granted on purchase (0 for non-currency products).
  final int crystals;
  final int bonusCrystals;
  final String currency;
  final int priceMicros;
  final String? badge;
  final bool highlight;

  int get totalCrystals => crystals + bonusCrystals;

  StoreProduct copyWith({
    String? title,
    String? description,
    String? price,
    String? currency,
    int? priceMicros,
  }) => StoreProduct(
    sku: sku,
    title: title ?? this.title,
    description: description ?? this.description,
    price: price ?? this.price,
    kind: kind,
    crystals: crystals,
    bonusCrystals: bonusCrystals,
    currency: currency ?? this.currency,
    priceMicros: priceMicros ?? this.priceMicros,
    badge: badge,
    highlight: highlight,
  );

  factory StoreProduct.fromMap(
    Map<Object?, Object?> map, {
    StoreProduct? template,
  }) => StoreProduct(
    sku: (map['sku'] ?? template?.sku ?? '').toString(),
    title: (map['title'] ?? template?.title ?? '').toString(),
    description: (map['description'] ?? template?.description ?? '').toString(),
    price: (map['price'] ?? template?.price ?? '').toString(),
    kind: template?.kind ?? ProductKind.consumable,
    crystals: template?.crystals ?? 0,
    bonusCrystals: template?.bonusCrystals ?? 0,
    currency: (map['currency'] ?? template?.currency ?? '').toString(),
    priceMicros:
        (map['priceMicros'] as num?)?.toInt() ?? template?.priceMicros ?? 0,
    badge: template?.badge,
    highlight: template?.highlight ?? false,
  );
}

enum PurchaseState {
  purchased,
  pending,
  cancelled,
  failed,
  restored,
  alreadyOwned,
}

/// Outcome of a purchase or restore.
class PurchaseResult {
  const PurchaseResult({
    required this.sku,
    required this.state,
    required this.provider,
    this.orderId = '',
    this.token = '',
    this.quantity = 1,
    this.message,
    this.raw = const <String, Object?>{},
  });

  const PurchaseResult.cancelled(this.sku, this.provider)
    : state = PurchaseState.cancelled,
      orderId = '',
      token = '',
      quantity = 1,
      message = null,
      raw = const <String, Object?>{};

  const PurchaseResult.failed(this.sku, this.provider, this.message)
    : state = PurchaseState.failed,
      orderId = '',
      token = '',
      quantity = 1,
      raw = const <String, Object?>{};

  final String sku;
  final PurchaseState state;
  final String provider;
  final String orderId;
  final String token;
  final int quantity;
  final String? message;
  final Map<String, Object?> raw;

  bool get isSuccess =>
      state == PurchaseState.purchased || state == PurchaseState.restored;

  /// Stable identifier used to de-duplicate receipts across restores.
  String get receiptId => orderId.isNotEmpty
      ? orderId
      : (token.isNotEmpty ? token : '$provider:$sku');

  factory PurchaseResult.fromMap(
    Map<Object?, Object?> map, {
    required String provider,
    String? fallbackSku,
  }) {
    final String stateName = (map['state'] ?? 'purchased').toString();
    return PurchaseResult(
      sku: (map['sku'] ?? fallbackSku ?? '').toString(),
      provider: provider,
      state: PurchaseState.values.firstWhere(
        (PurchaseState s) => s.name == stateName,
        orElse: () => PurchaseState.purchased,
      ),
      orderId: (map['orderId'] ?? '').toString(),
      token: (map['token'] ?? map['purchaseToken'] ?? '').toString(),
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      message: map['message']?.toString(),
      raw: map.map<String, Object?>(
        (Object? k, Object? v) => MapEntry<String, Object?>(k.toString(), v),
      ),
    );
  }
}

/// Thrown for programming errors (never for user cancellation).
class BillingException implements Exception {
  BillingException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'BillingException(${code ?? '-'}): $message';
}
