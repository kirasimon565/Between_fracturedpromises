import 'dart:async';

/// Abstraction over "time passing" so the engine can be driven by a fake clock
/// in tests and by real timers in the app.
abstract class EngineClock {
  DateTime now();

  /// Schedules [callback] after [delay]; the returned handle can be cancelled.
  ClockHandle after(Duration delay, void Function() callback);

  /// Schedules a repeating callback.
  ClockHandle every(Duration interval, void Function() callback);
}

abstract class ClockHandle {
  bool get isActive;

  void cancel();
}

class _TimerHandle implements ClockHandle {
  _TimerHandle(this._timer);

  final Timer _timer;

  @override
  bool get isActive => _timer.isActive;

  @override
  void cancel() => _timer.cancel();
}

/// Real wall-clock implementation used by the game.
class SystemClock implements EngineClock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();

  @override
  ClockHandle after(Duration delay, void Function() callback) =>
      _TimerHandle(Timer(delay, callback));

  @override
  ClockHandle every(Duration interval, void Function() callback) =>
      _TimerHandle(Timer.periodic(interval, (Timer _) => callback()));
}

/// Deterministic clock for unit tests: nothing fires until [advance] is called.
class FakeClock implements EngineClock {
  FakeClock([DateTime? start])
    : _now = start ?? DateTime.fromMillisecondsSinceEpoch(0);

  DateTime _now;
  int _nextId = 0;
  final Map<int, _FakeTask> _tasks = <int, _FakeTask>{};

  @override
  DateTime now() => _now;

  @override
  ClockHandle after(Duration delay, void Function() callback) {
    final int id = _nextId++;
    _tasks[id] = _FakeTask(_now.add(delay), callback, null);
    return _FakeHandle(this, id);
  }

  @override
  ClockHandle every(Duration interval, void Function() callback) {
    final int id = _nextId++;
    _tasks[id] = _FakeTask(_now.add(interval), callback, interval);
    return _FakeHandle(this, id);
  }

  int get pendingCount => _tasks.length;

  /// Moves time forward, firing everything scheduled in that window.
  void advance(Duration duration) {
    final DateTime target = _now.add(duration);
    while (true) {
      final List<MapEntry<int, _FakeTask>> due =
          _tasks.entries
              .where(
                (MapEntry<int, _FakeTask> e) => !e.value.at.isAfter(target),
              )
              .toList()
            ..sort(
              (MapEntry<int, _FakeTask> a, MapEntry<int, _FakeTask> b) =>
                  a.value.at.compareTo(b.value.at),
            );
      if (due.isEmpty) break;
      final MapEntry<int, _FakeTask> entry = due.first;
      _now = entry.value.at;
      final Duration? interval = entry.value.interval;
      if (interval == null) {
        _tasks.remove(entry.key);
      } else {
        _tasks[entry.key] = _FakeTask(
          _now.add(interval),
          entry.value.callback,
          interval,
        );
      }
      entry.value.callback();
    }
    _now = target;
  }

  void _cancel(int id) => _tasks.remove(id);

  bool _isActive(int id) => _tasks.containsKey(id);
}

class _FakeTask {
  _FakeTask(this.at, this.callback, this.interval);

  final DateTime at;
  final void Function() callback;
  final Duration? interval;
}

class _FakeHandle implements ClockHandle {
  _FakeHandle(this._clock, this._id);

  final FakeClock _clock;
  final int _id;

  @override
  bool get isActive => _clock._isActive(_id);

  @override
  void cancel() => _clock._cancel(_id);
}
