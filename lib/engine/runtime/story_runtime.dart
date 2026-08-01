import 'dart:async';

import '../commands/command.dart';
import '../diagnostics/diagnostic.dart';
import '../events/engine_event.dart';
import '../parser/ast.dart';
import '../parser/expression.dart';
import '../save/engine_snapshot.dart';
import '../scheduler/engine_clock.dart';
import '../scheduler/scheduler.dart';
import '../state/game_state.dart';
import '../state/relationships.dart';
import '../variables/engine_value.dart';
import '../variables/expression_scope.dart';
import '../variables/variable_store.dart';
import 'deterministic_random.dart';
import 'engine_api.dart';
import 'engine_effect.dart';
import 'engine_settings.dart';
import 'execution_context.dart';
import 'instruction.dart';
import 'pending_choice.dart';
import 'program.dart';
import 'runtime_status.dart';

/// The interpreter.
///
/// It walks the compiled [Program] one instruction at a time, hands commands to
/// the [CommandRegistry], and suspends itself whenever the story needs to wait
/// for time, an event, or the player. Nothing here knows about Flutter.
class StoryRuntime implements EngineApi {
  StoryRuntime({
    required this.registry,
    GameState? state,
    EngineClock? clock,
    EngineScheduler? scheduler,
    EventBus? events,
    DeterministicRandom? random,
    EngineSettings settings = const EngineSettings(),
    this.onCheckpoint,
  })  : _state = state ?? GameState(),
        clock = clock ?? const SystemClock(),
        _scheduler =
            scheduler ?? EngineScheduler(clock: clock ?? const SystemClock()),
        events = events ?? EventBus(),
        random = random ?? DeterministicRandom(0x2545F491),
        _settings = settings {
    _scope = ScriptScope(state: _state, random: this.random);
  }

  final CommandRegistry registry;

  @override
  final EngineClock clock;

  @override
  final EventBus events;

  @override
  final DeterministicRandom random;

  /// Invoked whenever the story asks for an autosave.
  final Future<void> Function(String? name)? onCheckpoint;

  final GameState _state;
  final EngineScheduler _scheduler;
  EngineSettings _settings;
  late ScriptScope _scope;

  Program? _program;
  int _pc = 0;
  RuntimeStatus _status = RuntimeStatus.idle;
  final List<CallFrame> _callStack = <CallFrame>[];
  final List<EventHandlerRegistration> _handlers = <EventHandlerRegistration>[];
  final List<int> _pendingCalls = <int>[];
  final Map<String, _ScheduledLabel> _scheduledLabels =
      <String, _ScheduledLabel>{};

  PendingChoice? _pendingChoice;
  String? _awaitedSignal;
  StreamSubscription<EngineEvent>? _signalSubscription;

  /// Set when the awaited signal arrives while the runtime is paused.
  ///
  /// Without the latch the event would be dropped — the player backgrounds the
  /// app at the wrong millisecond and the story never continues.
  bool _signalLatched = false;
  String? _lastError;
  bool _looping = false;
  int _instructionBudget = 0;

  final StreamController<EngineEffect> _effects =
      StreamController<EngineEffect>.broadcast();
  final StreamController<RuntimeStatus> _statusChanges =
      StreamController<RuntimeStatus>.broadcast();
  final StreamController<PendingChoice?> _choiceChanges =
      StreamController<PendingChoice?>.broadcast();

  static const int _maxInstructionsPerTick = 400;
  static const int _runawayLimit = 500000;

  // ── Public surface ──────────────────────────────────────────────────────

  @override
  GameState get state => _state;

  @override
  VariableStore get variables => _state.variables;

  @override
  EngineScheduler get scheduler => _scheduler;

  @override
  ExpressionScope get scope => _scope;

  @override
  EngineSettings get settings => _settings;

  set settings(EngineSettings value) => _settings = value;

  @override
  Program get program => _program ?? _emptyProgram;

  @override
  String get episodeId => _state.episodeId;

  @override
  int get programCounter => _pc;

  @override
  String get currentLabel =>
      _program == null ? '' : _program!.labelAt(_pc);

  RuntimeStatus get status => _status;

  PendingChoice? get pendingChoice => _pendingChoice;

