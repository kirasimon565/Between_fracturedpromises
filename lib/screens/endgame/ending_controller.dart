import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/constants.dart';
import '../../models/ending.dart';
import '../../services/story_engine.dart';

class EndingController extends GetxController {
  final StoryEngine _storyEngine = Get.find<StoryEngine>();

  // Observables for the Endgame Screen
  final ending = Rx<Ending?>(null);
  final truthPercentage = 0.obs;
  final paradoxResolved = false.obs;

  @override
  void onInit() {
    super.onInit();
    _calculateFinalOutcome();
  }

  /// 🛠️ Analyzes the StoryEngine state to determine the finale
  void _calculateFinalOutcome() {
    // 1. Calculate Truth (Based on how many gallery items were unlocked)
    // Assuming 10 total secrets in the game
    int secretsFound = _storyEngine.unlockedGlobalSecrets.length;
    truthPercentage.value = ((secretsFound / 10) * 100).toInt().clamp(0, 100);

    // 2. Determine Paradox Resolution
    // Logic: If the player found the 'Daniel' truth, the paradox is resolved
    paradoxResolved.value = _storyEngine.hasCompletedThread('daniel');

    // 3. Select Ending based on Story Engine 'ending_flag'
    String endingId = _storyEngine.getMetadata('final_ending_id') ?? 'e_neutral';
    
    ending.value = _getEndingById(endingId);
    
    // 4. Save this ending to history
    _saveEndingToHistory(endingId);
  }

  /// 🛠️ Persistence: Save the ending so it appears in a "Hall of Fame" or Menu
  Future<void> _saveEndingToHistory(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('ending_history') ?? [];
    if (!history.contains(id)) {
      history.add(id);
      await prefs.setStringList('ending_history', history);
    }
  }

  /// 🛠️ Data Mapper for Ending Models
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
