/// The complete SQLite schema, expressed as DDL executed through Drift's
/// migrator.
///
/// Two rules govern what lives here:
///  1. **Story scripts are never stored in the database.** They are compiled
///     from `assets/story/**` at runtime; the database only remembers *where
///     the player is* inside them.
///  2. Anything the UI needs to query without deserialising a whole save
///     (gallery, achievements, journal, objectives…) gets a real table, while
///     the byte-exact resume information lives in a single snapshot blob.
abstract final class AppSchema {
  static const int version = 1;

  /// Slot id used for the single "continue" save the phone UI writes to.
  static const int autoSlot = 0;

  static const List<String> createStatements = <String>[
    // ── Profile / global player data ───────────────────────────────────────
    '''
    CREATE TABLE IF NOT EXISTS player_profile (
      id             INTEGER PRIMARY KEY CHECK (id = 1),
      name           TEXT    NOT NULL DEFAULT 'Nadia',
      display_name   TEXT    NOT NULL DEFAULT '',
      pronouns       TEXT    NOT NULL DEFAULT 'she/her',
      avatar         TEXT,
      age            INTEGER NOT NULL DEFAULT 0,
      onboarded      INTEGER NOT NULL DEFAULT 0,
      created_at     INTEGER NOT NULL,
      updated_at     INTEGER NOT NULL
    )
    ''',
    '''
    CREATE TABLE IF NOT EXISTS wallet (
      id                 INTEGER PRIMARY KEY CHECK (id = 1),
      crystals           INTEGER NOT NULL DEFAULT 0,
      lifetime_earned    INTEGER NOT NULL DEFAULT 0,
      lifetime_spent     INTEGER NOT NULL DEFAULT 0,
      lifetime_purchased INTEGER NOT NULL DEFAULT 0,
      ad_free            INTEGER NOT NULL DEFAULT 0,
      last_restore_at    INTEGER
    )
    ''',
    '''
    CREATE TABLE IF NOT EXISTS wallet_entitlements (
      sku         TEXT PRIMARY KEY,
      kind        TEXT NOT NULL DEFAULT 'non_consumable',
      provider    TEXT NOT NULL DEFAULT 'unknown',
      acquired_at INTEGER NOT NULL
    )
    ''',
    '''
    CREATE TABLE IF NOT EXISTS choice_unlocks (
      choice_id   TEXT PRIMARY KEY,
      episode_id  TEXT NOT NULL DEFAULT '',
      cost        INTEGER NOT NULL DEFAULT 0,
      unlocked_at INTEGER NOT NULL
    )
    ''',
    '''
    CREATE TABLE IF NOT EXISTS purchase_receipts (
      id           TEXT PRIMARY KEY,
      sku          TEXT NOT NULL,
      provider     TEXT NOT NULL,
      state        TEXT NOT NULL,
      quantity     INTEGER NOT NULL DEFAULT 1,
      crystals     INTEGER NOT NULL DEFAULT 0,
      purchased_at INTEGER NOT NULL,
      acknowledged INTEGER NOT NULL DEFAULT 0,
      payload      TEXT
    )
    ''',
    '''
    CREATE TABLE IF NOT EXISTS settings (
      key   TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
    ''',

    // ── Saves & runtime checkpoints ────────────────────────────────────────
    '''
    CREATE TABLE IF NOT EXISTS save_slots (
      slot        INTEGER PRIMARY KEY,
      name        TEXT    NOT NULL DEFAULT '',
      episode_id  TEXT    NOT NULL DEFAULT '',
      episode_no  INTEGER NOT NULL DEFAULT 0,
      label       TEXT    NOT NULL DEFAULT '',
      line        INTEGER NOT NULL DEFAULT 0,
      scene       TEXT    NOT NULL DEFAULT '',
      summary     TEXT    NOT NULL DEFAULT '',
      cover       TEXT,
      playtime_ms INTEGER NOT NULL DEFAULT 0,
      auto        INTEGER NOT NULL DEFAULT 0,
      created_at  INTEGER NOT NULL,
      updated_at  INTEGER NOT NULL
    )
    ''',
    '''
    CREATE TABLE IF NOT EXISTS runtime_checkpoints (
      slot       INTEGER PRIMARY KEY REFERENCES save_slots(slot) ON DELETE CASCADE,
      episode_id TEXT    NOT NULL,
      program_id TEXT    NOT NULL,
      pc         INTEGER NOT NULL,
      label      TEXT    NOT NULL,
      line       INTEGER NOT NULL,
      status     TEXT    NOT NULL,
      seed       INTEGER NOT NULL,
      snapshot   TEXT    NOT NULL,
      saved_at   INTEGER NOT NULL,
      version    INTEGER NOT NULL DEFAULT 2
    )
    ''',

    // ── Queryable projections of the live game state ───────────────────────
    '''
    CREATE TABLE IF NOT EXISTS player_variables (
      slot  INTEGER NOT NULL,
      name  TEXT    NOT NULL,
      value TEXT    NOT NULL,
      type  TEXT    NOT NULL DEFAULT 'string',
      PRIMARY KEY (slot, name)
    )
    ''',
    '''
    CREATE TABLE IF NOT EXISTS player_flags (
      slot INTEGER NOT NULL,
      name TEXT    NOT NULL,
      set_at INTEGER NOT NULL,
      PRIMARY KEY (slot, name)
    )
    ''',
    '''
    CREATE TABLE IF NOT EXISTS relationships (
      slot         INTEGER NOT NULL,
      character_id TEXT    NOT NULL,
      trust        REAL    NOT NULL DEFAULT 0,
      friendship   REAL    NOT NULL DEFAULT 0,
      love         REAL    NOT NULL DEFAULT 0,
      tension      REAL    NOT NULL DEFAULT 0,
      suspicion    REAL    NOT NULL DEFAULT 0,
      PRIMARY KEY (slot, character_id)
    )
    ''',
    '''
    CREATE TABLE IF NOT EXISTS journal_entries (
      slot       INTEGER NOT NULL,
      entry_id   TEXT    NOT NULL,
      title      TEXT    NOT NULL,
      body       TEXT    NOT NULL,
      category   TEXT    NOT NULL DEFAULT 'note',
      created_at INTEGER NOT NULL,
      PRIMARY KEY (slot, entry_id)
    )
    ''',
    '''
    CREATE TABLE IF NOT EXISTS objectives (
      slot        INTEGER NOT NULL,
      objective_id TEXT   NOT NULL,
      title       TEXT    NOT NULL,
      description TEXT    NOT NULL DEFAULT '',
      status      TEXT    NOT NULL DEFAULT 'active',
      updated_at  INTEGER NOT NULL,
      PRIMARY KEY (slot, objective_id)
    )
    ''',
    '''
    CREATE TABLE IF NOT EXISTS evidence (
      slot         INTEGER NOT NULL,
      evidence_id  TEXT    NOT NULL,
      title        TEXT    NOT NULL,
      description  TEXT    NOT NULL DEFAULT '',
      source       TEXT    NOT NULL DEFAULT '',
      image        TEXT,
      discovered_at INTEGER NOT NULL,
      PRIMARY KEY (slot, evidence_id)
    )
    ''',
    '''
    CREATE TABLE IF NOT EXISTS installed_apps (
      slot         INTEGER NOT NULL,
      app_id       TEXT    NOT NULL,
      name         TEXT    NOT NULL,
      icon         TEXT,
      source       TEXT    NOT NULL DEFAULT 'system',
      installed_at INTEGER NOT NULL,
      PRIMARY KEY (slot, app_id)
    )
    ''',
    '''
    CREATE TABLE IF NOT EXISTS browser_history (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      slot       INTEGER NOT NULL,
      url        TEXT    NOT NULL,
      title      TEXT    NOT NULL DEFAULT '',
      bookmark   INTEGER NOT NULL DEFAULT 0,
      visited_at INTEGER NOT NULL
    )
    ''',
    '''
    CREATE TABLE IF NOT EXISTS notifications (
      slot            INTEGER NOT NULL,
      notification_id TEXT    NOT NULL,
      app_id          TEXT    NOT NULL,
      title           TEXT    NOT NULL,
      body            TEXT    NOT NULL DEFAULT '',
      thread_id       TEXT,
      read            INTEGER NOT NULL DEFAULT 0,
      created_at      INTEGER NOT NULL,
      PRIMARY KEY (slot, notification_id)
    )
    ''',

    // ── Profile-wide collections (survive New Game) ────────────────────────
    '''
    CREATE TABLE IF NOT EXISTS gallery_unlocks (
      item_id     TEXT PRIMARY KEY,
      title       TEXT NOT NULL,
      image       TEXT NOT NULL,
      category    TEXT NOT NULL DEFAULT 'story',
      episode_id  TEXT NOT NULL DEFAULT '',
      premium     INTEGER NOT NULL DEFAULT 0,
      unlocked_at INTEGER NOT NULL
    )
    ''',
    '''
    CREATE TABLE IF NOT EXISTS achievements (
      achievement_id TEXT PRIMARY KEY,
      title          TEXT NOT NULL,
      description    TEXT NOT NULL DEFAULT '',
      icon           TEXT,
      secret         INTEGER NOT NULL DEFAULT 0,
      progress       INTEGER NOT NULL DEFAULT 0,
      target         INTEGER NOT NULL DEFAULT 1,
      unlocked       INTEGER NOT NULL DEFAULT 0,
      unlocked_at    INTEGER
    )
    ''',
    '''
    CREATE TABLE IF NOT EXISTS episode_progress (
      episode_id   TEXT PRIMARY KEY,
      episode_no   INTEGER NOT NULL DEFAULT 0,
      title        TEXT NOT NULL DEFAULT '',
      started_at   INTEGER,
      completed_at INTEGER,
      last_label   TEXT NOT NULL DEFAULT '',
      plays        INTEGER NOT NULL DEFAULT 0
    )
    ''',
    'CREATE INDEX IF NOT EXISTS idx_history_slot ON browser_history (slot, visited_at DESC)',
    'CREATE INDEX IF NOT EXISTS idx_notifications_slot ON notifications (slot, created_at DESC)',
  ];

  /// Tables that belong to a single playthrough and are wiped on "New Game".
  static const List<String> slotScopedTables = <String>[
    'player_variables',
    'player_flags',
    'relationships',
    'journal_entries',
    'objectives',
    'evidence',
    'installed_apps',
    'browser_history',
    'notifications',
    'runtime_checkpoints',
  ];
}
