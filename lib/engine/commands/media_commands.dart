import '../runtime/engine_effect.dart';
import 'command.dart';

/// Images, backgrounds, music, sound effects and haptics.
List<CommandHandler> mediaCommands() => <CommandHandler>[
      const FunctionCommand(
          <String>['image', 'show_image', 'photo'], _image),
      const FunctionCommand(<String>['hide_image'], _hideImage),
      const FunctionCommand(<String>['background', 'bg'], _background),
      const FunctionCommand(<String>['video'], _video),
      const FunctionCommand(<String>['music'], _music),
      const FunctionCommand(<String>['stop_music'], _stopMusic),
      const FunctionCommand(<String>['sound', 'sfx', 'play'], _sound),
      const FunctionCommand(<String>['ambience'], _ambience),
      const FunctionCommand(<String>['vibrate'], _vibrate),
      const FunctionCommand(<String>['mute'], _mute),
      const FunctionCommand(<String>['unmute'], _unmute),
    ];

CommandOutcome _image(CommandContext ctx) {
  final String asset = ctx.str(0);
  if (asset.isEmpty) return CommandOutcome.next;
  final Duration? dwell = ctx.has('duration')
      ? ctx.namedDuration('duration', const Duration(seconds: 3))
      : null;
  ctx.engine.emitEffect(ShowImageEffect(
    asset: asset,
    caption: ctx.namedStrOrNull('caption'),
    duration: dwell,
    blur: ctx.namedNum('blur').toDouble(),
  ));
  return dwell == null ? CommandOutcome.next : CommandOutcome.wait(dwell);
}

CommandOutcome _hideImage(CommandContext ctx) {
  ctx.engine.emitEffect(const HideImageEffect());
  return CommandOutcome.next;
}

CommandOutcome _background(CommandContext ctx) {
  final String asset = ctx.str(0);
  ctx.engine.state.setScene(background: asset);
  ctx.engine.emitEffect(GenericEffect('background', <String, Object?>{
    'asset': asset,
    'fade': ctx.namedNum('fade', 0.4),
    'blur': ctx.namedNum('blur'),
  }));
  return CommandOutcome.next;
}

CommandOutcome _video(CommandContext ctx) {
  ctx.engine.emitEffect(GenericEffect('video', <String, Object?>{
    'asset': ctx.str(0),
    'loop': ctx.namedBool('loop'),
    'mute': ctx.namedBool('mute'),
  }));
  return CommandOutcome.next;
}

CommandOutcome _music(CommandContext ctx) {
  final String track = ctx.str(0);
  final double volume = ctx.namedNum('volume', 0.6).toDouble();
  ctx.engine.state.musicTrack = track;
  ctx.engine.state.musicVolume = volume;
  ctx.engine.emitEffect(MusicEffect(
    track: track,
    volume: volume,
    loop: ctx.namedBool('loop', true),
    fade: ctx.namedDuration('fade', const Duration(milliseconds: 800)),
  ));
  return CommandOutcome.next;
}

CommandOutcome _stopMusic(CommandContext ctx) {
  ctx.engine.state.musicTrack = null;
  ctx.engine.emitEffect(MusicEffect(
    stop: true,
    fade: ctx.namedDuration('fade', const Duration(milliseconds: 600)),
  ));
  return CommandOutcome.next;
}

CommandOutcome _sound(CommandContext ctx) {
  final String asset = ctx.str(0);
  if (asset.isEmpty) return CommandOutcome.next;
  ctx.engine.emitEffect(
      PlaySoundEffect(asset, volume: ctx.namedNum('volume', 1).toDouble()));
  return CommandOutcome.next;
}

CommandOutcome _ambience(CommandContext ctx) {
  ctx.engine.emitEffect(AmbienceEffect(
    ctx.str(0),
    volume: ctx.namedNum('volume', 0.4).toDouble(),
    stop: ctx.str(0).isEmpty || ctx.str(0) == 'none',
  ));
  return CommandOutcome.next;
}

CommandOutcome _vibrate(CommandContext ctx) {
  ctx.engine.emitEffect(VibrateEffect(
    milliseconds: ctx.has('duration')
        ? ctx.namedDuration('duration', const Duration(milliseconds: 150))
            .inMilliseconds
        : ctx.integer(0, 150),
    pattern: ctx.namedStrOrNull('pattern'),
  ));
  return CommandOutcome.next;
}

CommandOutcome _mute(CommandContext ctx) {
  ctx.engine.state.updatePhone((phone) => phone.copyWith(silent: true));
  ctx.engine.emitEffect(const MusicEffect(stop: true));
  return CommandOutcome.next;
}

CommandOutcome _unmute(CommandContext ctx) {
  ctx.engine.state.updatePhone((phone) => phone.copyWith(silent: false));
  return CommandOutcome.next;
}
