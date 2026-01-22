// lib/services/story_engine.dart

import 'dart:async';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

import '../models/message.dart';
import '../models/choice.dart';
import 'state_service.dart';
import 'audio_service.dart';

import '../data/playback_store.dart';
import '../data/models/playback_models.dart';
import '../data/models/script_models.dart';
import '../logic/story_runtime.dart';
import '../logic/chat_scheduler.dart';

class StoryEngine extends GetxService {
  final PlaybackStore _store = Get.find<PlaybackStore>();
  final StoryRuntime _runtime = Get.find<StoryRuntime>();
  final ChatScheduler _scheduler = Get.find<ChatScheduler>();
  final AudioService _audioService = Get.find<AudioService>();
  final StateService _stateService = Get.find<StateService>();

  final RxMap<String, bool> isTyping = <String, bool>{}.obs;

  // ✅ Categorized lists for UI
  final RxList<String> messengerThreads = <String>[].obs;
  final RxList<String> makeloveThreads = <String>[].obs;

  // ✅ Proxy variables for compatibility
  final RxList<String> unlockedGlobalSecrets = <String>[].obs;

  Rx<String?> get currentEpisode => _stateService.currentEpisodeId;

  // Store active streams so we don't recreate them constantly
  final Map<String, StreamSubscription> _subscriptions = {};

  @override
  void onInit() {
    super.onInit();

    // Bind Scheduler typing state to Engine typing state (for UI)
    isTyping.bindStream(_scheduler.typingStates.stream);

    // Watch for thread unlocks to update lists
    ever(_stateService.currentSceneId, (_) => _refreshThreadLists());

    // Initial load
    final ep = _stateService.currentEpisodeId.value ?? 'ep1_the_spark';
    _runtime.loadEpisode(ep).then((_) => _refreshThreadLists());
  }

  // ✅ Compatibility Method
  String? getMetadata(String key) {
    return _stateService.variables[key]?.toString();
  }

  // ✅ Compatibility Method
  bool hasCompletedThread(String threadId) {
    // In new architecture, we might check if thread is "done" (all messages read)
    // For now, let's just check if it's unlocked.
    // Ideally, we check PlaybackStore if last message is delivered.
    return messengerThreads.contains(threadId) || makeloveThreads.contains(threadId);
  }

  /// Refreshes the thread lists (Messenger vs Makelove) based on local DB content
  Future<void> _refreshThreadLists() async {
    // 1. Get all threads that are "visible"
    // Rule: Thread is visible if it has >0 VisibleMessages OR is unlocked.
    // For now, let's just query ThreadMetas + Unlocked.

    final metas = await _store.isar.threadMetas.where().findAll();
    final state = await _store.getRuntimeState();
    final unlocked = state.unlockedThreads.toSet(); // Strings

    final newMessenger = <String>[];
    final newMakelove = <String>[];

    for (final meta in metas) {
      // Check if unlocked or has content
      final hasContent = await _store.isar.visibleMessages
          .filter()
          .threadIdEqualTo(meta.threadId)
          .count() > 0;

      if (unlocked.contains(meta.threadId) || hasContent) {
        if (meta.app == 'makelove') {
          newMakelove.add(meta.threadId);
        } else {
          newMessenger.add(meta.threadId);
        }
      }
    }

    // Safety for Daniel
    newMessenger.removeWhere((id) => id.toLowerCase() == 'daniel');

    messengerThreads.assignAll(newMessenger);
    makeloveThreads.assignAll(newMakelove);
  }

  Stream<Message?> getLastMessageStream(String threadId) {
    return getMessagesStream(threadId)
        .map((list) => list.isNotEmpty ? list.last : null);
  }

  Stream<List<Message>> getMessagesStream(String threadId) {
    // Convert Isar Stream<List<VisibleMessage>> -> Stream<List<Message>> (UI Model)
    return _store.watchMessages(threadId).map((visibleList) {
      return visibleList.map((v) => _mapToUiMessage(v)).toList();
    });
  }

  Message _mapToUiMessage(VisibleMessage v) {
    // Map VisibleMessage (DB) to Message (UI)
    return Message(
      id: v.id.toString(), // UI expects String ID
      sender: _parseSender(v.sender),
      content: v.content,
      type: _parseType(v.type),
      delay: 0, // Already delivered, delay irrelevant
      orderIndex: 0, // Order is by list position now
      sceneId: v.sceneId,
      choices: null, // TODO: Parse choicesJson if last message?
      metadata: {'dbId': v.id},
    );
  }

  Sender _parseSender(String s) {
    return Sender.values.firstWhere(
      (e) => e.toString().split('.').last == s,
      orElse: () => Sender.system,
    );
  }

  MessageType _parseType(String t) {
    return MessageType.values.firstWhere(
      (e) => e.toString().split('.').last == t,
      orElse: () => MessageType.text,
    );
  }

  /// Make a choice (UI Action)
  void makeChoice(String threadId, Choice choice) {
    // 1. Inject Nadia's response immediately into UI/DB
    final visible = VisibleMessage()
      ..threadId = threadId
      ..saveSlotId = _store.saveSlotId
      ..origin = 'choice'
      ..sender = 'nadia'
      ..content = choice.text
      ..type = 'text'
      ..deliveredAt = DateTime.now();

    _store.addVisibleMessage(visible);
    _audioService.playPing();

    // 2. Tell Runtime to handle the logic (State impact, Navigation)
    _runtime.handleChoice(threadId, choice.text, choice.targetNode);

    // 3. Ensure Thread stays visible
    _store.updateRuntime(newUnlockedThreads: [threadId]);
    _refreshThreadLists();
  }
}
