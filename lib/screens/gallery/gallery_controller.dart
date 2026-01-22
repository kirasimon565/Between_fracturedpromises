import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/constants.dart';
import '../../services/audio_service.dart';
import '../../data/playback_store.dart';

class GalleryController extends GetxController {
  final AudioService _audio = Get.find<AudioService>();
  final PlaybackStore _store = Get.find<PlaybackStore>();
  
  final RxList<String> unlockedImages = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _bindGallery();
  }

  void _bindGallery() {
    _store.watchRuntimeState().listen((state) {
      unlockedImages.assignAll(state.unlockedGallery);
    });
  }

  Future<void> unlockNewEvidence(String imagePath) async {
    if (!unlockedImages.contains(imagePath)) {
      _audio.playPing(); 
      
      await _store.unlockGalleryItem(imagePath);
      
      Get.snackbar(
        "ENCRYPTION BROKEN", 
        "A new fragment has been added to the secure gallery.",
        snackPosition: SnackPosition.TOP,
        colorText: Colors.white,
        backgroundColor: Colors.black.withOpacity(0.8),
        borderRadius: 0,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
        borderWidth: 0.5,
        borderColor: Colors.white10,
      );
    }
  }

  Future<void> resetGallery() async {
    // Not implemented in MVP
  }
}
