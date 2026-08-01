import 'engine_clock.dart';

/// A task the scheduler is holding on to.
class ScheduledTask {
  ScheduledTask({
    required this.id,
    required this.callback,
    required this.deadline,
    required this.total,
    this.repeatEvery,
    this.tag,
  });

  final String id;
  final void Function() callback;

  /// Wall-clock moment the task should fire.
  DateTime deadline;

  /// Original duration (used when re-arming after a pause).
  Duration total;
  final Duration? repeatEvery;
  final String? tag;

  ClockHandle? handle;

  /// Remaining time captured while paused.
  Duration? remaining;

  bool get isRepeating => repeatEvery != null;
}

/// Central timer service for the engine.
///
/// Everything time-based goes through here — story delays, typing indicators,
/// timed choices, background events — which means a single [pause] call freezes
/// the whole simulation (used when the app goes to the background or the player
/// opens the pause menu).
class EngineScheduler {
  EngineScheduler({EngineClock? clock}) : clock = clock ?? const SystemClock();

  final EngineClock clock;

  final Map<String, ScheduledTask> _tasks = <String, ScheduledTask>{};
  int _counter = 0;
  bool _paused = false;

  bool get isPaused => _paused;

  int get pendingCount => _tasks.length;

  Iterable<ScheduledTask> get tasks => _tasks.values;

  String _nextId(String prefix) => '${prefix}_${_counter++}';

  /// Runs [callback] once after [delay]. Returns the task id.
  String after(
    Duration delay,
    void Function() callback, {
    String? id,
    String? tag,
  }) {
    final String taskId = id ?? _nextId('task');
    cancel(taskId);
    final ScheduledTask task = ScheduledTask(
      id: taskId,
      callback: callback,
      deadline: clock.now().add(delay),
      total: delay,
      tag: tag,
    );
    _tasks[taskId] = task;
    if (_paused) {
      task.remaining = delay;
    } else {
      _arm(task, delay);
    }
    return taskId;
  }

  /// Runs [callback] every [interval] until cancelled (background timers).
  String every(
    Duration interval,
    void Function() callback, {
    String? id,
    String? tag,
  }) {
    final String taskId = id ?? _nextId('repeat');
    cancel(taskId);
    final ScheduledTask task = ScheduledTask(
      id: taskId,
      callback: callback,
      deadline: clock.now().add(interval),
      total: interval,
      repeatEvery: interval,
      tag: tag,
    );
    _tasks[taskId] = task;
    if (_paused) {
      task.remaining = interval;
    } else {
      _armRepeating(task, interval);
    }
    return taskId;
  }

  void _arm(ScheduledTask task, Duration delay) {
    task.deadline = clock.now().add(delay);
    task.handle = clock.after(delay, () {
      _tasks.remove(task.id);
      task.callback();
    });
  }

  void _armRepeating(ScheduledTask task, Duration first) {
    task.deadline = clock.now().add(first);
    task.handle = clock.after(first, () {
      task.callback();
      if (_tasks.containsKey(task.id)) {
        _armRepeating(task, task.repeatEvery!);
      }
    });
  }

  bool cancel(String id) {
    final ScheduledTask? task = _tasks.remove(id);
    task?.handle?.cancel();
    return task != null;
  }

  void cancelTag(String tag) {
    for (final ScheduledTask task in _tasks.values.toList()) {
      if (task.tag == tag) cancel(task.id);
    }
  }

  void cancelAll() {
    for (final ScheduledTask task in _tasks.values.toList()) {
      task.handle?.cancel();
    }
    _tasks.clear();
  }

  /// Freezes every pending task, remembering how much time each had left.
  void pause() {
    if (_paused) return;
    _paused = true;
    final DateTime now = clock.now();
    for (final ScheduledTask task in _tasks.values) {
      final Duration left = task.deadline.difference(now);
      task.remaining = left.isNegative ? Duration.zero : left;
      task.handle?.cancel();
      task.handle = null;
    }
  }

  /// Re-arms everything that was frozen by [pause].
  void resume() {
    if (!_paused) return;
    _paused = false;
    for (final ScheduledTask task in _tasks.values.toList()) {
      final Duration left = task.remaining ?? task.total;
      task.remaining = null;
      if (task.isRepeating) {
        _armRepeating(task, left);
      } else {
        _arm(task, left);
      }
    }
  }

  /// Serialisable view of story-level timers (used by the save system).
  List<Map<String, dynamic>> snapshotTagged(String tag) {
    final DateTime now = clock.now();
    return _tasks.values
        .where((ScheduledTask t) => t.tag == tag)
        .map((ScheduledTask t) => <String, dynamic>{
              'id': t.id,
              'remainingMs': (t.remaining ?? t.deadline.difference(now))
                  .inMilliseconds
                  .clamp(0, 1 << 31),
              'repeatMs': t.repeatEvery?.inMilliseconds,
            })
        .toList();
  }
}
