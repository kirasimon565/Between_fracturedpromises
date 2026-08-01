import 'dart:async';

/// A named signal flowing through the engine.
///
/// Events are the glue between the script (`@emit`, `@on`, `@await`), the
/// runtime (choice made, message sent, episode finished) and the UI layer
/// (player tapped an app icon, download finished).
class EngineEvent {
  EngineEvent(this.name, {Map<String, Object?>? data, this.source = 'engine'})
    : data = data ?? const <String, Object?>{},
      timestamp = DateTime.now();

  final String name;
  final Map<String, Object?> data;
  final String source;
  final DateTime timestamp;

  Object? operator [](String key) => data[key];

  @override
  String toString() => 'EngineEvent($name, $data)';
}

/// Well-known event names emitted by the engine itself.
abstract final class EngineEvents {
  static const String episodeStarted = 'episode_started';
  static const String episodeFinished = 'episode_finished';
  static const String labelEntered = 'label_entered';
  static const String messageSent = 'message_sent';
  static const String choicePresented = 'choice_presented';
  static const String choiceMade = 'choice_made';
  static const String choiceRejected = 'choice_rejected';
  static const String flagSet = 'flag_set';
  static const String variableChanged = 'variable_changed';
  static const String relationshipChanged = 'relationship_changed';
  static const String appInstalled = 'app_installed';
  static const String appOpened = 'app_opened';
  static const String notificationPosted = 'notification_posted';
  static const String browserVisited = 'browser_visited';
  static const String downloadFinished = 'download_finished';
  static const String achievementUnlocked = 'achievement_unlocked';
  static const String galleryUnlocked = 'gallery_unlocked';
  static const String crystalsSpent = 'crystals_spent';
  static const String crystalsGranted = 'crystals_granted';
  static const String checkpoint = 'checkpoint';
  static const String runtimeError = 'runtime_error';
}

/// Simple broadcast bus with support for one-shot awaits.
class EventBus {
  final StreamController<EngineEvent> _controller =
      StreamController<EngineEvent>.broadcast();

  final List<EngineEvent> _history = <EngineEvent>[];
  static const int _historyLimit = 200;

  Stream<EngineEvent> get stream => _controller.stream;

  List<EngineEvent> get history => List<EngineEvent>.unmodifiable(_history);

  bool get isClosed => _controller.isClosed;

  void emit(EngineEvent event) {
    if (_controller.isClosed) return;
    _history.add(event);
    if (_history.length > _historyLimit) {
      _history.removeAt(0);
    }
    _controller.add(event);
  }

  void emitNamed(String name, {Map<String, Object?>? data}) =>
      emit(EngineEvent(name, data: data));

  Stream<EngineEvent> on(String name) =>
      _controller.stream.where((EngineEvent e) => e.name == name);

  Future<EngineEvent> next(String name, {Duration? timeout}) {
    final Future<EngineEvent> future = on(name).first;
    if (timeout == null) return future;
    return future.timeout(
      timeout,
      onTimeout: () => EngineEvent('${name}_timeout'),
    );
  }

  void dispose() {
    _controller.close();
  }
}

/// A `@on <event>` block registered by the script.
class EventHandlerRegistration {
  EventHandlerRegistration({
    required this.event,
    required this.address,
    required this.once,
  });

  final String event;
  final int address;
  final bool once;
  bool consumed = false;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'event': event,
    'address': address,
    'once': once,
    'consumed': consumed,
  };

  factory EventHandlerRegistration.fromJson(Map<String, dynamic> json) {
    final EventHandlerRegistration registration = EventHandlerRegistration(
      event: json['event'] as String,
      address: (json['address'] as num).toInt(),
      once: json['once'] as bool? ?? false,
    );
    registration.consumed = json['consumed'] as bool? ?? false;
    return registration;
  }
}
