import '../state/progress.dart';

/// One-shot, non-persistent instructions for the presentation layer.
///
/// Anything that must survive a save lives in `GameState`; anything that is a
/// momentary flourish (a sound, a shake, a toast) is an [EngineEffect].
abstract class EngineEffect {
  const EngineEffect();

  String get kind;
}

class PlaySoundEffect extends EngineEffect {
  const PlaySoundEffect(this.asset, {this.volume = 1.0});

  final String asset;
  final double volume;

  @override
  String get kind => 'sound';
}

class MusicEffect extends EngineEffect {
  const MusicEffect({
    this.track,
    this.volume = 0.6,
    this.fade = const Duration(milliseconds: 600),
    this.loop = true,
    this.stop = false,
  });

  final String? track;
  final double volume;
  final Duration fade;
  final bool loop;
  final bool stop;

  @override
  String get kind => 'music';
}

class AmbienceEffect extends EngineEffect {
  const AmbienceEffect(this.track, {this.volume = 0.4, this.stop = false});

  final String? track;
  final double volume;
  final bool stop;

  @override
  String get kind => 'ambience';
}

class VibrateEffect extends EngineEffect {
  const VibrateEffect({this.milliseconds = 120, this.pattern});

  final int milliseconds;
  final String? pattern;

  @override
  String get kind => 'vibrate';
}

/// Screen-wide visual flourishes: shake / glitch / flash / fade / shatter.
class ScreenEffect extends EngineEffect {
  const ScreenEffect({
    required this.effect,
    this.duration = const Duration(milliseconds: 600),
    this.intensity = 1.0,
    this.color,
  });

  final String effect;
  final Duration duration;
  final double intensity;
  final int? color;

  @override
  String get kind => 'screen';
}

class ToastEffect extends EngineEffect {
  const ToastEffect(
    this.text, {
    this.icon,
    this.duration = const Duration(seconds: 2),
  });

  final String text;
  final String? icon;
  final Duration duration;

  @override
  String get kind => 'toast';
}

class BannerEffect extends EngineEffect {
  const BannerEffect(
    this.text, {
    this.style = 'info',
    this.duration = const Duration(seconds: 3),
  });

  final String text;
  final String style;
  final Duration duration;

  @override
  String get kind => 'banner';
}

class DialogEffect extends EngineEffect {
  const DialogEffect({
    required this.title,
    required this.body,
    this.confirmLabel = 'OK',
    this.cancelLabel,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final String? cancelLabel;

  @override
  String get kind => 'dialog';
}

class TitleCardEffect extends EngineEffect {
  const TitleCardEffect({
    required this.title,
    this.subtitle,
    this.duration = const Duration(seconds: 3),
    this.style = 'default',
  });

  final String title;
  final String? subtitle;
  final Duration duration;
  final String style;

  @override
  String get kind => 'title_card';
}

class ShowImageEffect extends EngineEffect {
  const ShowImageEffect({
    required this.asset,
    this.caption,
    this.duration,
    this.fullscreen = true,
    this.blur = 0,
  });

  final String asset;
  final String? caption;
  final Duration? duration;
  final bool fullscreen;
  final double blur;

  @override
  String get kind => 'image';
}

class HideImageEffect extends EngineEffect {
  const HideImageEffect();

  @override
  String get kind => 'hide_image';
}

/// Asks the shell to move to another screen / app.
class NavigateEffect extends EngineEffect {
  const NavigateEffect(this.route, {this.arguments});

  final String route;
  final Map<String, Object?>? arguments;

  @override
  String get kind => 'navigate';
}

class OpenAppEffect extends EngineEffect {
  const OpenAppEffect(this.appId, {this.screen, this.arguments});

  final String appId;
  final String? screen;
  final Map<String, Object?>? arguments;

  @override
  String get kind => 'open_app';
}

class AppInstallEffect extends EngineEffect {
  const AppInstallEffect({
    required this.appId,
    required this.name,
    this.icon,
    this.duration = const Duration(seconds: 3),
    this.source = 'browser',
  });

  final String appId;
  final String name;
  final String? icon;
  final Duration duration;
  final String source;

  @override
  String get kind => 'app_install';
}

class AchievementEffect extends EngineEffect {
  const AchievementEffect(this.achievement);

  final Achievement achievement;

  @override
  String get kind => 'achievement';
}

class GalleryEffect extends EngineEffect {
  const GalleryEffect(this.item);

  final GalleryUnlock item;

  @override
  String get kind => 'gallery';
}

class CheckpointEffect extends EngineEffect {
  const CheckpointEffect({this.name, this.auto = true});

  final String? name;
  final bool auto;

  @override
  String get kind => 'checkpoint';
}

class StoreEffect extends EngineEffect {
  const StoreEffect({this.sku, this.reason, this.requiredCrystals = 0});

  final String? sku;
  final String? reason;
  final int requiredCrystals;

  @override
  String get kind => 'store';
}

class EpisodeCompleteEffect extends EngineEffect {
  const EpisodeCompleteEffect(this.episodeId, {this.reason});

  final String episodeId;
  final String? reason;

  @override
  String get kind => 'episode_complete';
}

class DebugEffect extends EngineEffect {
  const DebugEffect(this.message, {this.level = 'info'});

  final String message;
  final String level;

  @override
  String get kind => 'debug';
}

/// Escape hatch used by plugins and `@ui` so new presentation features do not
/// require changes to the engine.
class GenericEffect extends EngineEffect {
  const GenericEffect(this.name, [this.payload = const <String, Object?>{}]);

  final String name;
  final Map<String, Object?> payload;

  @override
  String get kind => name;
}
