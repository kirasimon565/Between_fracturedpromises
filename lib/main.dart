import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'theme/theme.dart';
import 'services/state_service.dart';
import 'services/audio_service.dart';
import 'data/playback_store.dart'; 

void main() async {
  // 1. Mandatory: Connect Flutter to Native Layer
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 2. Initialize Firebase (Critical for Analytics/Auth)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 3. Initialize Isar (The Hard Path Foundation)
    // We open the database BEFORE anything else tries to read from it.
    final playbackStore = PlaybackStore();
    await playbackStore.init(); 
    // 'permanent: true' prevents GetX from disposing this accidentally
    Get.put(playbackStore, permanent: true); 

    // 4. Initialize StateService (Nadia's Memory)
    // We WAIT for init() to finish so the grey screen doesn't find null data.
    final stateService = StateService();
    await stateService.init(); 
    Get.put(stateService, permanent: true);

    // 5. Register Global Audio and Theme
    Get.put(AudioService(), permanent: true);
    Get.put(ThemeService(), permanent: true);

    // 6. Launch the App
    runApp(const MyApp());
  } catch (e) {
    // 🛑 Final fallback: Log the error and launch the UI to prevent a black/grey screen
    debugPrint("=== BOOT CRASH ===: $e");
    
    // If we fail, we still launch MyApp so the engine doesn't just hang
    runApp(const MyApp());
  }
}