  String? get lastError => _lastError;

  bool get isLoaded => _program != null;

  Stream<EngineEffect> get effects => _effects.stream;

  Stream<RuntimeStatus> get statusChanges => _statusChanges.stream;

  Stream<PendingChoice?> get choiceChanges => _choiceChanges.stream;

  static final Program _emptyProgram = Program(
    id: '<none>',
    sourceName: '<none>',
    instructions: const <Instruction>[],
    labels: const <String, int>{},
    labelOrder: const <String>[],
  );

  // ── Loading & control ───────────────────────────────────────────────────

  /// Loads a program and (optionally) jumps straight to a label.
  Future<void> start(
    Program program, {
    String? atLabel,
    bool autoRun = true,
  }) async {
    _program = program;
    _state.episodeId = program.id;
    _pc = atLabel != null
        ? (program.addressOf(atLabel) ?? program.entryPoint)
        : program.entryPoint;
    _callStack.clear();
    _handlers.clear();
    _pendingCalls.clear();
    _clearChoice();
    _lastError = null;
    _instructionBudget = 0;
    _setStatus(RuntimeStatus.running);
    emitEvent(EngineEvents.episodeStarted,
        data: <String, Object?>{'episode': program.id});
    if (autoRun) await _drive();
  }

  /// Resumes a previously saved run.
  Future<void> restore(EngineSnapshot snapshot, Program program) async {
    _program = program;
    _state.restore(snapshot.gameState);
    _state.episodeId = snapshot.episodeId;
    _pc = program.length == 0
        ? 0
        : snapshot.programCounter.clamp(0, program.length - 1);
    _callStack
      ..clear()
      ..addAll(snapshot.callStack);
    _handlers
      ..clear()
      ..addAll(snapshot.handlers);
    random.seed = snapshot.randomSeed;
    _pendingCalls.clear();
    _clearChoice();
    _lastError = null;
    _instructionBudget = 0;

    for (final Map<String, dynamic> timer in snapshot.scheduledLabels) {
      final String label = timer['label'] as String? ?? '';
      final int remaining = (timer['remainingMs'] as num?)?.toInt() ?? 0;
      final int? repeat = (timer['repeatMs'] as num?)?.toInt();
      if (label.isEmpty) continue;
      scheduleLabel(
        label,
        Duration(milliseconds: remaining),
        id: timer['id'] as String?,
        repeat: repeat == null ? null : Duration(milliseconds: repeat),
      );
    }

    _setStatus(RuntimeStatus.running);
    await _drive();
  }

  /// Snapshot of everything needed to continue later.
  EngineSnapshot snapshot() => EngineSnapshot(
        episodeId: _state.episodeId,
        programId: _program?.id ?? '',
        programCounter: _pc,
        label: currentLabel,
        line: _program?.lineAt(_pc) ?? 0,
        status: _status,
        callStack: List<CallFrame>.of(_callStack),
        handlers: List<EventHandlerRegistration>.of(_handlers),
        randomSeed: random.seed,
        gameState: _state.toJson(),
        scheduledLabels: _scheduledLabels.values
            .map((_ScheduledLabel s) => s.toJson(clock.now()))
            .toList(),
        savedAt: clock.now(),
      );

  void pause() {
    if (_status == RuntimeStatus.paused || _status.isTerminal) return;
    _resumeStatus = _status;
    _scheduler.pause();
    _setStatus(RuntimeStatus.paused);
  }

  RuntimeStatus? _resumeStatus;

  Future<void> resume() async {
    if (_status != RuntimeStatus.paused) return;
    _scheduler.resume();
    final RuntimeStatus previous = _resumeStatus ?? RuntimeStatus.running;
    _resumeStatus = null;
    if (previous == RuntimeStatus.awaitingChoice && _pendingChoice != null) {
      _setStatus(RuntimeStatus.awaitingChoice);
      return;
    }
    if (previous == RuntimeStatus.awaitingSignal) {
      _setStatus(RuntimeStatus.awaitingSignal);
      // The signal landed while we were backgrounded: honour it now.
      if (_signalLatched) _resolveSignal();
      return;
    }
    _setStatus(RuntimeStatus.running);
    await _drive();
  }

