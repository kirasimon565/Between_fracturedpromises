import 'dart:convert';

import 'package:drift/drift.dart' show QueryRow, Variable;

import '../../engine/engine.dart';
import '../app_database.dart';
import '../schema.dart';

/// Everything the "Continue" card and the load menu need without opening a
/// full snapshot.
class SaveSlotSummary {
  const SaveSlotSummary({
    required this.slot,
    required this.name,
    required this.episodeId,
    required this.episodeNo,
    required this.label,
    required this.line,
    required this.scene,
    required this.summary,
    required this.playtime,
    required this.auto,
    required this.updatedAt,
    this.cover,
  });

  final int slot;
  final String name;
  final String episodeId;
  final int episodeNo;
  final String label;
  final int line;
  final String scene;
  final String summary;
  final Duration playtime;
  final bool auto;
  final DateTime updatedAt;
  final String? cover;

  bool get isEmpty => episodeId.isEmpty;

  factory SaveSlotSummary.fromRow(QueryRow row) => SaveSlotSummary(
    slot: row.read<int>('slot'),
    name: row.read<String>('name'),
    episodeId: row.read<String>('episode_id'),
    episodeNo: row.read<int>('episode_no'),
    label: row.read<String>('label'),
    line: row.read<int>('line'),
    scene: row.read<String>('scene'),
    summary: row.read<String>('summary'),
    playtime: Duration(milliseconds: row.read<int>('playtime_ms')),
    auto: row.read<int>('auto') == 1,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row.read<int>('updated_at')),
    cover: row.readNullable<String>('cover'),
  );
}

/// Reads and writes playthroughs.
///
/// A save is two things at once:
///  * a **snapshot** (`runtime_checkpoints.snapshot`) that resumes the
///    interpreter at the exact instruction, and
///  * a set of **projections** (variables, flags, relationships, journal,
///    objectives, evidence, installed apps, browser history, notifications)
///    that the UI can query cheaply.
class SaveRepository {
  SaveRepository(this._db);

  final AppDatabase _db;

  Future<List<SaveSlotSummary>> listSlots() async {
    final List<QueryRow> rows = await _db.rows(
      'SELECT * FROM save_slots ORDER BY updated_at DESC',
    );
    return rows.map(SaveSlotSummary.fromRow).toList();
  }

  Future<SaveSlotSummary?> slot(int slot) async {
    final QueryRow? row = await _db.row(
      'SELECT * FROM save_slots WHERE slot = ?',
      <Variable<Object>>[Vars.integer(slot)],
    );
    return row == null ? null : SaveSlotSummary.fromRow(row);
  }

  Future<SaveSlotSummary?> mostRecent() async {
    final QueryRow? row = await _db.row(
      'SELECT s.* FROM save_slots s '
      'INNER JOIN runtime_checkpoints c ON c.slot = s.slot '
      'ORDER BY s.updated_at DESC LIMIT 1',
    );
    return row == null ? null : SaveSlotSummary.fromRow(row);
  }

  Future<bool> hasAnySave() async {
    final QueryRow? row = await _db.row(
      'SELECT COUNT(*) AS n FROM runtime_checkpoints',
    );
    return (row?.read<int>('n') ?? 0) > 0;
  }

