import 'package:get/get.dart';
import 'firestore_service.dart';
import 'state_service.dart';

class SaveService extends GetxService {
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final StateService _state = Get.find<StateService>();

  // Facade to handle saving to both local state and cloud
  Future<void> saveGame(String episodeId, String sceneId, Map<String, dynamic> choices) async {
    // 1. Save Local
    _state.updateProgress(episodeId, sceneId);

    // 2. Sync Cloud
    await _firestore.saveProgress(episodeId, sceneId, choices);

    print("Game saved: $episodeId / $sceneId");
  }
}
