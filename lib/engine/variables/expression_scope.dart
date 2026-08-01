import 'engine_value.dart';

/// Everything an expression needs in order to resolve names and call helpers.
///
/// Implemented by the runtime's execution context. Keeping it as an interface
/// means expressions can be unit tested without booting the whole engine.
abstract class ExpressionScope {
  /// Resolves a bare identifier: variables first, then flags, then
  /// relationships, then engine built-ins (`crystals`, `episode`, `time`…).
  EngineValue lookup(String name);

  /// Invokes a built-in function such as `random(1, 6)` or `has_flag("x")`.
  EngineValue callFunction(String name, List<EngineValue> arguments);
}

/// Minimal scope backed by a plain map — used in tests and by the compiler for
/// constant folding.
class MapScope implements ExpressionScope {
  MapScope([Map<String, Object?>? values])
    : _values = <String, Object?>{...?values};

  final Map<String, Object?> _values;

  @override
  EngineValue lookup(String name) =>
      EngineValue.of(_values[name.toLowerCase()]);

  @override
  EngineValue callFunction(String name, List<EngineValue> arguments) =>
      EngineValue.nullValue;
}
