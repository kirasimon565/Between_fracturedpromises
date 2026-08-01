/// Static configuration: asset locations, episode manifest, route names.
///
/// Everything here is data, not behaviour — adding Episode 2 means adding one
/// [EpisodeManifest] entry and dropping a `.txt` file into `assets/story`.
library;

class EpisodeManifest {
  const EpisodeManifest({
    required this.id,
    required this.number,
    required this.title,
    required this.script,
    this.tagline = '',
    this.available = true,
    this.cover,
  });

  final String id;
  final int number;
  final String title;

  /// Path relative to [AppConfig.storyRoot].
  final String script;
  final String tagline;
  final bool available;
  final String? cover;
}

abstract final class AppConfig {
  static const String appName = 'Between';
  static const String subtitle = 'Fractured Promises';
  static const String studio = 'Between Studio';

  /// Root of every script file. The loader resolves `@include` relative to it.
  static const String storyRoot = 'assets/story/';

  static const String websiteCatalog = 'assets/data/websites.json';
  static const String contactsCatalog = 'assets/data/contacts.json';
  static const String achievementCatalog = 'assets/data/achievements.json';
  static const String galleryCatalog = 'assets/data/gallery.json';

  static const List<EpisodeManifest> episodes = <EpisodeManifest>[
    EpisodeManifest(
      id: 'ep1',
      number: 1,
      title: 'The Spark',
      script: 'episodes/ep1.txt',
      tagline: 'Everything starts with a message you should not have answered.',
    ),
    EpisodeManifest(
      id: 'ep2',
      number: 2,
      title: 'The Slip',
      script: 'episodes/ep2.txt',
      tagline: 'Coming soon.',
      available: false,
    ),
  ];

  static EpisodeManifest episode(String id) => episodes.firstWhere(
    (EpisodeManifest e) => e.id == id,
    orElse: () => episodes.first,
  );

  static const String defaultEpisodeId = 'ep1';
}

/// Route paths used by `go_router`. Kept as constants so the engine can emit
/// `NavigateEffect('/store')` without importing the router.
abstract final class Routes {
  static const String splash = '/';
  static const String studio = '/studio';
  static const String disclaimer = '/disclaimer';
  static const String welcome = '/welcome';
  static const String setup = '/setup';
  static const String menu = '/menu';
  static const String phone = '/phone';
  static const String app = '/phone/app/:appId';
  static const String store = '/store';
  static const String saves = '/saves';
  static const String settings = '/settings';
  static const String episodes = '/episodes';
  static const String debug = '/debug';

  static String appPath(String appId) => '/phone/app/$appId';
}
