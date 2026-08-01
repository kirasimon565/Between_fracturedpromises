import 'package:drift/drift.dart' show QueryRow, Variable;

import '../../engine/engine.dart';
import '../app_database.dart';

/// Progress that belongs to the *player*, not to a save slot: gallery unlocks,
/// achievements and per-episode completion.
class CollectionRepository {
  CollectionRepository(this._db);

  final AppDatabase _db;

  // ── Gallery ─────────────────────────────────────────────────────────────

  Future<List<GalleryUnlock>> gallery() async {
    final List<QueryRow> rows = await _db.rows(
      'SELECT * FROM gallery_unlocks ORDER BY unlocked_at DESC',
    );
    return rows
        .map(
          (QueryRow r) => GalleryUnlock(
            id: r.read<String>('item_id'),
            title: r.read<String>('title'),
            image: r.read<String>('image'),
            category: r.read<String>('category'),
            nsfw: r.read<int>('premium') == 1,
            episode: r.read<String>('episode_id'),
            unlockedAt: DateTime.fromMillisecondsSinceEpoch(
              r.read<int>('unlocked_at'),
            ),
          ),
        )
        .toList();
  }

  Future<void> unlockGallery(GalleryUnlock item) => _db.exec(
    'INSERT OR REPLACE INTO gallery_unlocks '
    '(item_id, title, image, category, episode_id, premium, unlocked_at) '
    'VALUES (?,?,?,?,?,?,?)',
    <Object?>[
      item.id,
      item.title,
      item.image,
      item.category,
      item.episode ?? '',
      item.nsfw ? 1 : 0,
      (item.unlockedAt ?? DateTime.now()).millisecondsSinceEpoch,
    ],
  );

  Future<bool> isGalleryUnlocked(String id) async {
    final QueryRow? row = await _db.row(
      'SELECT 1 AS found FROM gallery_unlocks WHERE item_id = ?',
      <Variable<Object>>[Vars.text(id)],
    );
    return row != null;
  }

  // ── Achievements ────────────────────────────────────────────────────────

  Future<List<Achievement>> achievements() async {
    final List<QueryRow> rows = await _db.rows(
      'SELECT * FROM achievements ORDER BY unlocked DESC, title ASC',
    );
    return rows.map((QueryRow r) {
      final int? at = r.readNullable<int>('unlocked_at');
      return Achievement(
        id: r.read<String>('achievement_id'),
        title: r.read<String>('title'),
        description: r.read<String>('description'),
        icon: r.readNullable<String>('icon'),
        hidden: r.read<int>('secret') == 1,
        progress: r.read<int>('progress'),
        goal: r.read<int>('target'),
        unlockedAt: at == null ? null : DateTime.fromMillisecondsSinceEpoch(at),
      );
    }).toList();
  }

  Future<void> saveAchievement(Achievement achievement) => _db.exec(
    'INSERT INTO achievements '
    '(achievement_id, title, description, icon, secret, progress, target, '
    ' unlocked, unlocked_at) VALUES (?,?,?,?,?,?,?,?,?) '
    'ON CONFLICT(achievement_id) DO UPDATE SET '
    ' title = excluded.title, description = excluded.description, '
    ' icon = excluded.icon, progress = MAX(achievements.progress, excluded.progress), '
    ' target = excluded.target, '
    ' unlocked = MAX(achievements.unlocked, excluded.unlocked), '
    ' unlocked_at = COALESCE(achievements.unlocked_at, excluded.unlocked_at)',
    <Object?>[
      achievement.id,
      achievement.title,
      achievement.description,
      achievement.icon,
      achievement.hidden ? 1 : 0,
      achievement.progress.round(),
      achievement.goal.round(),
      achievement.unlocked ? 1 : 0,
      achievement.unlockedAt?.millisecondsSinceEpoch,
    ],
  );

  // ── Episodes ────────────────────────────────────────────────────────────

  Future<void> markEpisodeStarted(
    String episodeId, {
    int number = 0,
    String title = '',
  }) => _db.exec(
    'INSERT INTO episode_progress '
    '(episode_id, episode_no, title, started_at, last_label, plays) '
    'VALUES (?,?,?,?,?,1) '
    'ON CONFLICT(episode_id) DO UPDATE SET '
    ' plays = episode_progress.plays + 1, '
    ' title = excluded.title, '
    ' started_at = COALESCE(episode_progress.started_at, excluded.started_at)',
    <Object?>[
      episodeId,
      number,
      title,
      DateTime.now().millisecondsSinceEpoch,
      '',
    ],
  );

  Future<void> markEpisodeCompleted(String episodeId, String lastLabel) =>
      _db.exec(
        'UPDATE episode_progress SET completed_at = ?, last_label = ? '
        'WHERE episode_id = ?',
        <Object?>[DateTime.now().millisecondsSinceEpoch, lastLabel, episodeId],
      );

  Future<bool> isEpisodeCompleted(String episodeId) async {
    final QueryRow? row = await _db.row(
      'SELECT completed_at FROM episode_progress WHERE episode_id = ?',
      <Variable<Object>>[Vars.text(episodeId)],
    );
    return row?.readNullable<int>('completed_at') != null;
  }

  Future<Map<String, bool>> completedEpisodes() async {
    final List<QueryRow> rows = await _db.rows(
      'SELECT episode_id, completed_at FROM episode_progress',
    );
    return <String, bool>{
      for (final QueryRow r in rows)
        r.read<String>('episode_id'):
            r.readNullable<int>('completed_at') != null,
    };
  }
}
