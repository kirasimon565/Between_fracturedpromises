import '../runtime/engine_effect.dart';
import 'command.dart';

/// Metadata, save/checkpoint and developer tooling.
List<CommandHandler> metaCommands() => <CommandHandler>[
  const FunctionCommand(<String>[
    'title',
    'episode',
    'chapter',
    'author',
    'difficulty',
    'version',
    'tags',
    'synopsis',
    'cover',
    'requires_episode',
  ], _metadata),
  const FunctionCommand(<String>['include'], _include),
  const FunctionCommand(<String>['checkpoint'], _checkpoint),
  const FunctionCommand(<String>['save'], _save),
  const FunctionCommand(<String>['debug'], _debug),
  const FunctionCommand(<String>['log'], _log),
  const FunctionCommand(<String>['assert'], _assert),
  const FunctionCommand(<String>['breakpoint'], _breakpoint),
  const FunctionCommand(<String>['trace'], _trace),
  const FunctionCommand(<String>['plugin'], _plugin),
  const FunctionCommand(<String>['use'], _use),
];

CommandOutcome _metadata(CommandContext ctx) {
  // Metadata is captured by the parser; storing it as a variable lets the
  // script (and the UI) read it back, e.g. `{title}`.
  ctx.engine.variables.set('meta_${ctx.name}', ctx.value(0).raw);
  return CommandOutcome.next;
}

/// Includes are inlined by the loader; reaching one at runtime is a no-op.
CommandOutcome _include(CommandContext ctx) => CommandOutcome.next;

/// `@plugin <name> action "..."` — forwards to a plugin registered through
/// `createCommandRegistry(plugins: ...)`.
///
/// A plugin that registers a handler under its own name shadows this fallback,
/// so reaching *here* means the script asked for a plugin the build does not
/// ship. That is a script problem, not a crash: it is logged and skipped.
CommandOutcome _plugin(CommandContext ctx) {
  final String name = ctx.id(0);
  final String action = ctx.namedStr('action');
  final String suffix = action.isEmpty ? '' : ' (action: $action)';
  ctx.engine.log(
    'No plugin named "$name" is registered$suffix — skipped.',
    level: 'warning',
  );
  return CommandOutcome.next;
}

/// `@use <plugin>` — a declaration the loader reads; harmless at runtime.
CommandOutcome _use(CommandContext ctx) {
  ctx.engine.variables.set('plugin_${ctx.id(0)}', true);
  return CommandOutcome.next;
}

CommandOutcome _checkpoint(CommandContext ctx) {
  ctx.engine.requestCheckpoint(
    name: ctx.namedStrOrNull('name') ?? (ctx.count > 0 ? ctx.str(0) : null),
  );
  return CommandOutcome.next;
}

CommandOutcome _save(CommandContext ctx) {
  ctx.engine.requestCheckpoint(name: ctx.count > 0 ? ctx.str(0) : 'manual');
  return CommandOutcome.next;
}

CommandOutcome _debug(CommandContext ctx) {
  ctx.engine.log(
    ctx.arguments.raw.isEmpty ? ctx.str(0) : ctx.arguments.raw,
    level: ctx.namedStr('level', 'debug'),
  );
  return CommandOutcome.next;
}

CommandOutcome _log(CommandContext ctx) {
  ctx.engine.log(ctx.str(0, ctx.arguments.raw));
  return CommandOutcome.next;
}

CommandOutcome _assert(CommandContext ctx) {
  final bool ok = ctx.flag(0, false);
  if (ok) return CommandOutcome.next;
  final String message = ctx.namedStr(
    'message',
    'Assertion failed at ${ctx.span}',
  );
  ctx.engine.log(message, level: 'error');
  ctx.engine.emitEffect(DebugEffect(message, level: 'error'));
  return CommandOutcome.next;
}

CommandOutcome _breakpoint(CommandContext ctx) {
  ctx.engine.log(
    'Breakpoint at ${ctx.span} (${ctx.engine.currentLabel})',
    level: 'warning',
  );
  return CommandOutcome.next;
}

CommandOutcome _trace(CommandContext ctx) {
  ctx.engine.log(
    'trace pc=${ctx.engine.programCounter} label=${ctx.engine.currentLabel} '
    'flags=${ctx.engine.state.flags.length} '
    'crystals=${ctx.engine.state.wallet.crystals}',
  );
  return CommandOutcome.next;
}
