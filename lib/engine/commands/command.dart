import 'dart:async';

import '../lexer/source_span.dart';
import '../parser/ast.dart';
import '../parser/expression.dart';
import '../runtime/engine_api.dart';
import '../variables/engine_value.dart';

/// What the runtime should do after a command finished.
enum CommandOutcomeType { next, jump, wait, waitForSignal, halt, error }

class CommandOutcome {
  const CommandOutcome._(
    this.type, {
    this.address,
    this.label,
    this.duration,
    this.signal,
    this.message,
  });

  final CommandOutcomeType type;
  final int? address;
  final String? label;
  final Duration? duration;
  final String? signal;
  final String? message;

  /// Continue with the next instruction.
  static const CommandOutcome next = CommandOutcome._(CommandOutcomeType.next);

  /// Jump to a label (resolved by the runtime).
  static CommandOutcome jump(String label) =>
      CommandOutcome._(CommandOutcomeType.jump, label: label);

  static CommandOutcome jumpTo(int address) =>
      CommandOutcome._(CommandOutcomeType.jump, address: address);

  /// Advance, then pause the runtime for [duration].
  ///
  /// Advancing *before* waiting keeps commands idempotent: a save taken during
  /// the pause resumes on the following instruction instead of replaying this
  /// one.
  static CommandOutcome wait(Duration duration) =>
      CommandOutcome._(CommandOutcomeType.wait, duration: duration);

  /// Advance, then block until [signal] is emitted on the event bus.
  static CommandOutcome waitFor(String signal, {Duration? timeout}) =>
      CommandOutcome._(
        CommandOutcomeType.waitForSignal,
        signal: signal,
        duration: timeout,
      );

  static CommandOutcome halt([String? reason]) =>
      CommandOutcome._(CommandOutcomeType.halt, message: reason);

  static CommandOutcome error(String message) =>
      CommandOutcome._(CommandOutcomeType.error, message: message);
}

/// Everything a handler needs for one invocation.
class CommandContext {
  CommandContext({
    required this.engine,
    required this.name,
    required this.arguments,
    required this.span,
  });

  final EngineApi engine;
  final String name;
  final ArgumentList arguments;
  final SourceSpan span;

  // ── Positional access ───────────────────────────────────────────────────

  bool get isEmpty => arguments.isEmpty;

  int get count => arguments.positional.length;

  EngineValue value(int index) =>
      engine.evaluate(arguments.positionalAt(index));

  String str(int index, [String fallback = '']) {
    final Expression? expression = arguments.positionalAt(index);
    if (expression == null) return fallback;
    final String result = engine.text(expression);
    return result.isEmpty ? fallback : result;
  }

  String id(int index, [String fallback = '']) =>
      str(index, fallback).trim().toLowerCase();

  num number(int index, [num fallback = 0]) {
    final Expression? expression = arguments.positionalAt(index);
    if (expression == null) return fallback;
    final EngineValue value = engine.evaluate(expression);
    if (value.isNull) return fallback;
    return value.asNum;
  }

  int integer(int index, [int fallback = 0]) => number(index, fallback).round();

  bool flag(int index, [bool fallback = true]) {
    final Expression? expression = arguments.positionalAt(index);
    if (expression == null) return fallback;
    return engine.evaluate(expression).isTruthy;
  }

  // ── Named access ────────────────────────────────────────────────────────

  bool has(String key) => arguments.hasNamed(key);

  EngineValue named(String key) => engine.evaluate(arguments.namedOrNull(key));

  String namedStr(String key, [String fallback = '']) {
    final Expression? expression = arguments.namedOrNull(key);
    if (expression == null) return fallback;
    final String result = engine.text(expression);
    return result.isEmpty ? fallback : result;
  }

  String? namedStrOrNull(String key) {
    final Expression? expression = arguments.namedOrNull(key);
    if (expression == null) return null;
    final String result = engine.text(expression);
    return result.isEmpty ? null : result;
  }

  num namedNum(String key, [num fallback = 0]) {
    final Expression? expression = arguments.namedOrNull(key);
    if (expression == null) return fallback;
    return engine.evaluate(expression).asNum;
  }

  int namedInt(String key, [int fallback = 0]) =>
      namedNum(key, fallback).round();

  bool namedBool(String key, [bool fallback = false]) {
    final Expression? expression = arguments.namedOrNull(key);
    if (expression == null) return fallback;
    return engine.evaluate(expression).isTruthy;
  }

  Duration namedDuration(String key, Duration fallback) {
    final Expression? expression = arguments.namedOrNull(key);
    if (expression == null) return fallback;
    final num seconds = engine.evaluate(expression).asNum;
    return Duration(milliseconds: (seconds * 1000).round());
  }

  /// First positional value, or the named `value` argument.
  String get primary => str(0, namedStr('value'));
}

/// Base class for every command implementation.
abstract class CommandHandler {
  const CommandHandler();

  /// Canonical name first, then aliases.
  List<String> get names;

  FutureOr<CommandOutcome> execute(CommandContext context);
}

/// Adapter so commands can be declared as plain functions.
class FunctionCommand extends CommandHandler {
  const FunctionCommand(this.names, this._body);

  @override
  final List<String> names;

  final FutureOr<CommandOutcome> Function(CommandContext context) _body;

  @override
  FutureOr<CommandOutcome> execute(CommandContext context) => _body(context);
}

/// Name → handler map. Plugins register into the same registry, which is why
/// new commands never require engine changes.
class CommandRegistry {
  final Map<String, CommandHandler> _handlers = <String, CommandHandler>{};

  Iterable<String> get names => _handlers.keys;

  int get length => _handlers.length;

  void register(CommandHandler handler) {
    for (final String name in handler.names) {
      _handlers[name.toLowerCase()] = handler;
    }
  }

  void registerAll(Iterable<CommandHandler> handlers) {
    for (final CommandHandler handler in handlers) {
      register(handler);
    }
  }

  void registerFunction(
    List<String> names,
    FutureOr<CommandOutcome> Function(CommandContext context) body,
  ) => register(FunctionCommand(names, body));

  bool contains(String name) => _handlers.containsKey(name.toLowerCase());

  CommandHandler? lookup(String name) => _handlers[name.toLowerCase()];

  void unregister(String name) => _handlers.remove(name.toLowerCase());
}
