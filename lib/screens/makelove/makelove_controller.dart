import 'package:get/get.dart';
import '../../services/story_engine.dart';
import '../../services/audio_service.dart';
import '../../theme/theme.dart';

class MakeloveController extends GetxController {
  final StoryEngine _engine = Get.find<StoryEngine>();
  final AudioService _audio = Get.find<AudioService>();
  final ThemeService _theme = Get.find<ThemeService>();

  // 🛠️ Track if the "LIVE" pulse should be active globally
  var isLiveSession = false.obs;

  // 🛠️ Track the current crimson intensity for UI effects
  var glowIntensity = 0.5.obs;

  @override
  void onInit() {
    super.onInit();
    // Automatically enable Secret Mode theme when this controller is active
    _theme.setSecretMode(true);
  }

  @override
  void onClose() {
    // Revert to standard mode when leaving Makelove
    _theme.setSecretMode(false);
    super.onClose();
  }

  // 🛠️ Logic for the "Heart" action (The advanced version of choices)
  void triggerHeartAction(String threadId) {
    // 🔊 Crimson tactile feedback
    _audio.playVibrate();
    
    // Logic to open the advanced Choice Rope
    isLiveSession.value = true;
  }

  // 🛠️ Logic to filter "Makelove-only" characters (like Daniel)
  List<String> get makeloveThreads {
    // Filters active threads to only show those belonging to the Makelove app
    return _engine.activeThreadIds
        .where((id) => id.toLowerCase() == 'daniel' || id.toLowerCase() == 'secret_contact')
        .toList();
  }

  // 🛠️ Signal strength simulation logic (for the "NO SIGNAL" design)
  double getSignalStrength(String threadId) {
    // This could be tied to story variables in the future
    return 0.8;
  }
}
