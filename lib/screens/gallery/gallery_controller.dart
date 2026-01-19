import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/constants.dart';
import '../../services/audio_service.dart';

class GalleryController extends GetxController {
  final AudioService _audio = Get.find<AudioService>();
  
  // Observable list of image paths
  final RxList<String> unlockedImages = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUnlockedEvidence(); // Load saved history on startup
  }

  /// 🛠️ Load discovered photos from device storage
  Future<void> _loadUnlockedEvidence() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList('unlocked_gallery') ?? [
      // Default starting evidence (optional)
      AppConstants.avatarNadia, 
    ];
    unlockedImages.assignAll(savedList);
  }

  /// 🛠️ Method to unlock new "Paradox" evidence during the story
  Future<void> unlockNewEvidence(String imagePath) async {
    if (!unlockedImages.contains(imagePath)) {
      // 🔊 Play a distinct mechanical sound for new discoveries
      _audio.playPing(); 
      
      unlockedImages.add(imagePath);
      
      // Save updated list to persistence layer
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('unlocked_gallery', unlockedImages.toList());
      
      // Optional: Show a "SECURE DATA RECOVERED" toast
      Get.snackbar(
        "ENCRYPTION BROKEN", 
        "A new fragment has been added to your gallery.",
        snackPosition: SnackPosition.TOP,
        colorText: Colors.white,
        backgroundColor: Colors.black54,
      );
    }
  }

  /// 🛠️ Clear logic for "Reset Game" scenarios
  Future<void> resetGallery() async {
    unlockedImages.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('unlocked_gallery');
  }
}
