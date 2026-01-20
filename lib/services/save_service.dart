import 'package:get/get.dart';
import 'firestore_service.dart';
import 'state_service.dart';
import 'auth_service.dart';

class SaveService extends GetxService {
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final StateService _state = Get.find<StateService>();
  final AuthService _auth = Get.find<AuthService>();

  /// Syncs the player's choices and current position to the cloud
  Future<void> saveGame(String episodeId, String sceneId, Map<String, dynamic> choices) async {
    if (_auth.uid.isEmpty) return;

    // 1. Update the local UI state immediately
    _state.updateProgress(episodeId, sceneId);

    // 2. Transmit to Firestore so the player can switch devices
    await _firestore.saveProgress(episodeId, sceneId, choices);
  }
}
