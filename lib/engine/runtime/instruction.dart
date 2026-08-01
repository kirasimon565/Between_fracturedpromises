import '../lexer/source_span.dart';
import '../parser/ast.dart';
import '../parser/expression.dart';
import '../variables/variable_store.dart';

/// Base class of the flat instruction set produced by the compiler.
///
/// Structured statements (`@if`, `@while`, `@choice`) are lowered into jumps,
/// which means the whole program is addressable by a single integer. Saving the
/// game is therefore "store the program counter", and loading restores
/// execution *exactly* where the player stopped.
abstract class Instruction {
  Instruction(this.span);

  final SourceSpan span;

  /// Short text used by the debug overlay / trace log.
  String get debugLabel;
}

/// Marks the address of a `:: label`. Executing it is a no-op.
class LabelInstruction extends Instruction {
  LabelInstruction(this.name, SourceSpan span) : super(span);

  final String name;

  @override
  String get debugLabel => ':: $name';
}

class NopInstruction extends Instruction {
  NopInstruction(super.span);

  @override
  String get debugLabel => 'nop';
}

/// Runs a registered command handler.
class CommandInstruction extends Instruction {
  CommandInstruction({
    required this.name,
    required this.arguments,
    required SourceSpan span,
  }) : super(span);

  final String name;
  final ArgumentList arguments;

  @override
  String get debugLabel => '@$name ${arguments.raw}';
}

/// Variable / flag / relationship / wallet mutation.
class AssignInstruction extends Instruction {
  AssignInstruction({
    required this.target,
    required this.operator,
    required this.value,
    required this.namespace,
    required SourceSpan span,
  }) : super(span);

  final String target;
  final AssignmentOperator operator;
  final Expression value;
  final VariableNamespace namespace;

  @override
  String get debugLabel => 'set $target ${operator.name} $value';
}

class JumpInstruction extends Instruction {
  JumpInstruction(this.target, SourceSpan span) : super(span);

  /// Absolute address; mutable so the compiler can back-patch it.
  int target;

  @override
  String get debugLabel => 'jump -> $target';
}

/// Jumps to [target] when [condition] evaluates to false.
class BranchIfFalseInstruction extends Instruction {
  BranchIfFalseInstruction(this.condition, this.target, SourceSpan span)
    : super(span);

  final Expression condition;
  int target;

  @override
  String get debugLabel => 'branch-if-not ($condition) -> $target';
}

/// Pushes a return address and jumps (used by `@call` and event handlers).
class CallInstruction extends Instruction {
  CallInstruction(this.target, SourceSpan span) : super(span);

  int target;

  @override
  String get debugLabel => 'call -> $target';
}

class ReturnInstruction extends Instruction {
  ReturnInstruction(super.span);

  @override
  String get debugLabel => 'return';
}

class HaltInstruction extends Instruction {
  HaltInstruction(super.span, {this.reason});

  final Expression? reason;

  @override
  String get debugLabel => 'halt';
}

/// A single selectable option after compilation: the target is an address.
class CompiledChoiceOption {
  const CompiledChoiceOption({
    required this.id,
    required this.label,
    required this.target,
    required this.kind,
    this.cost,
    this.condition,
    this.requirement,
    this.hint,
    this.once = false,
    this.targetLabel = '',
  });

  final String id;
  final Expression label;
  final int target;
  final String targetLabel;
  final ChoiceOptionKind kind;
  final Expression? cost;
  final Expression? condition;
  final Expression? requirement;
  final Expression? hint;
  final bool once;

  bool get isPremium => kind == ChoiceOptionKind.premium;
  bool get isLocked => kind == ChoiceOptionKind.locked;
}

/// Suspends the runtime until the player (or the timer) picks an option.
class ChoiceInstruction extends Instruction {
  ChoiceInstruction({
    required this.options,
    required SourceSpan span,
    this.prompt,
    this.timeout,
    this.defaultTarget,
    this.defaultLabel,
    this.shuffle = false,
    this.style,
  }) : super(span);

  final List<CompiledChoiceOption> options;
  final Expression? prompt;
  final Expression? timeout;

  /// Address used when a timed choice expires.
  final int? defaultTarget;
  final String? defaultLabel;
  final bool shuffle;
  final String? style;

  bool get isTimed => timeout != null;

  @override
  String get debugLabel => 'choice (${options.length} options)';
}

/// Registers a deferred `@on <event>` handler at runtime.
class RegisterHandlerInstruction extends Instruction {
  RegisterHandlerInstruction({
    required this.event,
    required this.address,
    required this.once,
    required SourceSpan span,
  }) : super(span);

  final String event;
  int address;
  final bool once;

  @override
  String get debugLabel => 'on $event -> $address';
}
