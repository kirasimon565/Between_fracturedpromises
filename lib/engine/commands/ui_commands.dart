import '../runtime/engine_effect.dart';
import 'command.dart';

/// Presentation-layer commands: overlays, dialogs, title cards and the
/// animation family (`@shake`, `@glitch`, `@flash`, …).
List<CommandHandler> uiCommands() => <CommandHandler>[
      const FunctionCommand(<String>['ui'], _ui),
      const FunctionCommand(<String>['toast'], _toast),
      const FunctionCommand(<String>['banner'], _banner),
      const FunctionCommand(<String>['overlay'], _overlay),
      const FunctionCommand(<String>['screen'], _screen),
      const FunctionCommand(<String>['dialog'], _dialog),
      const FunctionCommand(<String>['hud'], _hud),
      const FunctionCommand(<String>['title_card'], _titleCard),
      const FunctionCommand(<String>['credits'], _credits),
    ];

List<CommandHandler> animationCommands() => <CommandHandler>[
      const FunctionCommand(<String>['animate'], _animate),
      const FunctionCommand(<String>['shake'], _shake),
      const FunctionCommand(<String>['flash'], _flash),
      const FunctionCommand(<String>['glitch'], _glitch),
      const FunctionCommand(<String>['fade'], _fade),
      const FunctionCommand(<String>['shatter'], _shatter),
    ];


CommandOutcome _shake(CommandContext ctx) => _screenEffect(ctx, 'shake');

CommandOutcome _flash(CommandContext ctx) => _screenEffect(ctx, 'flash');

CommandOutcome _glitch(CommandContext ctx) => _screenEffect(ctx, 'glitch');

CommandOutcome _fade(CommandContext ctx) => _screenEffect(ctx, 'fade');

CommandOutcome _ui(CommandContext ctx) {
  ctx.engine.emitEffect(GenericEffect('ui', <String, Object?>{
    'mode': ctx.str(0, ctx.namedStr('mode')),
    'value': ctx.namedStr('value', ctx.str(1)),
  }));
  return CommandOutcome.next;
}

CommandOutcome _toast(CommandContext ctx) {
  ctx.engine.emitEffect(ToastEffect(
    ctx.str(0),
    icon: ctx.namedStrOrNull('icon'),
    duration: ctx.namedDuration('duration', const Duration(seconds: 2)),
  ));
  return CommandOutcome.next;
}

CommandOutcome _banner(CommandContext ctx) {
  ctx.engine.emitEffect(BannerEffect(
    ctx.str(0),
    style: ctx.namedStr('style', 'info'),
    duration: ctx.namedDuration('duration', const Duration(seconds: 3)),
  ));
  return CommandOutcome.next;
}

CommandOutcome _overlay(CommandContext ctx) {
  ctx.engine.emitEffect(GenericEffect('overlay', <String, Object?>{
    'mode': ctx.str(0, 'show'),
    'opacity': ctx.namedNum('opacity', 0.6),
    'color': ctx.namedStr('color', '#000000'),
  }));
  return CommandOutcome.next;
}

CommandOutcome _screen(CommandContext ctx) {
  ctx.engine.emitEffect(NavigateEffect(
    ctx.str(0),
    arguments: <String, Object?>{'args': ctx.namedStr('args')},
  ));
  return CommandOutcome.next;
}

CommandOutcome _dialog(CommandContext ctx) {
  ctx.engine.emitEffect(DialogEffect(
    title: ctx.namedStr('title', ctx.str(0)),
    body: ctx.namedStr('body', ctx.str(1)),
    confirmLabel: ctx.namedStr('confirm', 'OK'),
    cancelLabel: ctx.namedStrOrNull('cancel'),
  ));
  return CommandOutcome.next;
}

CommandOutcome _hud(CommandContext ctx) {
  ctx.engine.emitEffect(GenericEffect('hud', <String, Object?>{
    'show': ctx.namedStr('show', ctx.str(0)),
    'hide': ctx.namedStr('hide'),
  }));
  return CommandOutcome.next;
}

CommandOutcome _titleCard(CommandContext ctx) {
  final Duration duration =
      ctx.namedDuration('duration', const Duration(seconds: 3));
  ctx.engine.emitEffect(TitleCardEffect(
    title: ctx.str(0),
    subtitle: ctx.namedStrOrNull('subtitle'),
    duration: duration,
    style: ctx.namedStr('style', 'default'),
  ));
  return CommandOutcome.wait(ctx.engine.pace(duration));
}

CommandOutcome _credits(CommandContext ctx) {
  ctx.engine.emitEffect(const NavigateEffect('/credits'));
  return CommandOutcome.next;
}

CommandOutcome _animate(CommandContext ctx) {
  ctx.engine.emitEffect(GenericEffect('animate', <String, Object?>{
    'name': ctx.str(0),
    'target': ctx.namedStr('target', 'screen'),
    'durationMs': ctx
        .namedDuration('duration', const Duration(milliseconds: 600))
        .inMilliseconds,
    'curve': ctx.namedStr('curve', 'easeOut'),
    'value': ctx.namedNum('value', 1),
  }));
  return CommandOutcome.next;
}

CommandOutcome _screenEffect(CommandContext ctx, String effect) {
  final Duration duration = ctx.namedDuration(
      'duration',
      effect == 'fade'
          ? const Duration(milliseconds: 900)
          : const Duration(milliseconds: 600));
  if (ctx.engine.settings.reducedMotion && effect != 'fade') {
    return CommandOutcome.next;
  }
  ctx.engine.emitEffect(ScreenEffect(
    effect: effect,
    duration: duration,
    intensity: ctx.namedNum('intensity', ctx.number(0, 1)).toDouble(),
    color: _parseColor(ctx.namedStr('color')),
  ));
  return CommandOutcome.next;
}

CommandOutcome _shatter(CommandContext ctx) {
  final Duration duration =
      ctx.namedDuration('duration', const Duration(milliseconds: 1200));
  ctx.engine.emitEffect(
      ScreenEffect(effect: 'shatter', duration: duration));
  ctx.engine.emitEffect(const PlaySoundEffect('glass_shatter'));
  return CommandOutcome.wait(ctx.engine.pace(duration));
}

int? _parseColor(String value) {
  if (value.isEmpty) return null;
  final String hex = value.replaceAll('#', '');
  if (hex.length == 6) return int.tryParse('FF$hex', radix: 16);
  if (hex.length == 8) return int.tryParse(hex, radix: 16);
  return null;
}
