import '../runtime/engine_effect.dart';
import 'command.dart';
import 'command_helpers.dart';

/// Event emission, background scheduling and runtime control.
///
/// These are what make the runtime *event driven* rather than a straight line:
/// a script can arm a timer, keep talking, and be interrupted later.
List<CommandHandler> eventCommands() => <CommandHandler>[
      FunctionCommand(const <String>['emit'], _emit),
      FunctionCommand(const <String>['schedule'], _schedule),
      FunctionCommand(const <String>['cancel_schedule'], _cancelSchedule),
      FunctionCommand(const <String>['timer'], _timer),
      FunctionCommand(const <String>['await'], _await),
      FunctionCommand(const <String>['async'], _async),
      FunctionCommand(const <String>['pause_engine'], _pauseEngine),
      FunctionCommand(const <String>['resume_engine'], _resumeEngine),
    ];

CommandOutcome _emit(CommandContext ctx) {
  final String name = ctx.id(0);
  if (name.isEmpty) return CommandOutcome.next;
  final Duration delay = ctx.namedDuration('delay', Duration.zero);
  final Map<String, Object?> data = <String, Object?>{
    'data': ctx.namedStr('data'),
    'source': 'script',
  };
  if (delay <= Duration.zero) {
    ctx.engine.emitEvent(name, data: data);
  } else {
    ctx.engine.scheduler
        .after(delay, () => ctx.engine.emitEvent(name, data: data),
            tag: 'story_event');
  }
  return CommandOutcome.next;
}

/// `@schedule @label in 30` — runs a label on a background fiber.
CommandOutcome _schedule(CommandContext ctx) {
  final String label = ctx.str(0);
  if (label.isEmpty) return CommandOutcome.next;
  final Duration delay = ctx.has('in')
      ? ctx.namedDuration('in', const Duration(seconds: 5))
      : ctx.namedDuration('at', const Duration(seconds: 5));
  final Duration? repeat =
      ctx.has('repeat') ? ctx.namedDuration('repeat', Duration.zero) : null;
  ctx.engine.scheduleLabel(
    label,
    delay,
    id: ctx.namedStrOrNull('id'),
    repeat: repeat == null || repeat <= Duration.zero ? null : repeat,
  );
  return CommandOutcome.next;
}

CommandOutcome _cancelSchedule(CommandContext ctx) {
  ctx.engine.cancelScheduled(ctx.str(0));
  return CommandOutcome.next;
}

/// A visible countdown the UI can render (`@timer seconds 30 label "Reply"`).
CommandOutcome _timer(CommandContext ctx) {
  final Duration duration = ctx.has('seconds')
      ? Duration(milliseconds: (ctx.namedNum('seconds') * 1000).round())
      : Duration(milliseconds: (ctx.number(0, 10) * 1000).round());
  final String id = ctx.namedStr('id', ctx.uid('timer'));
  ctx.engine.emitEffect(GenericEffect('timer', <String, Object?>{
    'id': id,
    'durationMs': duration.inMilliseconds,
    'label': ctx.namedStr('label'),
    'visible': ctx.namedBool('visible', true),
  }));
  ctx.engine.scheduler.after(
    duration,
    () => ctx.engine.emitEvent('timer_$id'),
    id: id,
    tag: 'story_schedule',
  );
  return CommandOutcome.next;
}

/// Blocks until an event arrives (with an optional timeout).
CommandOutcome _await(CommandContext ctx) {
  final String signal = ctx.id(0);
  if (signal.isEmpty) return CommandOutcome.next;
  final Duration? timeout =
      ctx.has('timeout') ? ctx.namedDuration('timeout', Duration.zero) : null;
  return CommandOutcome.waitFor(signal, timeout: timeout);
}

/// Fire-and-forget execution of a label.
CommandOutcome _async(CommandContext ctx) {
  final String label = ctx.str(0);
  if (label.isEmpty) return CommandOutcome.next;
  ctx.engine.scheduleLabel(label, const Duration(milliseconds: 1));
  return CommandOutcome.next;
}

CommandOutcome _pauseEngine(CommandContext ctx) {
  ctx.engine.scheduler.pause();
  return CommandOutcome.next;
}

CommandOutcome _resumeEngine(CommandContext ctx) {
  ctx.engine.scheduler.resume();
  return CommandOutcome.next;
}
