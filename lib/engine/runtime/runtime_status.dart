/// Lifecycle of the interpreter.
enum RuntimeStatus {
  /// Nothing loaded yet.
  idle,

  /// Executing instructions.
  running,

  /// Sleeping on a story delay / typing indicator.
  waiting,

  /// Blocked on the player picking a choice.
  awaitingChoice,

  /// Blocked on an event (`@await`).
  awaitingSignal,

  /// Explicitly paused (app backgrounded, pause menu).
  paused,

  /// The episode reached `@end` or ran off the last instruction.
  finished,

  /// Unrecoverable error; details are on the runtime.
  error,
}

extension RuntimeStatusX on RuntimeStatus {
  bool get isBusy =>
      this == RuntimeStatus.running || this == RuntimeStatus.waiting;

  bool get isBlocked =>
      this == RuntimeStatus.awaitingChoice ||
      this == RuntimeStatus.awaitingSignal;

  bool get isTerminal =>
      this == RuntimeStatus.finished || this == RuntimeStatus.error;
}

/// A `@call` frame.
class CallFrame {
  const CallFrame(this.returnAddress, {this.kind = 'call'});

  final int returnAddress;

  /// `call`, `handler`, `async` — useful for the debug overlay.
  final String kind;

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'ret': returnAddress, 'kind': kind};

  factory CallFrame.fromJson(Map<String, dynamic> json) => CallFrame(
        (json['ret'] as num).toInt(),
        kind: json['kind'] as String? ?? 'call',
      );
}
