// lib/services/state_service.dart

import 'dart:convert';
import 'package:get/get.dart';
import '../data/playback_store.dart';

class StateService extends GetxService {
  final PlaybackStore _store = Get.find<PlaybackStore>();

  // Reactive state variables
  final RxString currentEpisodeId = 'ep1_the_spark'.obs;
  final RxString currentSceneId = 'scene_1'.obs;
  final RxMap<String, dynamic> variables = <String, dynamic>{}.obs;

  // New: Reactive list of unlocked thread metas for UI filtering
  final RxList<ThreadMeta> unlockedThreadMetas = <ThreadMeta>[].obs;

  Future<StateService> init() async {
    // Mirror Isar state to Rx variables
    _store.watchRuntimeState().listen((state) async {
      currentEpisodeId.value = state.currentEpisodeId;
      currentSceneId.value = state.currentSceneId;
      if (state.variablesJson.isNotEmpty) {
        try {
          variables.assignAll(jsonDecode(state.variablesJson));
        } catch (_) {
          // ignore error
        }
      }

      // Update unlocked metas when state changes
      await _refreshUnlockedMetas(state.unlockedThreads);
    });
    
    // Trigger initial load
    await _store.getRuntimeState();

    return this;
  }

  Future<void> _refreshUnlockedMetas(List<String> unlockedIds) async {
    final metas = <ThreadMeta>[];
    for (final id in unlockedIds) {
      final meta = await _store.getThreadMeta(id); // Helper we need to add to Store
      if (meta != null) {
        metas.add(meta);
      }
    }
    unlockedThreadMetas.assignAll(metas);
  }

  void setVariable(String key, dynamic value) {
    variables[key] = value;
    _persistVariables();
  }

  void updateProgress(String episodeId, String sceneId) {
    currentEpisodeId.value = episodeId;
    currentSceneId.value = sceneId;
    _store.updateRuntime(sceneId: sceneId);
  }

  void recordChoice(String choiceId) {
    final List<dynamic> history = variables['choice_history'] ?? [];
    if (!history.contains(choiceId)) {
      history.add(choiceId);
      variables['choice_history'] = history;
      _persistVariables();
    }
  }

  void _persistVariables() {
    _store.updateRuntime(variablesJson: jsonEncode(variables));
  }
}