  /// Fast-forwards the current wait (player tapped "skip").
  Future<void> skipWait() async {
    if (_status != RuntimeStatus.waiting) return;
    _scheduler.cancelTag('story_wait');
    _setStatus(RuntimeStatus.running);
    await _drive();
  }

  Future<void> stop() async {
    _scheduler.cancelAll();
    await _signalSubscription?.cancel();
    _signalSubscription = null;
    _clearChoice();
    _setStatus(RuntimeStatus.finished);
  }

  void dispose() {
    _scheduler.cancelAll();
    _signalSubscription?.cancel();
    _effects.close();
    _statusChanges.close();
    _choiceChanges.close();
  }

  // ── Choice handling ─────────────────────────────────────────────────────

  /// Picks the option at [index] of the pending choice.
  Future<bool> select(int index) async {
    final PendingChoice? choice = _pendingChoice;
    if (choice == null) return false;
    if (index < 0 || index >= choice.options.length) return false;
    final ChoiceOptionView option = choice.options[index];

    if (!option.enabled) {
      if (option.isPremium) {
        emitEffect(StoreEffect(
          reason: 'premium_choice',
          requiredCrystals: option.cost,
        ));
      }
      emitEvent(EngineEvents.choiceRejected, data: <String, Object?>{
        'id': option.id,
        'reason': option.isPremium ? 'insufficient_crystals' : 'locked',
      });
      return false;
    }

    if (option.isPremium && !option.alreadyOwned && option.cost > 0) {
      if (!_state.wallet.canAfford(option.cost)) {
        emitEffect(StoreEffect(
          reason: 'premium_choice',
          requiredCrystals: option.cost,
        ));
        emitEvent(EngineEvents.choiceRejected, data: <String, Object?>{
          'id': option.id,
          'reason': 'insufficient_crystals',
        });
        return false;
      }
      _state.updateWallet(
          (wallet) => wallet.spend(option.cost, choiceId: option.id));
      emitEvent(EngineEvents.crystalsSpent, data: <String, Object?>{
        'amount': option.cost,
        'choice': option.id,
      });
    }

    _state.markPicked(option.id);
    emitEvent(EngineEvents.choiceMade, data: <String, Object?>{
      'id': option.id,
      'label': option.label,
      'premium': option.isPremium,
    });

    _scheduler.cancelTag('choice_timer');
    _clearChoice();
    _pc = option.target;
    _setStatus(RuntimeStatus.running);
    await _drive();
    return true;
  }

  void _clearChoice() {
    if (_pendingChoice != null && !_choiceChanges.isClosed) {
      _choiceChanges.add(null);
    }
    _pendingChoice = null;
  }

  // ── EngineApi ───────────────────────────────────────────────────────────

  @override
  void emitEffect(EngineEffect effect) {
    if (!_effects.isClosed) _effects.add(effect);
  }

  @override
  void emitEvent(String name, {Map<String, Object?> data = const <String, Object?>{}}) {
    events.emit(EngineEvent(name, data: data));
    _fireHandlers(name);
  }

  @override
  int? resolveLabel(String label) => _program?.addressOf(label);

  @override
  void scheduleLabel(
    String label,
    Duration delay, {
    String? id,
    Duration? repeat,
  }) {
    final String taskId = id ?? 'sched_${_scheduledLabels.length}_$label';
    final _ScheduledLabel entry = _ScheduledLabel(
      id: taskId,
      label: label,
      firesAt: clock.now().add(delay),
      repeat: repeat,
    );
    _scheduledLabels[taskId] = entry;

    void fire() {
      final int? address = resolveLabel(label);
      if (address == null) {
        log('Scheduled label "$label" does not exist.', level: 'warning');
        _scheduledLabels.remove(taskId);
        return;
      }
      if (repeat == null) _scheduledLabels.remove(taskId);
      _pendingCalls.add(address);
      unawaited(_wake());
    }

    if (repeat != null) {
      _scheduler.every(repeat, fire, id: taskId, tag: 'story_schedule');
    } else {
      _scheduler.after(delay, fire, id: taskId, tag: 'story_schedule');
    }
  }

  @override
  void cancelScheduled(String id) {
    _scheduledLabels.remove(id);
    _scheduler.cancel(id);
  }

