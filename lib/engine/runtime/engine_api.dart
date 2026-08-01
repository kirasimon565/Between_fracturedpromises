import '../events/engine_event.dart';
import '../parser/expression.dart';
import '../scheduler/engine_clock.dart';
import '../scheduler/scheduler.dart';
import '../state/game_state.dart';
import '../variables/engine_value.dart';
import '../variables/expression_scope.dart';
import '../variables/variable_store.dart';
import 'deterministic_random.dart';
import 'engine_effect.dart';
import 'engine_settings.dart';
import 'program.dart';

/// The surface a command handler is allowed to touch.
///
/// Commands never see the interpreter loop itself — they mutate state, emit
/// effects/events and return a [CommandOutcome]. That keeps the ~150 built-in
/// commands trivially unit-testable and lets plugins add new ones safely.
abstract class EngineApi {
  GameState get state;

  VariableStore get variables;

  EngineScheduler get scheduler;

  EventBus get events;

  DeterministicRandom get random;

  EngineClock get clock;

  ExpressionScope get scope;

  EngineSettings get settings;

  Program get program;

  String get episodeId;

  /// Address currently being executed.
  int get programCounter;

  /// Nearest label for the current address.
  String get currentLabel;

  void emitEffect(EngineEffect effect);

  void emitEvent(String name, {Map<String, Object?> data});

  int? resolveLabel(String label);

  /// Runs a label later, on a background fiber (`@schedule`).
  void scheduleLabel(
    String label,
    Duration delay, {
    String? id,
    Duration? repeat,
  });

  void cancelScheduled(String id);

  /// Requests an autosave; the host app decides how to persist it.
  void requestCheckpoint({String? name});

  void log(String message, {String level});

  EngineValue evaluate(Expression? expression);

  /// Evaluates an expression to a string, applying interpolation.
  String text(Expression? expression, [String fallback = '']);

  /// Applies the player's reading-speed preferences to a story duration.
  Duration pace(Duration duration);
}
