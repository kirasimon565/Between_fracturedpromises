import 'package:flutter/material.dart'; // 🛠️ FIX: Added for Colors and Snackbars
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
      AppConstants.avatarNadia, 
    ];
    unlockedImages.assignAll(savedList);
  }

  /// 🛠️ Method to unlock new "Paradox" evidence
  Future<void> unlockNewEvidence(String imagePath) async {
    if (!unlockedImages.contains(imagePath)) {
      // 🔊 Play distinct mechanical sound
      _audio.playPing(); 
      
      unlockedImages.add(imagePath);
      
      // Persistence Layer Update
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('unlocked_gallery', unlockedImages.toList());
      
      // 🕵️ System Notification for Discovery
      Get.snackbar(
        "ENCRYPTION BROKEN", 
        "A new fragment has been added to the secure gallery.",
        snackPosition: SnackPosition.TOP,
        colorText: Colors.white,
        backgroundColor: Colors.black.withOpacity(0.8),
        borderRadius: 0, // Sharp edges for the Noir feel
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
        borderWidth: 0.5,
        borderColor: Colors.white10,
      );
    }
  }

  /// 🛠️ Clear logic for "System Wipe" or "New Game"
  Future<void> resetGallery() async {
    unlockedImages.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('unlocked_gallery');
  }
}
