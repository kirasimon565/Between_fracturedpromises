import 'package:drift/drift.dart';

import 'connection/database_connection.dart';
import 'schema.dart';

/// The application database.
///
/// This is a hand-written Drift database: the schema is declared as SQL in
/// [AppSchema] and executed through Drift's migrator, and every query goes
/// through Drift's `customSelect` / `customStatement` API. That keeps the
/// project free of a `build_runner` step while still using Drift for
/// connection management, transactions, background isolates and migrations.
class AppDatabase extends GeneratedDatabase {
  AppDatabase(super.executor);

  /// Opens the on-device SQLite file (`between.sqlite`).
  factory AppDatabase.open({String fileName = 'between.sqlite'}) =>
      AppDatabase(openDatabaseConnection(fileName));

  /// In-memory database used by tests.
  factory AppDatabase.memory() => AppDatabase(openMemoryConnection());

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables =>
      const Iterable<TableInfo<Table, dynamic>>.empty();

  @override
  Iterable<DatabaseSchemaEntity> get allSchemaEntities =>
      const <DatabaseSchemaEntity>[];

  @override
  int get schemaVersion => AppSchema.version;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await _createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // The schema is additive: re-running the `IF NOT EXISTS` DDL brings
          // an older file up to date without touching existing rows.
          await _createAll();
        },
        beforeOpen: (OpeningDetails details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
          await _createAll();
          await _seed();
        },
      );

  Future<void> _createAll() async {
    for (final String statement in AppSchema.createStatements) {
      await customStatement(statement);
    }
  }

  /// Guarantees the singleton rows exist so every later write is an UPDATE.
  Future<void> _seed() async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    await customStatement(
      'INSERT OR IGNORE INTO player_profile '
      '(id, name, display_name, pronouns, age, onboarded, created_at, updated_at) '
      "VALUES (1, 'Nadia', 'Nadia', 'she/her', 0, 0, ?, ?)",
      <Object?>[now, now],
    );
    await customStatement(
      'INSERT OR IGNORE INTO wallet (id, crystals) VALUES (1, 0)',
    );
  }

  // ── Small helpers shared by the repositories ────────────────────────────

  Future<List<QueryRow>> rows(
    String sql, [
    List<Variable<Object>> variables = const <Variable<Object>>[],
  ]) =>
      customSelect(sql, variables: variables).get();

  Future<QueryRow?> row(
    String sql, [
    List<Variable<Object>> variables = const <Variable<Object>>[],
  ]) =>
      customSelect(sql, variables: variables).getSingleOrNull();

  Future<void> exec(String sql, [List<Object?> args = const <Object?>[]]) =>
      customStatement(sql, args);

  /// Wipes every playthrough-scoped table for [slot].
  Future<void> clearSlot(int slot) async {
    await transaction(() async {
      for (final String table in AppSchema.slotScopedTables) {
        await customStatement('DELETE FROM $table WHERE slot = ?', <Object?>[slot]);
      }
      await customStatement(
          'DELETE FROM save_slots WHERE slot = ?', <Object?>[slot]);
    });
  }

  /// Deletes *everything*, including profile-wide collections. Used by the
  /// "erase all data" button in Settings.
  Future<void> eraseEverything() async {
    await transaction(() async {
      const List<String> tables = <String>[
        ...AppSchema.slotScopedTables,
        'save_slots',
        'gallery_unlocks',
        'achievements',
        'episode_progress',
        'choice_unlocks',
        'settings',
      ];
      for (final String table in tables) {
        await customStatement('DELETE FROM $table');
      }
      await customStatement('UPDATE wallet SET crystals = 0, '
          'lifetime_earned = 0, lifetime_spent = 0 WHERE id = 1');
      await customStatement(
          'UPDATE player_profile SET onboarded = 0 WHERE id = 1');
    });
  }
}

/// Convenience constructors for query parameters.
abstract final class Vars {
  static Variable<Object> text(String value) => Variable<String>(value);

  static Variable<Object> integer(int value) => Variable<int>(value);

  static Variable<Object> real(double value) => Variable<double>(value);

  static Variable<Object> boolean(bool value) => Variable<int>(value ? 1 : 0);
}
