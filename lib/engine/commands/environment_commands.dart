import '../runtime/engine_effect.dart';
import '../state/phone.dart';
import 'command.dart';
import 'command_helpers.dart';

/// Scene framing, in-fiction clock, weather, theme and network conditions.
List<CommandHandler> environmentCommands() => <CommandHandler>[
  const FunctionCommand(<String>['scene'], _scene),
  const FunctionCommand(<String>['time', 'clock'], _time),
  const FunctionCommand(<String>['date'], _date),
  const FunctionCommand(<String>['location'], _location),
  const FunctionCommand(<String>['weather'], _weather),
  const FunctionCommand(<String>['theme'], _theme),
  const FunctionCommand(<String>['advance_time'], _advanceTime),
  const FunctionCommand(<String>['network'], _network),
  const FunctionCommand(<String>['airplane_mode'], _airplane),
  const FunctionCommand(<String>['wifi'], _wifi),
  const FunctionCommand(<String>['sync_fail'], _syncFail),
];

CommandOutcome _scene(CommandContext ctx) {
  final String scene = ctx.id(0);
  if (scene.isEmpty) return CommandOutcome.next;

  final String app = ctx.namedStr(
    'app',
    CommandContextHelpers.appForScene(scene),
  );
  final String theme = ctx.namedStr(
    'theme',
    app == 'makelove' ? 'secret' : 'safe',
  );

  ctx.engine.state.setScene(
    scene: scene,
    background: ctx.namedStrOrNull('background'),
    theme: theme,
  );
  ctx.engine.state.updatePhone(
    (PhoneState p) => p.copyWith(currentApp: app, locked: false),
  );
  ctx.engine.emitEffect(OpenAppEffect(app, screen: scene));

  final String? music = ctx.namedStrOrNull('music');
  if (music != null) {
    ctx.engine.state.musicTrack = music;
    ctx.engine.emitEffect(MusicEffect(track: music));
  }
  return CommandOutcome.next;
}

CommandOutcome _time(CommandContext ctx) {
  final String clock = ctx.str(0);
  if (clock.isEmpty) return CommandOutcome.next;
  ctx.engine.state.updatePhone((PhoneState p) => p.copyWith(clock: clock));
  return CommandOutcome.next;
}

CommandOutcome _date(CommandContext ctx) {
  ctx.engine.state.updatePhone((PhoneState p) => p.copyWith(date: ctx.str(0)));
  return CommandOutcome.next;
}

CommandOutcome _location(CommandContext ctx) {
  ctx.engine.state.updatePhone(
    (PhoneState p) => p.copyWith(location: ctx.str(0)),
  );
  return CommandOutcome.next;
}

CommandOutcome _weather(CommandContext ctx) {
  ctx.engine.state.updatePhone(
    (PhoneState p) => p.copyWith(weather: ctx.str(0)),
  );
  return CommandOutcome.next;
}

CommandOutcome _theme(CommandContext ctx) {
  final String theme = ctx.str(0, ctx.namedStr('mode', 'safe'));
  ctx.engine.state.setScene(theme: theme);
  ctx.engine.emitEffect(
    GenericEffect('theme', <String, Object?>{'theme': theme}),
  );
  return CommandOutcome.next;
}

/// Moves the in-fiction clock forward.
CommandOutcome _advanceTime(CommandContext ctx) {
  final int minutes =
      ctx.namedInt('minutes', ctx.integer(0, 0)) + ctx.namedInt('hours') * 60;
  if (minutes == 0) return CommandOutcome.next;

  final List<String> parts = ctx.engine.state.phone.clock.split(':');
  int hh = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
  int mm = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  mm += minutes;
  hh = (hh + mm ~/ 60) % 24;
  mm = mm % 60;
  final String clock =
      '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
  ctx.engine.state.updatePhone((PhoneState p) => p.copyWith(clock: clock));
  return CommandOutcome.next;
}

CommandOutcome _network(CommandContext ctx) {
  final String state = ctx.str(0, ctx.namedStr('state', 'online'));
  ctx.engine.state.updatePhone(
    (PhoneState p) => p.copyWith(
      networkState: state,
      signal: ctx.namedInt('strength', p.signal),
    ),
  );
  return CommandOutcome.next;
}

CommandOutcome _airplane(CommandContext ctx) {
  final bool on = ctx.flag(0);
  ctx.engine.state.updatePhone(
    (PhoneState p) => p.copyWith(
      airplaneMode: on,
      networkState: on ? 'offline' : 'online',
      signal: on ? 0 : 4,
      wifi: on ? false : p.wifi,
    ),
  );
  return CommandOutcome.next;
}

CommandOutcome _wifi(CommandContext ctx) {
  ctx.engine.state.updatePhone(
    (PhoneState p) => p.copyWith(
      wifi: ctx.flag(0),
      signal: ctx.namedInt('strength', p.signal),
    ),
  );
  return CommandOutcome.next;
}

CommandOutcome _syncFail(CommandContext ctx) {
  ctx.engine.emitEffect(
    const BannerEffect('Sync failed. Check your connection.', style: 'error'),
  );
  ctx.engine.state.updatePhone(
    (PhoneState p) => p.copyWith(networkState: 'unstable'),
  );
  return CommandOutcome.next;
}
