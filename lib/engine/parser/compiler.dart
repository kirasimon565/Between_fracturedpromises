import '../diagnostics/diagnostic.dart';
import '../lexer/source_span.dart';
import '../runtime/instruction.dart';
import '../runtime/program.dart';
import '../variables/engine_value.dart';
import '../variables/variable_store.dart';
import 'ast.dart';
import 'expression.dart';

/// Lowers the AST into the flat instruction list executed by the runtime.
///
/// Loops and conditionals become jumps, so nothing on the runtime side needs to
/// understand block structure — which is exactly what makes "save anywhere,
/// resume anywhere" work.
class ScriptCompiler {
  ScriptCompiler({DiagnosticBag? diagnostics})
    : diagnostics = diagnostics ?? DiagnosticBag();

  final DiagnosticBag diagnostics;

  final List<Instruction> _code = <Instruction>[];
  final Map<String, int> _labels = <String, int>{};
  final List<String> _labelOrder = <String>[];

  /// Jumps whose target is a label name that may not exist yet.
  final List<_PendingLabelJump> _pending = <_PendingLabelJump>[];

  /// Loop context stack for `@break` / `@continue`.
  final List<_LoopContext> _loops = <_LoopContext>[];

  int _uniqueCounter = 0;

  Program compile(ScriptNode script, {required String id}) {
    _code.clear();
    _labels.clear();
    _labelOrder.clear();
    _pending.clear();
    _loops.clear();

    for (final LabelNode label in script.labels) {
      _defineLabel(label.name, label.span);
      _emitStatements(label.statements);
    }

    // Every program ends with an implicit halt.
    _emit(
      HaltInstruction(
        script.labels.isEmpty ? SourceSpan.unknown : script.labels.last.span,
      ),
    );

    _resolvePendingJumps();

    return Program(
      id: id,
      sourceName: script.sourceName,
      instructions: List<Instruction>.unmodifiable(_code),
      labels: Map<String, int>.unmodifiable(_labels),
      labelOrder: List<String>.unmodifiable(_labelOrder),
      metadata: Map<String, Expression>.from(script.metadata),
    );
  }

  // ── Emission helpers ────────────────────────────────────────────────────

  int get _here => _code.length;

  int _emit(Instruction instruction) {
    _code.add(instruction);
    return _code.length - 1;
  }

  void _defineLabel(String name, SourceSpan span) {
    if (_labels.containsKey(name)) {
      diagnostics.warn('Duplicate label "$name" — the first one wins.', span);
    } else {
      _labels[name] = _here;
      _labelOrder.add(name);
    }
    _emit(LabelInstruction(name, span));
  }

  String _unique(String prefix) => '__${prefix}_${_uniqueCounter++}';

  void _resolvePendingJumps() {
    for (final _PendingLabelJump jump in _pending) {
      final int? address = _labels[jump.label];
      if (address == null) {
        diagnostics.error('Unknown label "@${jump.label}".', jump.span);
        // Point the jump at the final halt so the game degrades gracefully.
        jump.apply(_code.length - 1);
        continue;
      }
      jump.apply(address);
    }
  }

  // ── Statements ──────────────────────────────────────────────────────────

  void _emitStatements(List<Statement> statements) {
    for (final Statement statement in statements) {
      _emitStatement(statement);
    }
  }

  void _emitStatement(Statement statement) {
    if (statement is CommandStatement) {
      if (statement.name == 'include') return; // resolved by the loader
      _emit(
        CommandInstruction(
          name: statement.name,
          arguments: statement.arguments,
          span: statement.span,
        ),
      );
      return;
    }

    if (statement is AssignmentStatement) {
      _emit(
        AssignInstruction(
          target: statement.target,
          operator: statement.operator,
          value: statement.value,
          namespace: statement.namespace,
          span: statement.span,
        ),
      );
      return;
    }

    if (statement is GotoStatement) {
      if (statement.isCall) {
        final CallInstruction call = CallInstruction(-1, statement.span);
        _emit(call);
        _pending.add(
          _PendingLabelJump(
            statement.target,
            statement.span,
            (int a) => call.target = a,
          ),
        );
      } else {
        final JumpInstruction jump = JumpInstruction(-1, statement.span);
        _emit(jump);
        _pending.add(
          _PendingLabelJump(
            statement.target,
            statement.span,
            (int a) => jump.target = a,
          ),
        );
      }
      return;
    }

    if (statement is ReturnStatement) {
      _emit(ReturnInstruction(statement.span));
      return;
    }

    if (statement is HaltStatement) {
      _emit(HaltInstruction(statement.span, reason: statement.reason));
      return;
    }

    if (statement is IfStatement) {
      _emitIf(statement);
      return;
    }

    if (statement is SwitchStatement) {
      _emitSwitch(statement);
      return;
    }

    if (statement is WhileStatement) {
      _emitWhile(statement);
      return;
    }

    if (statement is RepeatStatement) {
      _emitRepeat(statement);
      return;
    }

    if (statement is ForStatement) {
      _emitFor(statement);
      return;
    }

    if (statement is LoopControlStatement) {
      _emitLoopControl(statement);
      return;
    }

    if (statement is ChoiceStatement) {
      _emitChoice(statement);
      return;
    }

    if (statement is EventHandlerStatement) {
      _emitEventHandler(statement);
      return;
    }

    diagnostics.warn(
      'Statement ${statement.runtimeType} was ignored.',
      statement.span,
    );
  }

