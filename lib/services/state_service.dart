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

  Future<StateService> init() async {
    // Mirror Isar state to Rx variables
    _store.watchRuntimeState().listen((state) {
      currentEpisodeId.value = state.currentEpisodeId;
      currentSceneId.value = state.currentSceneId;
      if (state.variablesJson.isNotEmpty) {
        try {
          variables.assignAll(jsonDecode(state.variablesJson));
        } catch (_) {
          // ignore error
        }
      }
    });
    
    // Trigger initial load
    await _store.getRuntimeState();

    return this;
  }

  void setVariable(String key, dynamic value) {
    variables[key] = value;
    _persistVariables();
  }

  void updateProgress(String episodeId, String sceneId) {
    currentEpisodeId.value = episodeId;
    currentSceneId.value = sceneId;
    _store.updateRuntime(sceneId: sceneId); // Persist scene
    // Note: Episode ID update might need a separate method if it changes often
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

  // 🛠️ Stub for compatibility (Dead Code from old system)
  void clearProgress() {
    // TODO: Implement full reset
    variables.clear();
    updateProgress('ep1_the_spark', 'scene_1');
  }

  // 🛠️ Stub for Admin (Dead Code)
  void unlockAdmin() {
    setVariable('admin_unlocked', true);
  }
}
