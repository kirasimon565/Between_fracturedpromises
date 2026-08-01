/// Small xorshift PRNG.
///
/// `dart:math`'s Random cannot be serialised, and reproducibility matters: a
/// save file must replay the same "random" beats when reloaded.
class DeterministicRandom {
  DeterministicRandom([int? seed])
      : _state = (seed ?? DateTime.now().microsecondsSinceEpoch) & 0x7FFFFFFF {
    if (_state == 0) _state = 0x2545F491;
  }

  int _state;

  int get seed => _state;

  set seed(int value) => _state = value == 0 ? 0x2545F491 : value & 0x7FFFFFFF;

  int _next() {
    int x = _state;
    x ^= (x << 13) & 0x7FFFFFFF;
    x ^= x >> 17;
    x ^= (x << 5) & 0x7FFFFFFF;
    _state = x == 0 ? 0x2545F491 : x;
    return _state;
  }

  /// Uniform double in [0, 1).
  double nextDouble() => _next() / 0x7FFFFFFF;

  /// Uniform integer in [min, max] (inclusive).
  int between(int min, int max) {
    if (max <= min) return min;
    return min + (_next() % (max - min + 1));
  }

  bool chance(num percent) => nextDouble() * 100 < percent;

  T pick<T>(List<T> items, {T? fallback}) {
    if (items.isEmpty) {
      if (fallback != null) return fallback;
      throw StateError('Cannot pick from an empty list.');
    }
    return items[_next() % items.length];
  }

  List<T> shuffled<T>(List<T> items) {
    final List<T> copy = List<T>.of(items);
    for (int i = copy.length - 1; i > 0; i--) {
      final int j = _next() % (i + 1);
      final T tmp = copy[i];
      copy[i] = copy[j];
      copy[j] = tmp;
    }
    return copy;
  }
}
