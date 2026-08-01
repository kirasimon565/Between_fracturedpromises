import '../state/game_state.dart';
import '../state/relationships.dart';
import '../variables/engine_value.dart';
import '../variables/expression_scope.dart';
import 'deterministic_random.dart';

/// Resolves identifiers and built-in functions for every expression the script
/// evaluates.
///
/// Name resolution order: variables → engine built-ins → relationships →
/// flags → null.
class ScriptScope implements ExpressionScope {
  ScriptScope({required this.state, required this.random});

  final GameState state;
  final DeterministicRandom random;

  @override
  EngineValue lookup(String name) => state.lookup(name);

  @override
  EngineValue callFunction(String name, List<EngineValue> arguments) {
    EngineValue arg(int index) =>
        index < arguments.length ? arguments[index] : EngineValue.nullValue;

    switch (name.toLowerCase()) {
      // ── Randomness ──────────────────────────────────────────────────────
      case 'random':
        if (arguments.isEmpty) return EngineValue.number(random.nextDouble());
        if (arguments.length == 1) {
          return EngineValue.number(random.between(0, arg(0).asInt));
        }
        return EngineValue.number(random.between(arg(0).asInt, arg(1).asInt));
      case 'chance':
        return EngineValue.boolean(random.chance(arg(0).asNum));
      case 'pick':
        final List<EngineValue> pool = arguments.length == 1 && arg(0).isList
            ? arg(0).asList
            : arguments;
        if (pool.isEmpty) return EngineValue.nullValue;
        return pool[random.between(0, pool.length - 1)];

      // ── Math ────────────────────────────────────────────────────────────
      case 'min':
        return EngineValue.number(
          arg(0).asNum < arg(1).asNum ? arg(0).asNum : arg(1).asNum,
        );
      case 'max':
        return EngineValue.number(
          arg(0).asNum > arg(1).asNum ? arg(0).asNum : arg(1).asNum,
        );
      case 'abs':
        return EngineValue.number(arg(0).asNum.abs());
      case 'round':
        return EngineValue.number(arg(0).asNum.round());
      case 'floor':
        return EngineValue.number(arg(0).asNum.floor());
      case 'ceil':
        return EngineValue.number(arg(0).asNum.ceil());
      case 'clamp':
        final num value = arg(0).asNum;
        final num low = arg(1).asNum;
        final num high = arg(2).asNum;
        return EngineValue.number(
          value < low ? low : (value > high ? high : value),
        );

      // ── Strings & collections ───────────────────────────────────────────
      case 'len':
      case 'length':
        final EngineValue value = arg(0);
        if (value.isList) return EngineValue.number(value.asList.length);
        return EngineValue.number(value.asString.length);
      case 'at':
        final List<EngineValue> list = arg(0).asList;
        final int index = arg(1).asInt;
        if (index < 0 || index >= list.length) return EngineValue.nullValue;
        return list[index];
      case 'contains':
        if (arg(0).isList) {
          return EngineValue.boolean(
            arg(0).asList.any((EngineValue e) => e.looseEquals(arg(1))),
          );
        }
        return EngineValue.boolean(
          arg(0).asString.toLowerCase().contains(arg(1).asString.toLowerCase()),
        );
      case 'upper':
        return EngineValue.string(arg(0).asString.toUpperCase());
      case 'lower':
        return EngineValue.string(arg(0).asString.toLowerCase());
      case 'concat':
        return EngineValue.string(
          arguments.map((EngineValue v) => v.asString).join(),
        );

      // ── Story predicates ────────────────────────────────────────────────
      case 'has_flag':
        return EngineValue.boolean(state.hasFlag(arg(0).asString));
      case 'has_item':
        return EngineValue.boolean(state.hasItem(arg(0).asString));
      case 'has_evidence':
        return EngineValue.boolean(state.hasEvidence(arg(0).asString));
      case 'has_objective':
        return EngineValue.boolean(state.hasObjective(arg(0).asString));
      case 'has_achievement':
        return EngineValue.boolean(state.hasAchievement(arg(0).asString));
      case 'has_app':
        return EngineValue.boolean(state.phone.hasApp(arg(0).asString));
      case 'has_seen':
        return EngineValue.boolean(state.hasSeen(arg(0).asString));
      case 'has_visited':
        return EngineValue.boolean(state.hasVisited(arg(0).asString));
      case 'has_gallery':
        return EngineValue.boolean(state.hasGallery(arg(0).asString));
      case 'picked':
        return EngineValue.boolean(state.hasPicked(arg(0).asString));
      case 'owns':
        return EngineValue.boolean(state.wallet.ownsSku(arg(0).asString));
      case 'can_afford':
        return EngineValue.boolean(state.wallet.canAfford(arg(0).asInt));
      case 'unread':
        return EngineValue.number(state.phone.unreadNotifications);
      case 'item_count':
        return EngineValue.number(
          state.inventory[arg(0).asString.toLowerCase()]?.count ?? 0,
        );

      // ── Relationships ───────────────────────────────────────────────────
      case 'trust':
      case 'friendship':
      case 'love':
      case 'tension':
      case 'suspicion':
        final RelationshipAxis? axis = relationshipAxisFromName(name);
        if (axis == null) return EngineValue.zero;
        return EngineValue.number(
          state.relationship(arg(0).asString).axis(axis),
        );
      case 'bond':
        return EngineValue.string(
          state.relationship(arg(0).asString).bondLabel,
        );

      // ── Character helpers ───────────────────────────────────────────────
      case 'character_name':
        return EngineValue.string(
          state.character(arg(0).asString)?.name ?? arg(0).asString,
        );
      case 'is_online':
        return EngineValue.boolean(
          state.character(arg(0).asString)?.isOnline ?? false,
        );
    }

    return EngineValue.nullValue;
  }
}
