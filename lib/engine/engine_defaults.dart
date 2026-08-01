/// Engine-wide constants. Everything here can be overridden from a script, so
/// no gameplay decision is hard-coded in Dart.
abstract final class EngineDefaults {
  /// Character id treated as "the player" when a message is authored.
  static const String playerCharacterId = 'nadia';

  /// Variable a script can set to change the player character id.
  static const String playerIdVariable = 'player_id';

  /// Fallback messaging app.
  static const String defaultApp = 'messenger';

  /// Id of the system/narration pseudo-character.
  static const String systemCharacterId = 'system';

  static const String narratorCharacterId = 'narrator';

  /// Milliseconds of pause per character of dialogue.
  static const int msPerCharacter = 26;

  static const Duration minMessagePause = Duration(milliseconds: 420);
  static const Duration maxMessagePause = Duration(milliseconds: 2600);
  static const Duration maxTypingDuration = Duration(seconds: 8);
  static const Duration defaultTypingDuration = Duration(milliseconds: 1500);
  static const Duration defaultNotificationDwell = Duration(milliseconds: 900);

  /// Crystals granted to a brand new profile.
  static const int startingCrystals = 60;

  /// Cost used when a `💎` option does not declare a price.
  static const int defaultPremiumCost = 10;

  /// Apps installed on a fresh phone.
  static const List<String> preinstalledApps = <String>[
    'messenger',
    'browser',
    'gallery',
    'contacts',
    'calls',
    'settings',
    'store',
  ];

  /// Home page of the in-game browser.
  static const String browserHomePage = 'between://home';
}
