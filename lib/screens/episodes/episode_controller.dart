import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../data/playback_store.dart';
import '../../data/script_repository.dart';

class EpisodeController extends GetxController {
  // 🔗 Connections to our Hard Path services
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final PlaybackStore _isar = Get.find<PlaybackStore>();
  final ScriptRepository _repository = Get.find<ScriptRepository>();

  // 📊 Observable states for the UI
  var isDownloading = false.obs;
  var downloadProgress = 0.0.obs;
  var isDownloaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkIfDownloaded('episode_1'); // Check status on startup
  }

  void checkIfDownloaded(String episodeId) async {
    // Check Isar to see if the script already exists locally
    final exists = await _repository.isEpisodeLocal(episodeId);
    isDownloaded.value = exists;
  }

  Future<void> startDownload(String episodeId) async {
    if (isDownloading.value) return;

    try {
      isDownloading.value = true;
      downloadProgress.value = 0.1; // Start phase

      // 1. Fetch from Firebase Cloud
      // We assume Jules's FirestoreService has a getScript method
      final scriptData = await _firestore.getEpisodeScript(episodeId);
      downloadProgress.value = 0.5; // Halfway: Cloud fetch done

      // 2. Save to Isar (The Hard Path)
      // We push the data into the local database
      await _repository.saveScriptToLocal(scriptData);
      
      downloadProgress.value = 1.0; // Finished
      isDownloaded.value = true;
      
      Get.snackbar(
        "Success", 
        "Episode Downloaded",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );

    } catch (e) {
      Get.snackbar("Error", "Download failed: $e");
    } finally {
      isDownloading.value = false;
    }
  }
}
