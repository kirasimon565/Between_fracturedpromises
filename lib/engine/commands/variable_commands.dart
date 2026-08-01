import '../events/engine_event.dart';
import '../state/relationships.dart';
import '../variables/engine_value.dart';
import 'command.dart';

/// Flags, ad-hoc variables, randomness and relationship axes.
List<CommandHandler> variableCommands() => <CommandHandler>[
      FunctionCommand(const <String>['flag'], _flag),
      FunctionCommand(
          const <String>['unset', 'unflag', 'clear_flag'], _unset),
      FunctionCommand(const <String>['toggle'], _toggle),
      FunctionCommand(
          const <String>['unset_var', 'delete_var'], _unsetVariable),
      FunctionCommand(const <String>['random'], _random),
      FunctionCommand(const <String>['random_pick'], _randomPick),
      FunctionCommand(const <String>['seed'], _seed),
    ];

List<CommandHandler> relationshipCommands() => <CommandHandler>[
      FunctionCommand(const <String>['trust'],
          (CommandContext ctx) => _axis(ctx, RelationshipAxis.trust)),
      FunctionCommand(const <String>['friendship'],
          (CommandContext ctx) => _axis(ctx, RelationshipAxis.friendship)),
      FunctionCommand(const <String>['love'],
          (CommandContext ctx) => _axis(ctx, RelationshipAxis.love)),
      FunctionCommand(const <String>['tension'],
          (CommandContext ctx) => _axis(ctx, RelationshipAxis.tension)),
      FunctionCommand(const <String>['suspicion'],
          (CommandContext ctx) => _axis(ctx, RelationshipAxis.suspicion)),
      FunctionCommand(const <String>['relationship'], _relationship),
    ];

CommandOutcome _flag(CommandContext ctx) {
  final String name = ctx.id(0);
  if (name.isEmpty) return CommandOutcome.next;
  final bool value = ctx.count > 1 ? ctx.flag(1) : true;
  ctx.engine.state.setFlag(name, value: value);
  ctx.engine.emitEvent(EngineEvents.flagSet,
      data: <String, Object?>{'flag': name, 'value': value});
  return CommandOutcome.next;
}

CommandOutcome _unset(CommandContext ctx) {
  final String name = ctx.id(0);
  if (name.isEmpty) return CommandOutcome.next;
  ctx.engine.state.setFlag(name, value: false);
  ctx.engine.emitEvent(EngineEvents.flagSet,
      data: <String, Object?>{'flag': name, 'value': false});
  return CommandOutcome.next;
}

CommandOutcome _toggle(CommandContext ctx) {
  final String name = ctx.id(0);
  if (name.isEmpty) return CommandOutcome.next;
  ctx.engine.state.toggleFlag(name);
  return CommandOutcome.next;
}

CommandOutcome _unsetVariable(CommandContext ctx) {
  final String name = ctx.id(0);
  if (name.isEmpty) return CommandOutcome.next;
  ctx.engine.variables.remove(name);
  return CommandOutcome.next;
}

/// `@random into luck min 1 max 6` or `@random luck 1 6`.
CommandOutcome _random(CommandContext ctx) {
  final String target = ctx.namedStr('into', ctx.id(0, 'random_value'));
  final int min = ctx.has('min') ? ctx.namedInt('min') : ctx.integer(1, 0);
  final int max = ctx.has('max') ? ctx.namedInt('max', 100) : ctx.integer(2, 100);
  final int value = ctx.engine.random.between(min, max);
  ctx.engine.variables.set(target, value);
  return CommandOutcome.next;
}

/// `@random_pick into mood ["calm" "angry" "sad"]`
CommandOutcome _randomPick(CommandContext ctx) {
  final String target = ctx.namedStr('into', 'picked_value');
  final List<EngineValue> pool = <EngineValue>[];
  for (int i = 0; i < ctx.count; i++) {
    final EngineValue value = ctx.value(i);
    if (value.isList) {
      pool.addAll(value.asList);
    } else {
      pool.add(value);
    }
  }
  if (pool.isEmpty) return CommandOutcome.next;
  final EngineValue picked = pool[ctx.engine.random.between(0, pool.length - 1)];
  ctx.engine.variables.set(target, picked.raw);
  return CommandOutcome.next;
}

CommandOutcome _seed(CommandContext ctx) {
  ctx.engine.random.seed = ctx.integer(0, 1);
  return CommandOutcome.next;
}

/// `@trust daniel +5` / `@trust daniel 20 max 80`
CommandOutcome _axis(CommandContext ctx, RelationshipAxis axis) {
  final String character = ctx.id(0);
  if (character.isEmpty) return CommandOutcome.next;

  final num min = ctx.has('min') ? ctx.namedNum('min') : Relationship.min;
  final num max = ctx.has('max') ? ctx.namedNum('max') : Relationship.max;

  // A leading `=` in the script means "set", otherwise it is a delta.
  final String raw = ctx.arguments.raw;
  final bool absolute = raw.contains('=');
  final num amount = ctx.number(1, 0);

  final num result = ctx.engine.state.adjustRelationship(
    character,
    axis,
    amount,
    absolute: absolute,
    min: min,
    max: max,
  );

  ctx.engine.emitEvent(EngineEvents.relationshipChanged,
      data: <String, Object?>{
        'character': character,
        'axis': axis.name,
        'value': result,
      });
  return CommandOutcome.next;
}

/// `@relationship daniel trust 10 love 4`
CommandOutcome _relationship(CommandContext ctx) {
  final String character = ctx.id(0);
  if (character.isEmpty) return CommandOutcome.next;
  for (final RelationshipAxis axis in RelationshipAxis.values) {
    if (!ctx.has(axis.name)) continue;
    ctx.engine.state.adjustRelationship(
      character,
      axis,
      ctx.namedNum(axis.name),
      absolute: true,
    );
  }
  return CommandOutcome.next;
}
