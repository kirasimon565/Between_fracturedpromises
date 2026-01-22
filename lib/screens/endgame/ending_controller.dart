import 'package:get/get.dart';
import '../../app/constants.dart';
import '../../models/ending.dart';
import '../../services/story_engine.dart';
import '../../data/playback_store.dart';

class EndingController extends GetxController {
  final StoryEngine _storyEngine = Get.find<StoryEngine>();
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
    int secretsFound = _storyEngine.unlockedGlobalSecrets.length;
    truthPercentage.value = ((secretsFound / 10) * 100).toInt().clamp(0, 100);

    paradoxResolved.value = _storyEngine.hasCompletedThread('daniel');

    String endingId = _storyEngine.getMetadata('final_ending_id') ?? 'e_neutral';
    
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
