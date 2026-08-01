import '../lexer/source_span.dart';
import '../variables/variable_store.dart';
import 'expression.dart';

/// Positional + named arguments of a directive.
///
/// The DSL mixes both styles freely:
/// `@music "theme" volume 0.2 loop true` → positional `["theme"]`,
/// named `{volume: 0.2, loop: true}`.
class ArgumentList {
  const ArgumentList({
    this.positional = const <Expression>[],
    this.named = const <String, Expression>{},
    this.raw = '',
  });

  static const ArgumentList empty = ArgumentList();

  final List<Expression> positional;
  final Map<String, Expression> named;

  /// Original text after the directive name (used by pass-through commands
  /// such as `@debug` and by plugins that want to do their own parsing).
  final String raw;

  bool get isEmpty => positional.isEmpty && named.isEmpty;

  int get count => positional.length;

  Expression? positionalAt(int index) =>
      index < positional.length ? positional[index] : null;

  Expression? namedOrNull(String key) => named[key.toLowerCase()];

  bool hasNamed(String key) => named.containsKey(key.toLowerCase());

  @override
  String toString() =>
      '${positional.join(' ')}${named.isEmpty ? '' : ' $named'}';
}

/// Base class of every statement node.
abstract class Statement {
  const Statement(this.span);

  final SourceSpan span;
}

/// `@directive args…` — the workhorse of the language.
class CommandStatement extends Statement {
  const CommandStatement({
    required this.name,
    required this.arguments,
    required SourceSpan span,
  }) : super(span);

  /// Lower-cased directive name without the `@`.
  final String name;
  final ArgumentList arguments;

  @override
  String toString() => '@$name $arguments';
}

/// `@set var = expr`, `@add var 3`, `@subtract var 3`.
class AssignmentStatement extends Statement {
  const AssignmentStatement({
    required this.target,
    required this.operator,
    required this.value,
    required SourceSpan span,
    this.namespace = VariableNamespace.variable,
  }) : super(span);

  final String target;
  final AssignmentOperator operator;
  final Expression value;
  final VariableNamespace namespace;

  @override
  String toString() => '@set $target ${operator.name} $value';
}

/// Which logical bucket an assignment writes into.
enum VariableNamespace { variable, flag, relationship, wallet }

/// A single selectable option inside a `@choice` block.
class ChoiceOptionNode {
  const ChoiceOptionNode({
    required this.label,
    required this.target,
    required this.span,
    this.kind = ChoiceOptionKind.normal,
    this.cost,
    this.condition,
    this.requirement,
    this.hint,
    this.once = false,
    this.id,
  });

  final Expression label;

  /// Label name to jump to (without the leading `@`).
  final String target;

  final ChoiceOptionKind kind;

  /// Crystal price for premium options.
  final Expression? cost;

  /// `if <expr>` — hides the option entirely when false.
  final Expression? condition;

  /// `requires <expr>` — shows the option greyed out / locked when false.
  final Expression? requirement;

  /// Text shown when the option is locked.
  final Expression? hint;

  /// When true the option disappears after being picked once.
  final bool once;

  /// Stable id used for "seen options" bookkeeping; defaults to target.
  final String? id;

  final SourceSpan span;

  String get stableId => id ?? '$target@${span.line}';
}

enum ChoiceOptionKind { normal, premium, locked }

/// `@choice [timeout N] [default @label]` followed by option lines.
class ChoiceStatement extends Statement {
  const ChoiceStatement({
    required this.options,
    required SourceSpan span,
    this.prompt,
    this.timeout,
    this.defaultTarget,
    this.shuffle = false,
    this.style,
  }) : super(span);

  final List<ChoiceOptionNode> options;
  final Expression? prompt;

  /// Seconds before [defaultTarget] is auto-selected (timed choice).
  final Expression? timeout;
  final String? defaultTarget;
  final bool shuffle;
  final String? style;

  bool get isTimed => timeout != null;

  @override
  String toString() => '@choice(${options.length})';
}

