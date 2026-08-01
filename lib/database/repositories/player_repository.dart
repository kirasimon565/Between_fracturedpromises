import 'dart:convert';

import 'package:drift/drift.dart' show QueryRow, Variable;

import '../../engine/engine.dart';
import '../app_database.dart';

/// Profile-wide data that survives "New Game": who the player is, what they
/// own, and how they like the game to play.
class PlayerRepository {
  PlayerRepository(this._db);

  final AppDatabase _db;

  // ── Profile ─────────────────────────────────────────────────────────────

  Future<PlayerProfile> loadProfile() async {
    final QueryRow? row = await _db.row(
      'SELECT * FROM player_profile WHERE id = 1',
    );
    if (row == null) return const PlayerProfile();
    return PlayerProfile(
      name: row.read<String>('name'),
      displayName: row.read<String>('display_name'),
      pronouns: row.read<String>('pronouns'),
      avatar: row.readNullable<String>('avatar'),
      age: row.read<int>('age'),
    );
  }

  Future<bool> isOnboarded() async {
    final QueryRow? row = await _db.row(
      'SELECT onboarded FROM player_profile WHERE id = 1',
    );
    return (row?.read<int>('onboarded') ?? 0) == 1;
  }

  Future<void> saveProfile(PlayerProfile profile, {bool onboarded = true}) =>
      _db.exec(
        'UPDATE player_profile SET name = ?, display_name = ?, pronouns = ?, '
        'avatar = ?, age = ?, onboarded = ?, updated_at = ? WHERE id = 1',
        <Object?>[
          profile.name,
          profile.displayName,
          profile.pronouns,
          profile.avatar,
          profile.age,
          onboarded ? 1 : 0,
          DateTime.now().millisecondsSinceEpoch,
        ],
      );

  // ── Wallet ──────────────────────────────────────────────────────────────

  Future<Wallet> loadWallet() async {
    final QueryRow? row = await _db.row('SELECT * FROM wallet WHERE id = 1');
    final List<QueryRow> skus = await _db.rows(
      'SELECT sku FROM wallet_entitlements',
    );
    final List<QueryRow> unlocks = await _db.rows(
      'SELECT choice_id FROM choice_unlocks',
    );

    if (row == null) {
      return Wallet(
        ownedSkus: skus.map((QueryRow r) => r.read<String>('sku')).toList(),
        unlockedChoices: unlocks
            .map((QueryRow r) => r.read<String>('choice_id'))
            .toList(),
      );
    }

    final int? restore = row.readNullable<int>('last_restore_at');
    return Wallet(
      crystals: row.read<int>('crystals'),
      lifetimeEarned: row.read<int>('lifetime_earned'),
      lifetimeSpent: row.read<int>('lifetime_spent'),
      lifetimePurchased: row.read<int>('lifetime_purchased'),
      adFreePurchased: row.read<int>('ad_free') == 1,
      lastRestoreAt: restore == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(restore),
      ownedSkus: skus.map((QueryRow r) => r.read<String>('sku')).toList(),
      unlockedChoices: unlocks
          .map((QueryRow r) => r.read<String>('choice_id'))
          .toList(),
    );
  }

  Future<void> saveWallet(Wallet wallet, {String episodeId = ''}) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    await _db.transaction(() async {
      await _db.exec(
        'UPDATE wallet SET crystals = ?, lifetime_earned = ?, '
        'lifetime_spent = ?, lifetime_purchased = ?, ad_free = ?, '
        'last_restore_at = ? WHERE id = 1',
        <Object?>[
          wallet.crystals,
          wallet.lifetimeEarned,
          wallet.lifetimeSpent,
          wallet.lifetimePurchased,
          wallet.adFreePurchased ? 1 : 0,
          wallet.lastRestoreAt?.millisecondsSinceEpoch,
        ],
      );
      for (final String sku in wallet.ownedSkus) {
        await _db.exec(
          'INSERT OR IGNORE INTO wallet_entitlements '
          '(sku, kind, provider, acquired_at) VALUES (?,?,?,?)',
          <Object?>[sku, 'non_consumable', 'restored', now],
        );
      }
      for (final String choice in wallet.unlockedChoices) {
        await _db.exec(
          'INSERT OR IGNORE INTO choice_unlocks '
          '(choice_id, episode_id, cost, unlocked_at) VALUES (?,?,?,?)',
          <Object?>[choice, episodeId, 0, now],
        );
      }
    });
  }

  Future<void> recordReceipt({
    required String id,
    required String sku,
    required String provider,
    required String state,
    int quantity = 1,
    int crystals = 0,
    bool acknowledged = false,
    Map<String, Object?> payload = const <String, Object?>{},
  }) => _db.exec(
    'INSERT OR REPLACE INTO purchase_receipts '
    '(id, sku, provider, state, quantity, crystals, purchased_at, '
    ' acknowledged, payload) VALUES (?,?,?,?,?,?,?,?,?)',
    <Object?>[
      id,
      sku,
      provider,
      state,
      quantity,
      crystals,
      DateTime.now().millisecondsSinceEpoch,
      acknowledged ? 1 : 0,
      jsonEncode(payload),
    ],
  );

  Future<bool> hasReceipt(String id) async {
    final QueryRow? row = await _db.row(
      'SELECT 1 AS found FROM purchase_receipts WHERE id = ?',
      <Variable<Object>>[Vars.text(id)],
    );
    return row != null;
  }

  Future<List<Map<String, Object?>>> receipts() async {
    final List<QueryRow> rows = await _db.rows(
      'SELECT * FROM purchase_receipts ORDER BY purchased_at DESC',
    );
    return rows.map((QueryRow r) => r.data).toList();
  }

  // ── Settings ────────────────────────────────────────────────────────────

  Future<EngineSettings> loadSettings() async {
    final QueryRow? row = await _db.row(
      "SELECT value FROM settings WHERE key = 'engine'",
    );
    if (row == null) return const EngineSettings();
    try {
      return EngineSettings.fromJson(
        jsonDecode(row.read<String>('value')) as Map<String, dynamic>,
      );
    } catch (_) {
      return const EngineSettings();
    }
  }

  Future<void> saveSettings(EngineSettings settings) => _db.exec(
    'INSERT OR REPLACE INTO settings (key, value) VALUES (?,?)',
    <Object?>['engine', jsonEncode(settings.toJson())],
  );

  Future<String?> readSetting(String key) async {
    final QueryRow? row = await _db.row(
      'SELECT value FROM settings WHERE key = ?',
      <Variable<Object>>[Vars.text(key)],
    );
    return row?.read<String>('value');
  }

  Future<void> writeSetting(String key, String value) => _db.exec(
    'INSERT OR REPLACE INTO settings (key, value) VALUES (?,?)',
    <Object?>[key, value],
  );
}
