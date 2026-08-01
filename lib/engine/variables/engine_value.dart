import 'dart:convert';

/// Dynamic value used by the DSL.
///
/// The engine deliberately keeps a very small type system — numbers, strings,
/// booleans, lists and maps — because everything must survive a JSON round trip
/// when a save slot is written to Drift.
class EngineValue implements Comparable<EngineValue> {
  const EngineValue._(this.raw);

  final Object? raw;

  static const EngineValue nullValue = EngineValue._(null);
  static const EngineValue trueValue = EngineValue._(true);
  static const EngineValue falseValue = EngineValue._(false);
  static const EngineValue zero = EngineValue._(0);
  static const EngineValue emptyString = EngineValue._('');

  factory EngineValue.of(Object? value) {
    if (value == null) return nullValue;
    if (value is EngineValue) return value;
    if (value is bool) return value ? trueValue : falseValue;
    if (value is num) return EngineValue._(value);
    if (value is String) return EngineValue._(value);
    if (value is List) {
      return EngineValue._(
        value.map((Object? e) => EngineValue.of(e).raw).toList(),
      );
    }
    if (value is Map) {
      return EngineValue._(
        value.map<String, Object?>(
          (Object? k, Object? v) =>
              MapEntry<String, Object?>(k.toString(), EngineValue.of(v).raw),
        ),
      );
    }
    return EngineValue._(value.toString());
  }

  /// Const constructors so literal expressions can live in `const` contexts.
  const EngineValue.number(num value) : raw = value;
  const EngineValue.string(String value) : raw = value;
  const EngineValue.boolean(bool value) : raw = value;

  bool get isNull => raw == null;
  bool get isNum => raw is num;
  bool get isString => raw is String;
  bool get isBool => raw is bool;
  bool get isList => raw is List;
  bool get isMap => raw is Map;

  /// Truthiness rules: `null` and `false` are false, `0` is false, `""` is
  /// false, empty collections are false, everything else is true.
  bool get isTruthy {
    final Object? v = raw;
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final String s = v.trim().toLowerCase();
      if (s.isEmpty || s == 'false' || s == 'no' || s == '0' || s == 'off') {
        return false;
      }
      return true;
    }
    if (v is List) return v.isNotEmpty;
    if (v is Map) return v.isNotEmpty;
    return true;
  }

  num get asNum {
    final Object? v = raw;
    if (v is num) return v;
    if (v is bool) return v ? 1 : 0;
    if (v is String) return num.tryParse(v.trim()) ?? 0;
    if (v is List) return v.length;
    if (v is Map) return v.length;
    return 0;
  }

  int get asInt => asNum.round();

  double get asDouble => asNum.toDouble();

  bool get asBool => isTruthy;

  String get asString {
    final Object? v = raw;
    if (v == null) return '';
    if (v is String) return v;
    if (v is num) {
      if (v is int) return v.toString();
      if (v == v.roundToDouble() && v.abs() < 1e15) {
        return v.toInt().toString();
      }
      return v.toString();
    }
    if (v is bool) return v ? 'true' : 'false';
    return jsonEncode(v);
  }

  List<EngineValue> get asList {
    final Object? v = raw;
    if (v is List) {
      return v.map<EngineValue>((Object? e) => EngineValue.of(e)).toList();
    }
    if (v == null) return <EngineValue>[];
    return <EngineValue>[this];
  }

  Map<String, EngineValue> get asMap {
    final Object? v = raw;
    if (v is Map) {
      return v.map<String, EngineValue>(
        (Object? k, Object? value) =>
            MapEntry<String, EngineValue>(k.toString(), EngineValue.of(value)),
      );
    }
    return <String, EngineValue>{};
  }

  // ── Arithmetic ──────────────────────────────────────────────────────────

  EngineValue operator +(EngineValue other) {
    if (isString || other.isString) {
      // String concatenation only when neither side parses as a number.
      final bool numeric =
          (isNum || num.tryParse(asString) != null) &&
          (other.isNum || num.tryParse(other.asString) != null);
      if (!numeric) return EngineValue.string(asString + other.asString);
    }
    if (isList) {
      return EngineValue.of(<Object?>[
        ...asList.map((EngineValue e) => e.raw),
        other.raw,
      ]);
    }
    return EngineValue.number(asNum + other.asNum);
  }

  EngineValue operator -(EngineValue other) =>
      EngineValue.number(asNum - other.asNum);

  EngineValue operator *(EngineValue other) =>
      EngineValue.number(asNum * other.asNum);

  EngineValue operator /(EngineValue other) {
    final num divisor = other.asNum;
    if (divisor == 0) return zero;
    return EngineValue.number(asNum / divisor);
  }

  EngineValue operator %(EngineValue other) {
    final num divisor = other.asNum;
    if (divisor == 0) return zero;
    return EngineValue.number(asNum % divisor);
  }

  EngineValue negate() => EngineValue.number(-asNum);

  // ── Comparison ──────────────────────────────────────────────────────────

  @override
  int compareTo(EngineValue other) {
    if (isNum || other.isNum) {
      return asNum.compareTo(other.asNum);
    }
    return asString.compareTo(other.asString);
  }

  bool looseEquals(EngineValue other) {
    if (isNull && other.isNull) return true;
    if (isNull || other.isNull) return false;
    if (isBool || other.isBool) return isTruthy == other.isTruthy;
    if (isNum && other.isNum) return asNum == other.asNum;
    if (isNum || other.isNum) {
      final num? a = isNum ? asNum : num.tryParse(asString);
      final num? b = other.isNum ? other.asNum : num.tryParse(other.asString);
      if (a != null && b != null) return a == b;
    }
    return asString.toLowerCase() == other.asString.toLowerCase();
  }

  Object? toJson() => raw;

  @override
  bool operator ==(Object other) => other is EngineValue && looseEquals(other);

  @override
  int get hashCode => raw is num ? (raw! as num).hashCode : asString.hashCode;

  @override
  String toString() => asString;
}
