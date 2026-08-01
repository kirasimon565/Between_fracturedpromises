/// Tunables that change *how* the story is played back without changing what
/// the script says. Persisted in Drift and injected into the runtime.
class EngineSettings {
  const EngineSettings({
    this.textSpeed = 1.0,
    this.typingSpeed = 1.0,
    this.autoAdvance = false,
    this.autoAdvanceDelay = const Duration(milliseconds: 1400),
    this.skipSeen = false,
    this.instantMode = false,
    this.reducedMotion = false,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.hapticsEnabled = true,
    this.masterVolume = 1.0,
    this.musicVolume = 0.7,
    this.sfxVolume = 0.9,
    this.debugOverlay = false,
    this.locale = 'en',
  });

  /// Multiplier applied to every story delay. 2.0 = twice as fast.
  final double textSpeed;

  /// Multiplier applied to typing-indicator durations.
  final double typingSpeed;

  final bool autoAdvance;
  final Duration autoAdvanceDelay;

  /// Skip beats the player has already read.
  final bool skipSeen;

  /// Debug / QA mode: all delays collapse to zero.
  final bool instantMode;

  final bool reducedMotion;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool hapticsEnabled;
  final double masterVolume;
  final double musicVolume;
  final double sfxVolume;
  final bool debugOverlay;
  final String locale;

  Duration scaleStory(Duration duration) {
    if (instantMode) return Duration.zero;
    final double speed = textSpeed <= 0 ? 1 : textSpeed;
    return Duration(microseconds: (duration.inMicroseconds / speed).round());
  }

  Duration scaleTyping(Duration duration) {
    if (instantMode) return Duration.zero;
    final double speed = typingSpeed <= 0 ? 1 : typingSpeed;
    return Duration(microseconds: (duration.inMicroseconds / speed).round());
  }

  EngineSettings copyWith({
    double? textSpeed,
    double? typingSpeed,
    bool? autoAdvance,
    Duration? autoAdvanceDelay,
    bool? skipSeen,
    bool? instantMode,
    bool? reducedMotion,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticsEnabled,
    double? masterVolume,
    double? musicVolume,
    double? sfxVolume,
    bool? debugOverlay,
    String? locale,
  }) => EngineSettings(
    textSpeed: textSpeed ?? this.textSpeed,
    typingSpeed: typingSpeed ?? this.typingSpeed,
    autoAdvance: autoAdvance ?? this.autoAdvance,
    autoAdvanceDelay: autoAdvanceDelay ?? this.autoAdvanceDelay,
    skipSeen: skipSeen ?? this.skipSeen,
    instantMode: instantMode ?? this.instantMode,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    musicEnabled: musicEnabled ?? this.musicEnabled,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    masterVolume: masterVolume ?? this.masterVolume,
    musicVolume: musicVolume ?? this.musicVolume,
    sfxVolume: sfxVolume ?? this.sfxVolume,
    debugOverlay: debugOverlay ?? this.debugOverlay,
    locale: locale ?? this.locale,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'textSpeed': textSpeed,
    'typingSpeed': typingSpeed,
    'autoAdvance': autoAdvance,
    'autoAdvanceMs': autoAdvanceDelay.inMilliseconds,
    'skipSeen': skipSeen,
    'instant': instantMode,
    'reducedMotion': reducedMotion,
    'sound': soundEnabled,
    'music': musicEnabled,
    'haptics': hapticsEnabled,
    'master': masterVolume,
    'musicVolume': musicVolume,
    'sfxVolume': sfxVolume,
    'debug': debugOverlay,
    'locale': locale,
  };

  factory EngineSettings.fromJson(Map<String, dynamic> json) => EngineSettings(
    textSpeed: (json['textSpeed'] as num?)?.toDouble() ?? 1.0,
    typingSpeed: (json['typingSpeed'] as num?)?.toDouble() ?? 1.0,
    autoAdvance: json['autoAdvance'] as bool? ?? false,
    autoAdvanceDelay: Duration(
      milliseconds: (json['autoAdvanceMs'] as num?)?.toInt() ?? 1400,
    ),
    skipSeen: json['skipSeen'] as bool? ?? false,
    instantMode: json['instant'] as bool? ?? false,
    reducedMotion: json['reducedMotion'] as bool? ?? false,
    soundEnabled: json['sound'] as bool? ?? true,
    musicEnabled: json['music'] as bool? ?? true,
    hapticsEnabled: json['haptics'] as bool? ?? true,
    masterVolume: (json['master'] as num?)?.toDouble() ?? 1.0,
    musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.7,
    sfxVolume: (json['sfxVolume'] as num?)?.toDouble() ?? 0.9,
    debugOverlay: json['debug'] as bool? ?? false,
    locale: json['locale'] as String? ?? 'en',
  );
}