  /// Persists a snapshot plus its projections in one transaction.
  Future<void> write({
    required int slot,
    required EngineSnapshot snapshot,
    required GameState state,
    String name = '',
    String summary = '',
    int episodeNo = 0,
    String? cover,
    Duration playtime = Duration.zero,
    bool auto = true,
  }) async {
    final int now = DateTime.now().millisecondsSinceEpoch;

    await _db.transaction(() async {
      await _db.exec(
        'INSERT INTO save_slots '
        '(slot, name, episode_id, episode_no, label, line, scene, summary, '
        ' cover, playtime_ms, auto, created_at, updated_at) '
        'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?) '
        'ON CONFLICT(slot) DO UPDATE SET '
        ' name = excluded.name, episode_id = excluded.episode_id, '
        ' episode_no = excluded.episode_no, label = excluded.label, '
        ' line = excluded.line, scene = excluded.scene, '
        ' summary = excluded.summary, cover = excluded.cover, '
        ' playtime_ms = excluded.playtime_ms, auto = excluded.auto, '
        ' updated_at = excluded.updated_at',
        <Object?>[
          slot,
          name,
          snapshot.episodeId,
          episodeNo,
          snapshot.label,
          snapshot.line,
          state.currentScene,
          summary,
          cover,
          playtime.inMilliseconds,
          auto ? 1 : 0,
          now,
          now,
        ],
      );

      await _db.exec(
        'INSERT INTO runtime_checkpoints '
        '(slot, episode_id, program_id, pc, label, line, status, seed, '
        ' snapshot, saved_at, version) '
        'VALUES (?,?,?,?,?,?,?,?,?,?,?) '
        'ON CONFLICT(slot) DO UPDATE SET '
        ' episode_id = excluded.episode_id, program_id = excluded.program_id, '
        ' pc = excluded.pc, label = excluded.label, line = excluded.line, '
        ' status = excluded.status, seed = excluded.seed, '
        ' snapshot = excluded.snapshot, saved_at = excluded.saved_at, '
        ' version = excluded.version',
        <Object?>[
          slot,
          snapshot.episodeId,
          snapshot.programId,
          snapshot.programCounter,
          snapshot.label,
          snapshot.line,
          snapshot.status.name,
          snapshot.randomSeed,
          snapshot.encode(),
          snapshot.savedAt.millisecondsSinceEpoch,
          snapshot.version,
        ],
      );

      await _writeProjections(slot, state, now);
    });
  }

  Future<EngineSnapshot?> readSnapshot(int slot) async {
    final QueryRow? row = await _db.row(
      'SELECT snapshot FROM runtime_checkpoints WHERE slot = ?',
      <Variable<Object>>[Vars.integer(slot)],
    );
    if (row == null) return null;
    final Map<String, dynamic> json =
        jsonDecode(row.read<String>('snapshot')) as Map<String, dynamic>;
    return EngineSnapshot.fromJson(json);
  }

  Future<void> deleteSlot(int slot) => _db.clearSlot(slot);

  Future<void> renameSlot(int slot, String name) => _db.exec(
    'UPDATE save_slots SET name = ?, updated_at = ? WHERE slot = ?',
    <Object?>[name, DateTime.now().millisecondsSinceEpoch, slot],
  );

  /// Copies the autosave into a manual slot.
  Future<void> copySlot(int from, int to, {String name = ''}) async {
    final EngineSnapshot? snapshot = await readSnapshot(from);
    if (snapshot == null) return;
    final SaveSlotSummary? source = await slot(from);
    final GameState state = GameState()..restore(snapshot.gameState);
    await write(
      slot: to,
      snapshot: snapshot,
      state: state,
      name: name.isEmpty ? (source?.name ?? '') : name,
      summary: source?.summary ?? '',
      episodeNo: source?.episodeNo ?? 0,
      playtime: source?.playtime ?? Duration.zero,
      auto: false,
    );
    state.dispose();
  }

  // ── Projections ─────────────────────────────────────────────────────────