  @override
  void requestCheckpoint({String? name}) {
    emitEffect(CheckpointEffect(name: name));
    emitEvent(EngineEvents.checkpoint, data: <String, Object?>{'name': name});
    final Future<void> Function(String?)? callback = onCheckpoint;
    if (callback != null) unawaited(callback(name));
  }

  @override
  void log(String message, {String level = 'info'}) {
    emitEffect(DebugEffect(message, level: level));
  }

  @override
  EngineValue evaluate(Expression? expression) =>
      expression == null ? EngineValue.nullValue : expression.evaluate(_scope);

  @override
  String text(Expression? expression, [String fallback = '']) {
    if (expression == null) return fallback;
    final EngineValue value = expression.evaluate(_scope);
    return value.isNull ? fallback : value.asString;
  }

  @override
  Duration pace(Duration duration) => _settings.scaleStory(duration);

  // ── Interpreter ─────────────────────────────────────────────────────────

  void _setStatus(RuntimeStatus status) {
    if (_status == status) return;
    _status = status;
    if (!_statusChanges.isClosed) _statusChanges.add(status);
  }

  Future<void> _wake() async {
    if (_status == RuntimeStatus.paused || _status.isTerminal) return;
    if (_status == RuntimeStatus.running) return;
    if (_status == RuntimeStatus.awaitingChoice ||
        _status == RuntimeStatus.awaitingSignal) {
      // Background fibers still run while the player is deciding.
      await _pumpPendingCalls();
      return;
    }
    _setStatus(RuntimeStatus.running);
    await _drive();
  }

  Future<void> _pumpPendingCalls() async {
    if (_pendingCalls.isEmpty || _looping) return;
    // Background fibers execute as a nested run with their own return frame.
    final int address = _pendingCalls.removeAt(0);
    final int savedPc = _pc;
    final RuntimeStatus savedStatus = _status;
    final PendingChoice? savedChoice = _pendingChoice;
    _pc = address;
    _callStack.add(const CallFrame(-1, kind: 'async'));
    _setStatus(RuntimeStatus.running);
    await _drive(untilReturn: true);
    _pc = savedPc;
    _pendingChoice = savedChoice;
    _setStatus(savedStatus);
  }

  /// The main loop. Runs until the story blocks or finishes.
  Future<void> _drive({bool untilReturn = false}) async {
    if (_looping) return;
    _looping = true;
    int steps = 0;
    try {
      while (_status == RuntimeStatus.running) {
        if (!untilReturn && _pendingCalls.isNotEmpty) {
          final int address = _pendingCalls.removeAt(0);
          _callStack.add(CallFrame(_pc, kind: 'async'));
          _pc = address;
        }

        final Program? program = _program;
        if (program == null) {
          _setStatus(RuntimeStatus.idle);
          break;
        }
        if (!program.isValidAddress(_pc)) {
          _finish('end-of-program');
          break;
        }

        final Instruction instruction = program[_pc];
        final bool keepGoing = await _execute(instruction, untilReturn);
        if (!keepGoing) break;

        steps++;
        _instructionBudget++;
        if (_instructionBudget > _runawayLimit) {
          _fail('Runaway script: more than $_runawayLimit instructions.');
          break;
        }
        if (steps >= _maxInstructionsPerTick) {
          steps = 0;
          await Future<void>.delayed(Duration.zero);
        }
      }
    } catch (error, stack) {
      _fail('$error\n$stack');
    } finally {
      _looping = false;
    }
  }