  void _emitIf(IfStatement statement) {
    final List<JumpInstruction> exits = <JumpInstruction>[];

    for (final ConditionalBranch branch in statement.branches) {
      final BranchIfFalseInstruction test = BranchIfFalseInstruction(
        branch.condition,
        -1,
        statement.span,
      );
      _emit(test);
      _emitStatements(branch.body);
      final JumpInstruction exit = JumpInstruction(-1, statement.span);
      _emit(exit);
      exits.add(exit);
      test.target = _here;
    }

    _emitStatements(statement.elseBody);

    final int end = _here;
    for (final JumpInstruction exit in exits) {
      exit.target = end;
    }
  }

  void _emitSwitch(SwitchStatement statement) {
    final String temp = _unique('switch');
    _emit(
      AssignInstruction(
        target: temp,
        operator: AssignmentOperator.assign,
        value: statement.subject,
        namespace: VariableNamespace.variable,
        span: statement.span,
      ),
    );

    final List<JumpInstruction> exits = <JumpInstruction>[];

    for (final SwitchCase entry in statement.cases) {
      final Expression condition = BinaryExpression(
        '==',
        VariableExpression(temp, statement.span),
        entry.match,
        statement.span,
      );
      final BranchIfFalseInstruction test = BranchIfFalseInstruction(
        condition,
        -1,
        statement.span,
      );
      _emit(test);
      _emitStatements(entry.body);
      final JumpInstruction exit = JumpInstruction(-1, statement.span);
      _emit(exit);
      exits.add(exit);
      test.target = _here;
    }

    _emitStatements(statement.defaultBody);

    final int end = _here;
    for (final JumpInstruction exit in exits) {
      exit.target = end;
    }
  }

  void _emitWhile(WhileStatement statement) {
    final int start = _here;
    final BranchIfFalseInstruction test = BranchIfFalseInstruction(
      statement.condition,
      -1,
      statement.span,
    );
    _emit(test);

    final _LoopContext context = _LoopContext(continueTarget: start);
    _loops.add(context);
    _emitStatements(statement.body);
    _loops.removeLast();

    _emit(JumpInstruction(start, statement.span));
    final int end = _here;
    test.target = end;
    context.resolve(breakTarget: end, continueTarget: start);
  }

  void _emitRepeat(RepeatStatement statement) {
    final String counter = _unique('repeat_i');
    final String limit = _unique('repeat_n');

    _emit(
      AssignInstruction(
        target: counter,
        operator: AssignmentOperator.assign,
        value: const LiteralExpression(EngineValue.zero, SourceSpan.unknown),
        namespace: VariableNamespace.variable,
        span: statement.span,
      ),
    );
    _emit(
      AssignInstruction(
        target: limit,
        operator: AssignmentOperator.assign,
        value: statement.count,
        namespace: VariableNamespace.variable,
        span: statement.span,
      ),
    );

    final int start = _here;
    final BranchIfFalseInstruction test = BranchIfFalseInstruction(
      BinaryExpression(
        '<',
        VariableExpression(counter, statement.span),
        VariableExpression(limit, statement.span),
        statement.span,
      ),
      -1,
      statement.span,
    );
    _emit(test);

    final _LoopContext context = _LoopContext(continueTarget: -1);
    _loops.add(context);
    _emitStatements(statement.body);
    _loops.removeLast();

    final int increment = _here;
    _emit(
      AssignInstruction(
        target: counter,
        operator: AssignmentOperator.add,
        value: const LiteralExpression(
          EngineValue.number(1),
          SourceSpan.unknown,
        ),
        namespace: VariableNamespace.variable,
        span: statement.span,
      ),
    );
    _emit(JumpInstruction(start, statement.span));

    final int end = _here;
    test.target = end;
    context.resolve(breakTarget: end, continueTarget: increment);
  }

