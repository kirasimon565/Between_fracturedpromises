import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StateService extends GetxService {
  late SharedPreferences _prefs;

  // App State
  final RxString currentEpisodeId = 'episode_1'.obs;
  final RxString currentSceneId = 'scene_1'.obs;

  // Admin State
  final RxBool isAdminUnlocked = false.obs;

  Future<StateService> init() async {
    _prefs = await SharedPreferences.getInstance();
    currentEpisodeId.value = _prefs.getString('current_episode') ?? 'episode_1';
    currentSceneId.value = _prefs.getString('current_scene') ?? 'scene_1';
    isAdminUnlocked.value = _prefs.getBool('admin_unlocked') ?? false;
    return this;
  }

  void updateProgress(String episodeId, String sceneId) {
    currentEpisodeId.value = episodeId;
    currentSceneId.value = sceneId;
    _prefs.setString('current_episode', episodeId);
    _prefs.setString('current_scene', sceneId);
  }

  void unlockAdmin() {
    isAdminUnlocked.value = true;
    _prefs.setBool('admin_unlocked', true);
  }
}
