import 'package:flutter/material.dart'; // Added for debugPrint
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../data/playback_store.dart';
import '../data/script_repository.dart';
import '../data/models/script_models.dart';
import '../data/models/playback_models.dart';
import '../app/routes.dart'; // Added to navigate to Coming Soon
import 'chat_scheduler.dart';

class StoryRuntime extends GetxService {
  final PlaybackStore _store = Get.find<PlaybackStore>();
  final ScriptRepository _scriptRepo = Get.find<ScriptRepository>();
  final ChatScheduler _scheduler = Get.find<ChatScheduler>();

  Future<void> loadEpisode(String episodeId) async {
    await _scriptRepo.ensureEpisodeScript(episodeId);
    await _store.updateRuntime(variablesJson: null);
    final state = await _store.getRuntimeState();
    final sceneId = state.currentSceneId;
    await _advanceThreads(sceneId);
  }

  Future<void> _advanceThreads(String sceneId) async {
    final allThreads = await _store.isar.threadMetas.where().anyId().findAll();
    for (final meta in allThreads) {
      await _advanceThread(meta.threadId, sceneId);
    }
  }

  Future<void> _advanceThread(String threadId, String sceneId) async {
    final threadState = await _store.getThreadState(threadId);
    final scriptMsgs = await _scriptRepo.getScript(threadId, sceneId);
    final int currentCursor = threadState.cursor;
    final newMsgs = scriptMsgs.where((m) => m.orderIndex >= currentCursor).toList();

    if (newMsgs.isNotEmpty) {
      await _scheduler.scheduleBurst(threadId, newMsgs);
      final lastIndex = newMsgs.last.orderIndex;
      await _store.updateThreadCursor(threadId, lastIndex + 1, sceneId: sceneId);
    }
  }

  Future<void> handleChoice(String threadId, String choiceText, String targetNodeId) async {
    // 1. Check if the target node actually exists in our Local Isar Repository
    // This prevents the game from hanging if Jules hasn't uploaded the next part.
    final bool sceneExists = await _scriptRepo.doesSceneExist(targetNodeId);

    if (!sceneExists || targetNodeId.isEmpty) {
      debugPrint("🌊 [STORY ENGINE]: Target Node '$targetNodeId' not found. Sending to Coming Soon.");
      Get.toNamed(AppRoutes.comingSoon); 
      return;
    }

    final state = await _store.getRuntimeState();
    final oldScene = state.currentSceneId;

    if (targetNodeId != oldScene) {
      await _store.updateRuntime(sceneId: targetNodeId);
      await _advanceThreads(targetNodeId);
    } else {
      await _advanceThreads(targetNodeId);
    }
  }
}