  Future<bool> _execute(Instruction instruction, bool untilReturn) async {
    if (instruction is LabelInstruction) {
      _state.currentLabel = instruction.name;
      _state.markSeen(instruction.name);
      emitEvent(EngineEvents.labelEntered,
          data: <String, Object?>{'label': instruction.name});
      _pc++;
      return true;
    }

    if (instruction is NopInstruction) {
      _pc++;
      return true;
    }

    if (instruction is JumpInstruction) {
      _pc = instruction.target;
      return true;
    }

    if (instruction is BranchIfFalseInstruction) {
      final bool value = instruction.condition.evaluate(_scope).isTruthy;
      _pc = value ? _pc + 1 : instruction.target;
      return true;
    }

    if (instruction is CallInstruction) {
      _callStack.add(CallFrame(_pc + 1));
      _pc = instruction.target;
      return true;
    }

    if (instruction is ReturnInstruction) {
      if (_callStack.isEmpty) {
        _finish('return-without-call');
        return false;
      }
      final CallFrame frame = _callStack.removeLast();
      if (frame.kind == 'async' && frame.returnAddress < 0) {
        _setStatus(RuntimeStatus.idle);
        return false;
      }
      _pc = frame.returnAddress;
      if (untilReturn && frame.kind == 'async') return false;
      return true;
    }

    if (instruction is HaltInstruction) {
      _finish(text(instruction.reason, 'end'));
      return false;
    }

    if (instruction is AssignInstruction) {
      _applyAssignment(instruction);
      _pc++;
      return true;
    }

    if (instruction is RegisterHandlerInstruction) {
      _handlers.add(EventHandlerRegistration(
        event: instruction.event,
        address: instruction.address,
        once: instruction.once,
      ));
      _pc++;
      return true;
    }

    if (instruction is ChoiceInstruction) {
      _presentChoice(instruction);
      return false;
    }

    if (instruction is CommandInstruction) {
      return _executeCommand(instruction);
    }

    log('Unhandled instruction ${instruction.runtimeType}', level: 'warning');
    _pc++;
    return true;
  }

  Future<bool> _executeCommand(CommandInstruction instruction) async {
    final CommandHandler? handler = registry.lookup(instruction.name);
    if (handler == null) {
      log('No handler for @${instruction.name} (${instruction.span}).',
          level: 'warning');
      _pc++;
      return true;
    }

    final CommandContext context = CommandContext(
      engine: this,
      name: instruction.name,
      arguments: instruction.arguments,
      span: instruction.span,
    );

    late CommandOutcome outcome;
    try {
      outcome = await handler.execute(context);
    } catch (error) {
      log('@${instruction.name} failed: $error', level: 'error');
      _pc++;
      return true;
    }

    switch (outcome.type) {
      case CommandOutcomeType.next:
        _pc++;
        return true;

      case CommandOutcomeType.jump:
        final int? address = outcome.address ??
            (outcome.label == null ? null : resolveLabel(outcome.label!));
        if (address == null) {
          log('Cannot jump to "${outcome.label}" — unknown label.',
              level: 'error');
          _pc++;
          return true;
        }
        _pc = address;
        return true;

      case CommandOutcomeType.wait:
        _pc++;
        final Duration delay = outcome.duration ?? Duration.zero;
        if (delay <= Duration.zero) return true;
        _setStatus(RuntimeStatus.waiting);
        _scheduler.after(delay, () {
          if (_status != RuntimeStatus.waiting) return;
          _setStatus(RuntimeStatus.running);
          unawaited(_drive());
        }, tag: 'story_wait');
        return false;

      case CommandOutcomeType.waitForSignal:
        // The program counter deliberately stays on the `@await` instruction.
        // A save taken while waiting therefore points *at* the await, so
        // restoring re-arms it instead of silently skipping past the thing the
        // player was supposed to do (e.g. tapping Install in the browser).
        // `@await` has no side effects, so re-executing it is free.
        _awaitSignal(outcome.signal!, outcome.duration);
        return false;

      case CommandOutcomeType.halt:
        _finish(outcome.message ?? 'halt');
        return false;

      case CommandOutcomeType.error:
        log('@${instruction.name}: ${outcome.message}', level: 'error');
        _pc++;
        return true;
    }
  }

