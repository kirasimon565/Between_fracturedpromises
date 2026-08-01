import 'dart:convert';

import '../events/engine_event.dart';
import '../runtime/runtime_status.dart';

/// Everything required to resume a run byte-for-byte.
///
/// The snapshot is intentionally JSON-shaped: Drift stores it as a single text
/// column in `runtime_checkpoints`, while the normalised tables (variables,
/// flags, relationships…) keep a queryable projection for the UI.
class EngineSnapshot {
  const EngineSnapshot({
    required this.episodeId,
    required this.programId,
    required this.programCounter,
    required this.label,
    required this.line,
    required this.status,
    required this.callStack,
    required this.handlers,
    required this.randomSeed,
    required this.gameState,
    required this.scheduledLabels,
    required this.savedAt,
    this.version = currentVersion,
  });

  static const int currentVersion = 2;

  final String episodeId;
  final String programId;

  /// The single most important number in the save file.
  final int programCounter;

  /// Human readable position (`:: scene_claire_probes`).
  final String label;
  final int line;
  final RuntimeStatus status;
  final List<CallFrame> callStack;
  final List<EventHandlerRegistration> handlers;
  final int randomSeed;
  final Map<String, dynamic> gameState;
  final List<Map<String, dynamic>> scheduledLabels;
  final DateTime savedAt;
  final int version;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'v': version,
        'episode': episodeId,
        'program': programId,
        'pc': programCounter,
        'label': label,
        'line': line,
        'status': status.name,
        'stack': callStack.map((CallFrame f) => f.toJson()).toList(),
        'handlers': handlers
            .map((EventHandlerRegistration h) => h.toJson())
            .toList(),
        'seed': randomSeed,
        'state': gameState,
        'timers': scheduledLabels,
        'savedAt': savedAt.millisecondsSinceEpoch,
      };

  String encode() => jsonEncode(toJson());

  factory EngineSnapshot.fromJson(Map<String, dynamic> json) => EngineSnapshot(
        version: (json['v'] as num?)?.toInt() ?? 1,
        episodeId: json['episode'] as String? ?? '',
        programId: json['program'] as String? ?? '',
        programCounter: (json['pc'] as num?)?.toInt() ?? 0,
        label: json['label'] as String? ?? '',
        line: (json['line'] as num?)?.toInt() ?? 0,
        status: RuntimeStatus.values.firstWhere(
          (RuntimeStatus s) => s.name == json['status'],
          orElse: () => RuntimeStatus.running,
        ),
        callStack: (json['stack'] as List<dynamic>? ?? const <dynamic>[])
            .map((dynamic e) =>
                CallFrame.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        handlers: (json['handlers'] as List<dynamic>? ?? const <dynamic>[])
            .map((dynamic e) => EventHandlerRegistration.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList(),
        randomSeed: (json['seed'] as num?)?.toInt() ?? 1,
        gameState: Map<String, dynamic>.from(
            (json['state'] as Map?) ?? const <String, dynamic>{}),
        scheduledLabels:
            (json['timers'] as List<dynamic>? ?? const <dynamic>[])
                .map((dynamic e) => Map<String, dynamic>.from(e as Map))
                .toList(),
        savedAt: DateTime.fromMillisecondsSinceEpoch(
            (json['savedAt'] as num?)?.toInt() ??
                DateTime.now().millisecondsSinceEpoch),
      );

  factory EngineSnapshot.decode(String source) =>
      EngineSnapshot.fromJson(Map<String, dynamic>.from(
          jsonDecode(source) as Map));

  /// Short description used on save-slot cards.
  String get positionLabel =>
      label.isEmpty ? 'Line $line' : label.replaceAll('_', ' ');
}
