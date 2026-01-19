import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StateService extends GetxService {
  late SharedPreferences _prefs;

  // App State - Initialized as null to support the "Continue" button logic
  final RxnString currentEpisodeId = RxnString();
  final RxnString currentSceneId = RxnString();

  // Admin State
  final RxBool isAdminUnlocked = false.obs;

  Future<StateService> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Load persisted state
    currentEpisodeId.value = _prefs.getString('current_episode');
    currentSceneId.value = _prefs.getString('current_scene');
    isAdminUnlocked.value = _prefs.getBool('admin_unlocked') ?? false;
    
    // Load variables (optional: implement loop to load all 'var_' keys)
    return this;
  }

  final RxMap<String, dynamic> variables = <String, dynamic>{}.obs;

  // 🛠️ ADDED: Clear Progress for "Start Game" button
  void clearProgress() {
    currentEpisodeId.value = null;
    currentSceneId.value = null;
    variables.clear();
    
    // Clear SharedPreferences
    _prefs.remove('current_episode');
    _prefs.remove('current_scene');
    
    // Remove all stored variables
    final keys = _prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('var_')) {
        _prefs.remove(key);
      }
    }
  }

  void updateProgress(String episodeId, String sceneId) {
    currentEpisodeId.value = episodeId;
    currentSceneId.value = sceneId;
    _prefs.setString('current_episode', episodeId);
    _prefs.setString('current_scene', sceneId);
  }

  void setVariable(String key, dynamic value) {
    variables[key] = value;
    _prefs.setString('var_$key', value.toString());
  }

  void recordChoice(String choiceId) {
    print("Choice recorded: $choiceId");
  }

  void unlockAdmin() {
    isAdminUnlocked.value = true;
    _prefs.setBool('admin_unlocked', true);
  }
}
