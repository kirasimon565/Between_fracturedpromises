import 'package:get/get.dart';
import '../../data/playback_store.dart';

class ProfileController extends GetxController {
  final PlaybackStore _store = Get.find<PlaybackStore>();

  // Observable variables
  var messengerName = "Nadia Carter".obs;
  var makeloveAlias = "Unknown".obs;
  var bio = "Marketing Coordinator | Lifestyle Brand | 28".obs;
  var isParadoxMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  void _loadProfile() {
    // Watch for changes (reactive)
    _store.watchRuntimeState().listen((state) {
      messengerName.value = state.messengerName;
      makeloveAlias.value = state.makeloveAlias;
      bio.value = state.userBio;
    });
  }

  /// Toggles between Professional (Messenger) and Secret (Makelove/Gallery) mode
  void toggleParadoxMode() {
    isParadoxMode.value = !isParadoxMode.value;
  }

  /// Saves updated identities to Isar
  Future<void> saveIdentity(String messenger, String makelove) async {
    await _store.updateProfile(messenger: messenger, makelove: makelove);
  }
}