  void _emitFor(ForStatement statement) {
    final String list = _unique('for_list');
    final String index = _unique('for_i');

    _emit(
      AssignInstruction(
        target: list,
        operator: AssignmentOperator.assign,
        value: statement.iterable,
        namespace: VariableNamespace.variable,
        span: statement.span,
      ),
    );
    _emit(
      AssignInstruction(
        target: index,
        operator: AssignmentOperator.assign,
        value: const LiteralExpression(EngineValue.zero, SourceSpan.unknown),
        namespace: VariableNamespace.variable,
        span: statement.span,
      ),
    );

    final int start = _here;
    final BranchIfFalseInstruction test = BranchIfFalseInstruction(
      BinaryExpression(
        '<',
        VariableExpression(index, statement.span),
        CallExpression('len', <Expression>[
          VariableExpression(list, statement.span),
        ], statement.span),
        statement.span,
      ),
      -1,
      statement.span,
    );
    _emit(test);

    _emit(
      AssignInstruction(
        target: statement.variable,
        operator: AssignmentOperator.assign,
        value: CallExpression('at', <Expression>[
          VariableExpression(list, statement.span),
          VariableExpression(index, statement.span),
        ], statement.span),
        namespace: VariableNamespace.variable,
        span: statement.span,
      ),
    );

    final _LoopContext context = _LoopContext(continueTarget: -1);
    _loops.add(context);
    _emitStatements(statement.body);
    _loops.removeLast();

    final int increment = _here;
    _emit(
      AssignInstruction(
        target: index,
        operator: AssignmentOperator.add,
        value: const LiteralExpression(
          EngineValue.number(1),
          SourceSpan.unknown,
        ),
        namespace: VariableNamespace.variable,
        span: statement.span,
      ),
    );
    _emit(JumpInstruction(start, statement.span));

    final int end = _here;
    test.target = end;
    context.resolve(breakTarget: end, continueTarget: increment);
  }

  void _emitLoopControl(LoopControlStatement statement) {
    if (_loops.isEmpty) {
      diagnostics.error(
        '@${statement.isBreak ? 'break' : 'continue'} outside of a loop.',
        statement.span,
      );
      return;
    }
    final JumpInstruction jump = JumpInstruction(-1, statement.span);
    _emit(jump);
    if (statement.isBreak) {
      _loops.last.breaks.add(jump);
    } else {
      _loops.last.continues.add(jump);
    }
  }

  void _emitChoice(ChoiceStatement statement) {
    final List<CompiledChoiceOption> options = <CompiledChoiceOption>[];
    final List<_PendingLabelJump> patches = <_PendingLabelJump>[];

    for (final ChoiceOptionNode option in statement.options) {
      final int slot = options.length;
      options.add(
        CompiledChoiceOption(
          id: option.stableId,
          label: option.label,
          target: -1,
          targetLabel: option.target,
          kind: option.kind,
          cost: option.cost,
          condition: option.condition,
          requirement: option.requirement,
          hint: option.hint,
          once: option.once,
        ),
      );
      patches.add(
        _PendingLabelJump(option.target, option.span, (int address) {
          options[slot] = CompiledChoiceOption(
            id: option.stableId,
            label: option.label,
            target: address,
            targetLabel: option.target,
            kind: option.kind,
            cost: option.cost,
            condition: option.condition,
            requirement: option.requirement,
            hint: option.hint,
            once: option.once,
          );
        }),
      );
    }
    _pending.addAll(patches);

    _emit(
      ChoiceInstruction(
        options: options,
        span: statement.span,
        prompt: statement.prompt,
        timeout: statement.timeout,
        // Timed choices resolve their fallback through the label table at
        // runtime, which keeps the instruction immutable.
        defaultLabel: statement.defaultTarget,
        shuffle: statement.shuffle,
        style: statement.style,
      ),
    );

    if (statement.defaultTarget != null) {
      // Registered purely so an unknown default label is reported at compile
      // time like any other bad jump.
      _pending.add(
        _PendingLabelJump(statement.defaultTarget!, statement.span, (int _) {}),
      );
    }
  }

  void _emitEventHandler(EventHandlerStatement statement) {
    // Handler bodies live inline but are jumped over during normal flow.
    final JumpInstruction skip = JumpInstruction(-1, statement.span);
    final RegisterHandlerInstruction register = RegisterHandlerInstruction(
      event: statement.event,
      address: -1,
      once: statement.once,
      span: statement.span,
    );
    _emit(register);
    _emit(skip);
    register.address = _here;
    _emitStatements(statement.body);
    _emit(ReturnInstruction(statement.span));
    skip.target = _here;
  }
}

class _PendingLabelJump {
  _PendingLabelJump(this.label, this.span, this.apply);

  final String label;
  final SourceSpan span;
  final void Function(int address) apply;
}

class _LoopContext {
  _LoopContext({required this.continueTarget});

  int continueTarget;
  final List<JumpInstruction> breaks = <JumpInstruction>[];
  final List<JumpInstruction> continues = <JumpInstruction>[];

  void resolve({required int breakTarget, required int continueTarget}) {
    for (final JumpInstruction jump in breaks) {
      jump.target = breakTarget;
    }
    for (final JumpInstruction jump in continues) {
      jump.target = continueTarget;
    }
  }
}