  void _applyAssignment(AssignInstruction instruction) {
    final EngineValue value = instruction.value.evaluate(_scope);

    switch (instruction.namespace) {
      case VariableNamespace.wallet:
        final int current = _state.wallet.crystals;
        final int next = _applyOperator(
                instruction.operator, current, value.asNum)
            .round();
        final int delta = next - current;
        _state.updateWallet((wallet) => delta >= 0
            ? wallet.earn(delta)
            : wallet.spend(-delta));
        emitEvent(
          delta >= 0
              ? EngineEvents.crystalsGranted
              : EngineEvents.crystalsSpent,
          data: <String, Object?>{'amount': delta.abs()},
        );
        return;

      case VariableNamespace.relationship:
        final int underscore = instruction.target.indexOf('_');
        final RelationshipAxis? axis = underscore <= 0
            ? null
            : relationshipAxisFromName(
                instruction.target.substring(0, underscore));
        if (axis != null) {
          final String character = instruction.target.substring(underscore + 1);
          final num current = _state.relationship(character).axis(axis);
          final num next =
              _applyOperator(instruction.operator, current, value.asNum);
          _state.adjustRelationship(character, axis, next, absolute: true);
          emitEvent(EngineEvents.relationshipChanged, data: <String, Object?>{
            'character': character,
            'axis': axis.name,
            'value': next,
          });
          return;
        }
        continue variable;

      variable:
      case VariableNamespace.variable:
      case VariableNamespace.flag:
        variables.mutate(instruction.target, instruction.operator, value);
        emitEvent(EngineEvents.variableChanged, data: <String, Object?>{
          'name': instruction.target,
          'value': variables.get(instruction.target).raw,
        });
        return;
    }
  }

  num _applyOperator(AssignmentOperator op, num current, num operand) {
    switch (op) {
      case AssignmentOperator.assign:
        return operand;
      case AssignmentOperator.add:
        return current + operand;
      case AssignmentOperator.subtract:
        return current - operand;
      case AssignmentOperator.multiply:
        return current * operand;
      case AssignmentOperator.divide:
        return operand == 0 ? current : current / operand;
      case AssignmentOperator.modulo:
        return operand == 0 ? current : current % operand;
    }
  }

  void _presentChoice(ChoiceInstruction instruction) {
    final List<ChoiceOptionView> views = <ChoiceOptionView>[];
    int index = 0;

    for (final CompiledChoiceOption option in instruction.options) {
      if (option.condition != null &&
          !option.condition!.evaluate(_scope).isTruthy) {
        continue;
      }
      if (option.once && _state.hasPicked(option.id)) continue;

      final int cost = option.cost == null
          ? (option.isPremium ? defaultPremiumCost : 0)
          : option.cost!.evaluate(_scope).asInt;
      final bool owned = _state.wallet.hasUnlockedChoice(option.id);
      bool enabled = true;
      String? hint = option.hint == null ? null : text(option.hint);

      if (option.requirement != null &&
          !option.requirement!.evaluate(_scope).isTruthy) {
        enabled = false;
        hint ??= 'Locked';
      }
      if (option.isPremium && !owned && !_state.wallet.canAfford(cost)) {
        enabled = false;
        hint ??= 'Needs $cost crystals';
      }

      views.add(ChoiceOptionView(
        index: index++,
        id: option.id,
        label: text(option.label),
        kind: option.kind,
        target: option.target,
        cost: cost,
        enabled: enabled,
        hint: hint,
        alreadyOwned: owned,
        picked: _state.hasPicked(option.id),
      ));
    }

    if (views.isEmpty) {
      log('Choice at ${instruction.span} had no selectable options.',
          level: 'warning');
      _pc++;
      unawaited(_drive());
      return;
    }

    final List<ChoiceOptionView> ordered =
        instruction.shuffle ? random.shuffled(views) : views;

    final Duration? timeout = instruction.timeout == null
        ? null
        : Duration(
            milliseconds:
                (instruction.timeout!.evaluate(_scope).asNum * 1000).round());

    _pendingChoice = PendingChoice(
      options: ordered,
      address: _pc,
      prompt: instruction.prompt == null ? null : text(instruction.prompt),
      timeout: timeout,
      startedAt: clock.now(),
      style: instruction.style,
    );
    _setStatus(RuntimeStatus.awaitingChoice);
    if (!_choiceChanges.isClosed) _choiceChanges.add(_pendingChoice);
    emitEvent(EngineEvents.choicePresented, data: <String, Object?>{
      'count': ordered.length,
      'timed': timeout != null,
    });

    if (timeout != null) {
      _scheduler.after(timeout, () => _onChoiceTimeout(instruction),
          tag: 'choice_timer');
    }
  }

