import 'package:get/get.dart';
import '../../data/playback_store.dart';

class ProfileController extends GetxController {
  final PlaybackStore _store = Get.find<PlaybackStore>();

  var name = "Nadia".obs;
  var bio = "Just looking for a spark...".obs;
  var age = 28.obs;
  var isEditing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  void _loadProfile() {
    _store.watchRuntimeState().listen((state) {
      name.value = state.userName;
      bio.value = state.userBio;
    });
  }

  Future<void> saveProfile(String newName, String newBio) async {
    name.value = newName;
    bio.value = newBio;
    isEditing.value = false;

    await _store.updateProfile(name: newName, bio: newBio);
  }
}
