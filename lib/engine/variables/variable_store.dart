import 'engine_value.dart';

/// Mutation operators accepted by `@set`, `@add`, `@subtract`.
enum AssignmentOperator { assign, add, subtract, multiply, divide, modulo }

AssignmentOperator assignmentOperatorFromLexeme(String lexeme) {
  switch (lexeme) {
    case '+=':
      return AssignmentOperator.add;
    case '-=':
      return AssignmentOperator.subtract;
    case '*=':
      return AssignmentOperator.multiply;
    case '/=':
      return AssignmentOperator.divide;
    case '%=':
      return AssignmentOperator.modulo;
    case '=':
    default:
      return AssignmentOperator.assign;
  }
}

/// Observable key/value store for story variables.
///
/// The store is intentionally *not* Flutter aware — the Riverpod layer listens
/// to [changes] and republishes what the UI needs.
class VariableStore {
  VariableStore([Map<String, Object?>? initial]) {
    if (initial != null) {
      initial.forEach((String key, Object? value) {
        _values[_normalize(key)] = EngineValue.of(value);
      });
    }
  }

  final Map<String, EngineValue> _values = <String, EngineValue>{};
  final List<void Function(String key, EngineValue value)> _listeners =
      <void Function(String, EngineValue)>[];

  Map<String, EngineValue> get snapshot =>
      Map<String, EngineValue>.unmodifiable(_values);

  Iterable<String> get keys => _values.keys;

  int get length => _values.length;

  void addListener(void Function(String key, EngineValue value) listener) =>
      _listeners.add(listener);

  void removeListener(void Function(String key, EngineValue value) listener) =>
      _listeners.remove(listener);

  static String _normalize(String key) => key.trim().toLowerCase();

  bool has(String key) => _values.containsKey(_normalize(key));

  EngineValue get(String key) =>
      _values[_normalize(key)] ?? EngineValue.nullValue;

  num getNum(String key) => get(key).asNum;

  String getString(String key) => get(key).asString;

  bool getBool(String key) => get(key).isTruthy;

  void set(String key, Object? value) {
    final String k = _normalize(key);
    final EngineValue v = EngineValue.of(value);
    _values[k] = v;
    _notify(k, v);
  }

  /// Applies `op` to the current value and stores the result.
  EngineValue mutate(String key, AssignmentOperator op, EngineValue operand) {
    final String k = _normalize(key);
    final EngineValue current = _values[k] ?? EngineValue.zero;
    late final EngineValue next;
    switch (op) {
      case AssignmentOperator.assign:
        next = operand;
        break;
      case AssignmentOperator.add:
        next = current + operand;
        break;
      case AssignmentOperator.subtract:
        next = current - operand;
        break;
      case AssignmentOperator.multiply:
        next = current * operand;
        break;
      case AssignmentOperator.divide:
        next = current / operand;
        break;
      case AssignmentOperator.modulo:
        next = current % operand;
        break;
    }
    _values[k] = next;
    _notify(k, next);
    return next;
  }

  /// Clamps a numeric variable in place; used by relationship commands.
  EngineValue clamp(String key, num min, num max) {
    final String k = _normalize(key);
    final num value = (_values[k] ?? EngineValue.zero).asNum;
    final EngineValue clamped =
        EngineValue.number(value < min ? min : (value > max ? max : value));
    _values[k] = clamped;
    _notify(k, clamped);
    return clamped;
  }

  void remove(String key) {
    final String k = _normalize(key);
    _values.remove(k);
    _notify(k, EngineValue.nullValue);
  }

  void clear() {
    final List<String> previous = _values.keys.toList();
    _values.clear();
    for (final String key in previous) {
      _notify(key, EngineValue.nullValue);
    }
  }

  void _notify(String key, EngineValue value) {
    for (final void Function(String, EngineValue) listener
        in List<void Function(String, EngineValue)>.from(_listeners)) {
      listener(key, value);
    }
  }

  Map<String, Object?> toJson() => _values.map<String, Object?>(
      (String k, EngineValue v) => MapEntry<String, Object?>(k, v.raw));

  void restore(Map<String, Object?> json) {
    _values.clear();
    json.forEach((String key, Object? value) {
      _values[_normalize(key)] = EngineValue.of(value);
    });
  }
}