  void _onChoiceTimeout(ChoiceInstruction instruction) {
    if (_status != RuntimeStatus.awaitingChoice) return;
    final PendingChoice? choice = _pendingChoice;
    if (choice == null) return;

    final String? fallbackLabel = instruction.defaultLabel;
    final int? fallbackAddress =
        fallbackLabel == null ? null : resolveLabel(fallbackLabel);

    if (fallbackAddress != null) {
      _clearChoice();
      emitEvent(EngineEvents.choiceMade,
          data: <String, Object?>{'id': 'timeout', 'timeout': true});
      _pc = fallbackAddress;
      _setStatus(RuntimeStatus.running);
      unawaited(_drive());
      return;
    }

    // No explicit default → pick the first enabled option.
    for (final ChoiceOptionView option in choice.options) {
      if (option.enabled) {
        unawaited(select(option.index));
        return;
      }
    }
  }

  void _awaitSignal(String signal, Duration? timeout) {
    _awaitedSignal = signal;
    _signalLatched = false;
    _setStatus(RuntimeStatus.awaitingSignal);
    _signalSubscription?.cancel();
    _signalSubscription = events.stream.listen((EngineEvent event) {
      if (event.name != signal) return;
      _resolveSignal();
    });
    if (timeout != null) {
      _scheduler.after(timeout, _resolveSignal, tag: 'await_timeout');
    }
  }

  void _resolveSignal() {
    // Arriving while paused is legitimate — latch it and let [resume] finish
    // the job rather than throwing the event away.
    if (_status == RuntimeStatus.paused &&
        _resumeStatus == RuntimeStatus.awaitingSignal) {
      _signalLatched = true;
      return;
    }
    if (_status != RuntimeStatus.awaitingSignal) return;
    _awaitedSignal = null;
    _signalLatched = false;
    _signalSubscription?.cancel();
    _signalSubscription = null;
    _scheduler.cancelTag('await_timeout');
    // Step over the `@await` the program counter was parked on.
    _pc++;
    _setStatus(RuntimeStatus.running);
    unawaited(_drive());
  }

  void _fireHandlers(String eventName) {
    if (_handlers.isEmpty) return;
    for (final EventHandlerRegistration handler in _handlers) {
      if (handler.event != eventName || handler.consumed) continue;
      if (handler.once) handler.consumed = true;
      _pendingCalls.add(handler.address);
    }
    if (_pendingCalls.isNotEmpty &&
        (_status == RuntimeStatus.awaitingChoice ||
            _status == RuntimeStatus.awaitingSignal ||
            _status == RuntimeStatus.waiting)) {
      unawaited(_pumpPendingCalls());
    }
  }

  void _finish(String reason) {
    _scheduler.cancelTag('story_wait');
    _scheduler.cancelTag('choice_timer');
    _clearChoice();
    _setStatus(RuntimeStatus.finished);
    emitEffect(EpisodeCompleteEffect(_state.episodeId, reason: reason));
    emitEvent(EngineEvents.episodeFinished, data: <String, Object?>{
      'episode': _state.episodeId,
      'reason': reason,
    });
  }

  void _fail(String message) {
    _lastError = message;
    _setStatus(RuntimeStatus.error);
    emitEffect(DebugEffect(message, level: 'error'));
    emitEvent(EngineEvents.runtimeError,
        data: <String, Object?>{'message': message});
  }

  /// Default price used when a premium option omits an explicit cost.
  static const int defaultPremiumCost = 10;

  /// Diagnostics surfaced by the compiler for the currently loaded program.
  final DiagnosticBag diagnostics = DiagnosticBag();

  /// Debug helper: the last N executed instruction labels.
  final List<String> trace = <String>[];

  String? get awaitedSignal => _awaitedSignal;
}

class _ScheduledLabel {
  _ScheduledLabel({
    required this.id,
    required this.label,
    required this.firesAt,
    this.repeat,
  });

  final String id;
  final String label;
  final DateTime firesAt;
  final Duration? repeat;

  Map<String, dynamic> toJson(DateTime now) {
    final Duration left = firesAt.difference(now);
    return <String, dynamic>{
      'id': id,
      'label': label,
      'remainingMs': left.isNegative ? 0 : left.inMilliseconds,
      if (repeat != null) 'repeatMs': repeat!.inMilliseconds,
    };
  }
}
