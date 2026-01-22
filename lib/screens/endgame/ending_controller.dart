import 'package:get/get.dart';
import '../../app/constants.dart';
import '../../models/ending.dart';
import '../../services/state_service.dart';
import '../../data/playback_store.dart';

class EndingController extends GetxController {
  final StateService _stateService = Get.find<StateService>();
  final PlaybackStore _store = Get.find<PlaybackStore>();

  final ending = Rx<Ending?>(null);
  final truthPercentage = 0.obs;
  final paradoxResolved = false.obs;

  @override
  void onInit() {
    super.onInit();
    _calculateFinalOutcome();
  }

  void _calculateFinalOutcome() {
    // 🛠️ Replaced queries with StateService/Store queries

    // Example: Count secrets from variables or unlockedGallery
    // Assuming 'secrets_found' variable is tracked
    int secretsFound = (_stateService.variables['secrets_found'] as int?) ?? 0;
    truthPercentage.value = ((secretsFound / 10) * 100).toInt().clamp(0, 100);

    // Check completion of Daniel thread
    // We can check if thread meta has some 'completed' flag or similar,
    // or check a variable 'thread_daniel_complete'.
    paradoxResolved.value = (_stateService.variables['thread_daniel_complete'] == true);

    String endingId = (_stateService.variables['final_ending_id'] as String?) ?? 'e_neutral';
    
    ending.value = _getEndingById(endingId);
    
    _saveEndingToHistory(endingId);
  }

  Future<void> _saveEndingToHistory(String id) async {
    await _store.recordEnding(id);
  }

  Ending _getEndingById(String id) {
    switch (id) {
      case 'e_truth':
        return Ending(
          id: 'e_truth',
          type: EndingType.perfect,
          title: "The Architect",
          description: "You saw through every layer. The truth is cold, but it is yours.",
          imagePath: AppConstants.galleryEndingPerfect,
        );
      case 'e_betrayal':
        return Ending(
          id: 'e_betrayal',
          type: EndingType.fractured,
          title: "The Betrayed",
          description: "You trusted the wrong shadow. Now you are part of the lie.",
          imagePath: AppConstants.galleryEndingFractured,
        );
      default:
        return Ending(
          id: 'e_neutral',
          type: EndingType.neutral,
          title: "The Silenced",
          description: "Some questions were never meant to be answered.",
          imagePath: AppConstants.galleryEndingNeutral,
        );
    }
  }
}
