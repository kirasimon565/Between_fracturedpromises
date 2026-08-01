/// Premium currency ("crystals") wallet.
///
/// The wallet lives in the engine so the DSL can spend crystals on premium
/// choices, but the *purchase* of crystals happens in the billing layer, which
/// simply calls [Wallet.credit] through the runtime.
class Wallet {
  const Wallet({
    this.crystals = 0,
    this.lifetimeEarned = 0,
    this.lifetimeSpent = 0,
    this.lifetimePurchased = 0,
    this.ownedSkus = const <String>[],
    this.unlockedChoices = const <String>[],
    this.adFreePurchased = false,
    this.lastRestoreAt,
  });

  final int crystals;
  final int lifetimeEarned;
  final int lifetimeSpent;
  final int lifetimePurchased;

  /// Non-consumable products the player owns (episode packs, ad-free…).
  final List<String> ownedSkus;

  /// Premium choice ids already paid for — re-picking them is free.
  final List<String> unlockedChoices;

  final bool adFreePurchased;
  final DateTime? lastRestoreAt;

  bool canAfford(int amount) => crystals >= amount;

  bool ownsSku(String sku) => ownedSkus.contains(sku);

  bool hasUnlockedChoice(String id) => unlockedChoices.contains(id);

  Wallet copyWith({
    int? crystals,
    int? lifetimeEarned,
    int? lifetimeSpent,
    int? lifetimePurchased,
    List<String>? ownedSkus,
    List<String>? unlockedChoices,
    bool? adFreePurchased,
    DateTime? lastRestoreAt,
  }) =>
      Wallet(
        crystals: crystals ?? this.crystals,
        lifetimeEarned: lifetimeEarned ?? this.lifetimeEarned,
        lifetimeSpent: lifetimeSpent ?? this.lifetimeSpent,
        lifetimePurchased: lifetimePurchased ?? this.lifetimePurchased,
        ownedSkus: ownedSkus ?? this.ownedSkus,
        unlockedChoices: unlockedChoices ?? this.unlockedChoices,
        adFreePurchased: adFreePurchased ?? this.adFreePurchased,
        lastRestoreAt: lastRestoreAt ?? this.lastRestoreAt,
      );

  /// Adds crystals earned in-game (story rewards, achievements).
  Wallet earn(int amount) => copyWith(
        crystals: crystals + amount,
        lifetimeEarned: lifetimeEarned + amount,
      );

  /// Adds crystals bought with real money.
  Wallet credit(int amount, {String? sku}) => copyWith(
        crystals: crystals + amount,
        lifetimePurchased: lifetimePurchased + amount,
        ownedSkus: sku == null || ownedSkus.contains(sku)
            ? ownedSkus
            : <String>[...ownedSkus, sku],
      );

  Wallet spend(int amount, {String? choiceId}) => copyWith(
        crystals: (crystals - amount) < 0 ? 0 : crystals - amount,
        lifetimeSpent: lifetimeSpent + amount,
        unlockedChoices: choiceId == null || unlockedChoices.contains(choiceId)
            ? unlockedChoices
            : <String>[...unlockedChoices, choiceId],
      );

  Wallet grantEntitlement(String sku) => copyWith(
        ownedSkus:
            ownedSkus.contains(sku) ? ownedSkus : <String>[...ownedSkus, sku],
        adFreePurchased: adFreePurchased || sku.contains('ad_free'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'crystals': crystals,
        'earned': lifetimeEarned,
        'spent': lifetimeSpent,
        'purchased': lifetimePurchased,
        'skus': ownedSkus,
        'choices': unlockedChoices,
        'adFree': adFreePurchased,
        if (lastRestoreAt != null)
          'restore': lastRestoreAt!.millisecondsSinceEpoch,
      };

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        crystals: (json['crystals'] as num?)?.toInt() ?? 0,
        lifetimeEarned: (json['earned'] as num?)?.toInt() ?? 0,
        lifetimeSpent: (json['spent'] as num?)?.toInt() ?? 0,
        lifetimePurchased: (json['purchased'] as num?)?.toInt() ?? 0,
        ownedSkus: (json['skus'] as List<dynamic>?)
                ?.map((dynamic e) => e.toString())
                .toList() ??
            const <String>[],
        unlockedChoices: (json['choices'] as List<dynamic>?)
                ?.map((dynamic e) => e.toString())
                .toList() ??
            const <String>[],
        adFreePurchased: json['adFree'] as bool? ?? false,
        lastRestoreAt: json['restore'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                (json['restore'] as num).toInt()),
      );
}

/// Player identity captured during the setup flow.
class PlayerProfile {
  const PlayerProfile({
    this.name = 'Nadia',
    this.displayName = 'Nadia Carter',
    this.pronouns = 'she/her',
    this.avatar,
    this.age = 28,
    this.createdAt,
  });

  final String name;
  final String displayName;
  final String pronouns;
  final String? avatar;
  final int age;
  final DateTime? createdAt;

  PlayerProfile copyWith({
    String? name,
    String? displayName,
    String? pronouns,
    String? avatar,
    int? age,
  }) =>
      PlayerProfile(
        name: name ?? this.name,
        displayName: displayName ?? this.displayName,
        pronouns: pronouns ?? this.pronouns,
        avatar: avatar ?? this.avatar,
        age: age ?? this.age,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'display': displayName,
        'pronouns': pronouns,
        if (avatar != null) 'avatar': avatar,
        'age': age,
        if (createdAt != null) 'at': createdAt!.millisecondsSinceEpoch,
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => PlayerProfile(
        name: json['name'] as String? ?? 'Nadia',
        displayName: json['display'] as String? ?? 'Nadia Carter',
        pronouns: json['pronouns'] as String? ?? 'she/her',
        avatar: json['avatar'] as String?,
        age: (json['age'] as num?)?.toInt() ?? 28,
        createdAt: json['at'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch((json['at'] as num).toInt()),
      );
}
