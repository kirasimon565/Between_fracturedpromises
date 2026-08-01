import '../engine_defaults.dart';
import '../runtime/engine_api.dart';
import '../state/chat.dart';
import 'command.dart';

/// Shared plumbing used by the built-in command families.
extension CommandContextHelpers on CommandContext {
  EngineApi get e => engine;

  /// Id of the character the player embodies (scripts may override it).
  String get playerId {
    final String configured = engine.variables.getString(
      EngineDefaults.playerIdVariable,
    );
    return configured.isEmpty
        ? EngineDefaults.playerCharacterId
        : configured.toLowerCase();
  }

  bool isPlayer(String characterId) => characterId.toLowerCase() == playerId;

  /// Which app the current scene belongs to.
  String get currentApp {
    final String named = namedStr('app');
    if (named.isNotEmpty) return named.toLowerCase();
    final String? active = engine.state.phone.currentApp;
    if (active != null && active.isNotEmpty) return active;
    return CommandContextHelpers.appForScene(engine.state.currentScene);
  }

  /// Derives an app id from a scene name such as `makelove_chat`.
  static String appForScene(String scene) {
    final String s = scene.toLowerCase();
    if (s.contains('makelove')) return 'makelove';
    if (s.contains('browser') || s.contains('web')) return 'browser';
    if (s.contains('gallery')) return 'gallery';
    if (s.contains('call')) return 'calls';
    if (s.contains('sms')) return 'sms';
    return EngineDefaults.defaultApp;
  }

  /// Resolves the thread a message belongs to.
  ///
  /// Priority: explicit `thread`/`app` arguments → the sender's own thread →
  /// the currently open conversation.
  String resolveThreadId(String senderId) {
    final String explicit = namedStr('thread');
    if (explicit.isNotEmpty) return explicit.toLowerCase();

    final String sender = senderId.toLowerCase();
    final bool systemish =
        sender == EngineDefaults.systemCharacterId ||
        sender == EngineDefaults.narratorCharacterId ||
        sender.isEmpty;

    if (systemish || isPlayer(sender)) {
      final String? active = engine.state.activeThreadId;
      if (active != null && active.isNotEmpty) return active;
      return systemish ? 'system' : playerId;
    }
    return sender;
  }

  /// Ensures the thread exists and returns it.
  ChatThread openThread(String threadId, {String? app, String? title}) {
    final ChatThread thread = engine.state.ensureThread(
      threadId,
      app: app ?? currentApp,
      title: title ?? engine.state.character(threadId)?.name,
      participants: <String>{threadId, playerId}.toList(),
      avatar: engine.state.character(threadId)?.avatar,
    );
    return thread;
  }

  /// Human reading pace for a line of dialogue.
  Duration readingTime(String text) {
    final int ms = text.length * EngineDefaults.msPerCharacter;
    final Duration raw = Duration(milliseconds: ms);
    final Duration clamped = raw < EngineDefaults.minMessagePause
        ? EngineDefaults.minMessagePause
        : (raw > EngineDefaults.maxMessagePause
              ? EngineDefaults.maxMessagePause
              : raw);
    return engine.pace(clamped);
  }

  /// Monotonic-ish unique id (deterministic across a replay).
  String uid(String prefix) =>
      '${prefix}_${engine.programCounter}_${engine.random.between(1000, 9999)}';
}
