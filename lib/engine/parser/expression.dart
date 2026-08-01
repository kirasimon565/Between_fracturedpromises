import '../lexer/source_span.dart';
import '../variables/engine_value.dart';
import '../variables/expression_scope.dart';

/// Base class for every expression node.
///
/// Expressions are evaluated lazily at runtime, which is what makes string
/// interpolation (`"Hi {player_name}"`) and conditional choices possible
/// without re-parsing the script.
abstract class Expression {
  const Expression(this.span);

  final SourceSpan span;

  EngineValue evaluate(ExpressionScope scope);

  /// Serialised form; the compiled program is cached to disk between runs.
  Map<String, dynamic> toJson();

  static Expression fromJson(Map<String, dynamic> json) {
    final String kind = json['k'] as String;
    final SourceSpan span = json['sp'] == null
        ? SourceSpan.unknown
        : SourceSpan.fromJson(Map<String, dynamic>.from(json['sp'] as Map));
    switch (kind) {
      case 'lit':
        return LiteralExpression(EngineValue.of(json['v']), span);
      case 'var':
        return VariableExpression(json['n'] as String, span);
      case 'str':
        return InterpolatedStringExpression(
          (json['p'] as List<dynamic>)
              .map((dynamic e) =>
                  StringPart.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(),
          span,
        );
      case 'un':
        return UnaryExpression(
          json['o'] as String,
          Expression.fromJson(Map<String, dynamic>.from(json['e'] as Map)),
          span,
        );
      case 'bin':
        return BinaryExpression(
          json['o'] as String,
          Expression.fromJson(Map<String, dynamic>.from(json['l'] as Map)),
          Expression.fromJson(Map<String, dynamic>.from(json['r'] as Map)),
          span,
        );
      case 'call':
        return CallExpression(
          json['n'] as String,
          (json['a'] as List<dynamic>)
              .map((dynamic e) =>
                  Expression.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(),
          span,
        );
      case 'list':
        return ListExpression(
          (json['i'] as List<dynamic>)
              .map((dynamic e) =>
                  Expression.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(),
          span,
        );
      default:
        return LiteralExpression(EngineValue.nullValue, span);
    }
  }
}

class LiteralExpression extends Expression {
  const LiteralExpression(this.value, SourceSpan span) : super(span);

  final EngineValue value;

  @override
  EngineValue evaluate(ExpressionScope scope) => value;

  @override
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'k': 'lit', 'v': value.raw, 'sp': span.toJson()};

  @override
  String toString() => value.isString ? '"${value.asString}"' : value.asString;
}

class VariableExpression extends Expression {
  const VariableExpression(this.name, SourceSpan span) : super(span);

  final String name;

  @override
  EngineValue evaluate(ExpressionScope scope) => scope.lookup(name);

  @override
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'k': 'var', 'n': name, 'sp': span.toJson()};

  @override
  String toString() => name;
}

/// One chunk of an interpolated string: either literal text or `{expression}`.
class StringPart {
  const StringPart.text(this.text) : expression = null;
  const StringPart.expression(this.expression) : text = null;

  final String? text;
  final Expression? expression;

  bool get isText => text != null;

  Map<String, dynamic> toJson() => isText
      ? <String, dynamic>{'t': text}
      : <String, dynamic>{'e': expression!.toJson()};

  static StringPart fromJson(Map<String, dynamic> json) {
    if (json.containsKey('t')) return StringPart.text(json['t'] as String);
    return StringPart.expression(
        Expression.fromJson(Map<String, dynamic>.from(json['e'] as Map)));
  }
}

class InterpolatedStringExpression extends Expression {
  const InterpolatedStringExpression(this.parts, SourceSpan span) : super(span);

  final List<StringPart> parts;

  @override
  EngineValue evaluate(ExpressionScope scope) {
    final StringBuffer buffer = StringBuffer();
    for (final StringPart part in parts) {
      if (part.isText) {
        buffer.write(part.text);
      } else {
        buffer.write(part.expression!.evaluate(scope).asString);
      }
    }
    return EngineValue.string(buffer.toString());
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'k': 'str',
        'p': parts.map((StringPart p) => p.toJson()).toList(),
        'sp': span.toJson(),
      };

  @override
  String toString() => parts
      .map((StringPart p) => p.isText ? p.text : '{${p.expression}}')
      .join();
}

class UnaryExpression extends Expression {
  const UnaryExpression(this.operator, this.operand, SourceSpan span)
      : super(span);

  final String operator;
  final Expression operand;

  @override
  EngineValue evaluate(ExpressionScope scope) {
    final EngineValue value = operand.evaluate(scope);
    switch (operator) {
      case '!':
      case 'not':
        return EngineValue.boolean(!value.isTruthy);
      case '-':
        return value.negate();
      case '+':
        return EngineValue.number(value.asNum);
      default:
        return value;
    }
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'k': 'un',
        'o': operator,
        'e': operand.toJson(),
        'sp': span.toJson(),
      };

  @override
  String toString() => '$operator$operand';
}

class BinaryExpression extends Expression {
  const BinaryExpression(this.operator, this.left, this.right, SourceSpan span)
      : super(span);

  final String operator;
  final Expression left;
  final Expression right;

  @override
  EngineValue evaluate(ExpressionScope scope) {
    // Short-circuit logical operators.
    if (operator == '&&' || operator == 'and') {
      return EngineValue.boolean(
          left.evaluate(scope).isTruthy && right.evaluate(scope).isTruthy);
    }
    if (operator == '||' || operator == 'or') {
      return EngineValue.boolean(
          left.evaluate(scope).isTruthy || right.evaluate(scope).isTruthy);
    }

    final EngineValue a = left.evaluate(scope);
    final EngineValue b = right.evaluate(scope);
    switch (operator) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        return a / b;
      case '%':
        return a % b;
      case '==':
        return EngineValue.boolean(a.looseEquals(b));
      case '!=':
        return EngineValue.boolean(!a.looseEquals(b));
      case '>':
        return EngineValue.boolean(a.compareTo(b) > 0);
      case '>=':
        return EngineValue.boolean(a.compareTo(b) >= 0);
      case '<':
        return EngineValue.boolean(a.compareTo(b) < 0);
      case '<=':
        return EngineValue.boolean(a.compareTo(b) <= 0);
      default:
        return EngineValue.nullValue;
    }
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'k': 'bin',
        'o': operator,
        'l': left.toJson(),
        'r': right.toJson(),
        'sp': span.toJson(),
      };

  @override
  String toString() => '($left $operator $right)';
}

class CallExpression extends Expression {
  const CallExpression(this.name, this.arguments, SourceSpan span)
      : super(span);

  final String name;
  final List<Expression> arguments;

  @override
  EngineValue evaluate(ExpressionScope scope) => scope.callFunction(
        name,
        arguments.map((Expression e) => e.evaluate(scope)).toList(),
      );

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'k': 'call',
        'n': name,
        'a': arguments.map((Expression e) => e.toJson()).toList(),
        'sp': span.toJson(),
      };

  @override
  String toString() => '$name(${arguments.join(', ')})';
}

class ListExpression extends Expression {
  const ListExpression(this.items, SourceSpan span) : super(span);

  final List<Expression> items;

  @override
  EngineValue evaluate(ExpressionScope scope) => EngineValue.of(
        items.map((Expression e) => e.evaluate(scope).raw).toList(),
      );

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'k': 'list',
        'i': items.map((Expression e) => e.toJson()).toList(),
        'sp': span.toJson(),
      };

  @override
  String toString() => '[${items.join(', ')}]';
}