  Future<void> _writeProjections(int slot, GameState state, int now) async {
    for (final String table in AppSchema.slotScopedTables) {
      if (table == 'runtime_checkpoints') continue;
      await _db.exec('DELETE FROM $table WHERE slot = ?', <Object?>[slot]);
    }

    for (final MapEntry<String, EngineValue> entry
        in state.variables.snapshot.entries) {
      await _db.exec(
        'INSERT OR REPLACE INTO player_variables (slot, name, value, type) '
        'VALUES (?,?,?,?)',
        <Object?>[
          slot,
          entry.key,
          jsonEncode(entry.value.raw),
          _typeOf(entry.value),
        ],
      );
    }

    for (final String flag in state.flags) {
      await _db.exec(
        'INSERT OR REPLACE INTO player_flags (slot, name, set_at) VALUES (?,?,?)',
        <Object?>[slot, flag, now],
      );
    }

    for (final Relationship r in state.relationships.values) {
      await _db.exec(
        'INSERT OR REPLACE INTO relationships '
        '(slot, character_id, trust, friendship, love, tension, suspicion) '
        'VALUES (?,?,?,?,?,?,?)',
        <Object?>[
          slot,
          r.characterId,
          r.trust.toDouble(),
          r.friendship.toDouble(),
          r.love.toDouble(),
          r.tension.toDouble(),
          r.suspicion.toDouble(),
        ],
      );
    }

    for (final JournalEntry entry in state.journal) {
      await _db.exec(
        'INSERT OR REPLACE INTO journal_entries '
        '(slot, entry_id, title, body, category, created_at) VALUES (?,?,?,?,?,?)',
        <Object?>[
          slot,
          entry.id,
          entry.title,
          entry.body,
          entry.category,
          entry.createdAt.millisecondsSinceEpoch,
        ],
      );
    }

    for (final Objective objective in state.objectives.values) {
      await _db.exec(
        'INSERT OR REPLACE INTO objectives '
        '(slot, objective_id, title, description, status, updated_at) '
        'VALUES (?,?,?,?,?,?)',
        <Object?>[
          slot,
          objective.id,
          objective.title,
          objective.description,
          objective.status.name,
          now,
        ],
      );
    }

    for (final EvidenceEntry evidence in state.evidence.values) {
      await _db.exec(
        'INSERT OR REPLACE INTO evidence '
        '(slot, evidence_id, title, description, source, image, discovered_at) '
        'VALUES (?,?,?,?,?,?,?)',
        <Object?>[
          slot,
          evidence.id,
          evidence.title,
          evidence.description,
          evidence.source ?? '',
          evidence.image,
          evidence.discoveredAt?.millisecondsSinceEpoch ?? now,
        ],
      );
    }

    for (final InstalledApp app in state.phone.apps) {
      await _db.exec(
        'INSERT OR REPLACE INTO installed_apps '
        '(slot, app_id, name, icon, source, installed_at) VALUES (?,?,?,?,?,?)',
        <Object?>[
          slot,
          app.id,
          app.name,
          app.icon,
          app.source,
          app.installedAt?.millisecondsSinceEpoch ?? now,
        ],
      );
    }

    for (final BrowserHistoryEntry entry in state.browser.history.take(80)) {
      await _db.exec(
        'INSERT INTO browser_history (slot, url, title, bookmark, visited_at) '
        'VALUES (?,?,?,0,?)',
        <Object?>[
          slot,
          entry.url,
          entry.title,
          entry.visitedAt.millisecondsSinceEpoch,
        ],
      );
    }
    for (final BrowserHistoryEntry entry in state.browser.bookmarks) {
      await _db.exec(
        'INSERT INTO browser_history (slot, url, title, bookmark, visited_at) '
        'VALUES (?,?,?,1,?)',
        <Object?>[
          slot,
          entry.url,
          entry.title,
          entry.visitedAt.millisecondsSinceEpoch,
        ],
      );
    }

    for (final GameNotification n in state.phone.notifications.take(60)) {
      await _db.exec(
        'INSERT OR REPLACE INTO notifications '
        '(slot, notification_id, app_id, title, body, thread_id, read, created_at) '
        'VALUES (?,?,?,?,?,?,?,?)',
        <Object?>[
          slot,
          n.id,
          n.appId,
          n.title,
          n.body,
          n.threadId,
          n.read ? 1 : 0,
          n.timestamp.millisecondsSinceEpoch,
        ],
      );
    }
  }

  static String _typeOf(EngineValue value) {
    if (value.isNum) return 'number';
    if (value.isBool) return 'bool';
    if (value.isList) return 'list';
    if (value.isMap) return 'map';
    return 'string';
  }
}