class ConditionalBranch {
  const ConditionalBranch(this.condition, this.body);

  final Expression condition;
  final List<Statement> body;
}

/// `@if … @elseif … @else … @endif`
class IfStatement extends Statement {
  const IfStatement({
    required this.branches,
    required SourceSpan span,
    this.elseBody = const <Statement>[],
  }) : super(span);

  final List<ConditionalBranch> branches;
  final List<Statement> elseBody;
}

class SwitchCase {
  const SwitchCase(this.match, this.body);

  final Expression match;
  final List<Statement> body;
}

/// `@switch expr / @case value / @default / @endswitch`
class SwitchStatement extends Statement {
  const SwitchStatement({
    required this.subject,
    required this.cases,
    required SourceSpan span,
    this.defaultBody = const <Statement>[],
  }) : super(span);

  final Expression subject;
  final List<SwitchCase> cases;
  final List<Statement> defaultBody;
}

/// `@while cond … @endwhile`
class WhileStatement extends Statement {
  const WhileStatement({
    required this.condition,
    required this.body,
    required SourceSpan span,
  }) : super(span);

  final Expression condition;
  final List<Statement> body;
}

/// `@repeat N … @endrepeat`
class RepeatStatement extends Statement {
  const RepeatStatement({
    required this.count,
    required this.body,
    required SourceSpan span,
  }) : super(span);

  final Expression count;
  final List<Statement> body;
}

/// `@for item in list … @endfor`
class ForStatement extends Statement {
  const ForStatement({
    required this.variable,
    required this.iterable,
    required this.body,
    required SourceSpan span,
  }) : super(span);

  final String variable;
  final Expression iterable;
  final List<Statement> body;
}

/// `@break` / `@continue`
class LoopControlStatement extends Statement {
  const LoopControlStatement(this.isBreak, SourceSpan span) : super(span);

  final bool isBreak;
}

/// `@goto @label` and `@call @label`.
class GotoStatement extends Statement {
  const GotoStatement({
    required this.target,
    required SourceSpan span,
    this.isCall = false,
  }) : super(span);

  /// Static label name, or `null` when the target is dynamic.
  final String target;
  final bool isCall;
}

/// `@return`
class ReturnStatement extends Statement {
  const ReturnStatement(SourceSpan span) : super(span);
}

/// `@end` — stops the episode.
class HaltStatement extends Statement {
  const HaltStatement(SourceSpan span, {this.reason}) : super(span);

  final Expression? reason;
}

/// `@on <event> … @endon` — registers a deferred handler block.
class EventHandlerStatement extends Statement {
  const EventHandlerStatement({
    required this.event,
    required this.body,
    required SourceSpan span,
    this.once = false,
  }) : super(span);

  final String event;
  final List<Statement> body;
  final bool once;
}

/// `:: label_name` and its statements.
class LabelNode {
  LabelNode({
    required this.name,
    required this.span,
    List<Statement>? statements,
  }) : statements = statements ?? <Statement>[];

  final String name;
  final SourceSpan span;
  final List<Statement> statements;

  @override
  String toString() => ':: $name (${statements.length} statements)';
}

/// A fully parsed script file.
class ScriptNode {
  ScriptNode({
    required this.sourceName,
    List<LabelNode>? labels,
    Map<String, Expression>? metadata,
    List<String>? includes,
  })  : labels = labels ?? <LabelNode>[],
        metadata = metadata ?? <String, Expression>{},
        includes = includes ?? <String>[];

  final String sourceName;
  final List<LabelNode> labels;

  /// `@title`, `@episode`, `@author`, `@difficulty`, `@version`…
  final Map<String, Expression> metadata;

  /// `@include "other.txt"` — resolved by the script loader before compiling.
  final List<String> includes;

  LabelNode? labelNamed(String name) {
    for (final LabelNode label in labels) {
      if (label.name == name) return label;
    }
    return null;
  }

  @override
  String toString() => 'Script($sourceName, ${labels.length} labels)';
}
