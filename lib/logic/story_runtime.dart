import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../data/playback_store.dart';
import '../data/script_repository.dart';
import '../data/models/script_models.dart';
import '../data/models/playback_models.dart';
import 'chat_scheduler.dart';

class StoryRuntime extends GetxService {
  final PlaybackStore _store = Get.find<PlaybackStore>();
  final ScriptRepository _scriptRepo = Get.find<ScriptRepository>();
  final ChatScheduler _scheduler = Get.find<ChatScheduler>();

  Future<void> loadEpisode(String episodeId) async {
    // 1. Ensure Script Loaded
    await _scriptRepo.ensureEpisodeScript(episodeId);

    // 2. Ensure Runtime Initialized
    await _store.updateRuntime(variablesJson: null);

    // 3. Kickstart logic: Check all threads for current node content
    final state = await _store.getRuntimeState();
    final sceneId = state.currentSceneId;

    // Auto-play any messages in the current scene for unlocked threads.
    await _advanceThreads(sceneId);
  }

  /// Checks unlocked threads. If they have script messages > cursor, schedule them.
  Future<void> _advanceThreads(String sceneId) async {
    // 🛠️ FIX: Use .where().anyId().findAll() to satisfy Isar 3 query rules
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
