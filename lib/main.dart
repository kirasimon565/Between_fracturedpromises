import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'theme/theme.dart';
import 'services/state_service.dart';
import 'services/audio_service.dart';
import 'data/playback_store.dart'; 
import 'data/script_repository.dart';
import 'logic/story_runtime.dart'; 
import 'logic/chat_scheduler.dart';

void main() async {
  // 1. Mandatory: Connect Flutter to Native Layer
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 2. Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 3. Initialize Isar (The Hard Path Foundation)
    final playbackStore = PlaybackStore();
    await playbackStore.init(); 
    Get.put(playbackStore, permanent: true); 

    // 4. Register ScriptRepository & ChatScheduler (Dependencies for StoryRuntime)
    Get.put(ScriptRepository(), permanent: true);
    Get.put(ChatScheduler(), permanent: true);

    // 5. Initialize StateService (Nadia's Memory)
    final stateService = StateService();
    await stateService.init(); 
    Get.put(stateService, permanent: true);

    // 6. Initialize StoryRuntime (The Game's Brain)
    final storyRuntime = StoryRuntime();
    // await storyRuntime.init(); // Uncomment if init logic is added later
    Get.put(storyRuntime, permanent: true);

    // 7. Register Global Audio and Theme
    Get.put(AudioService(), permanent: true);
    Get.put(ThemeService(), permanent: true);

    // 8. Launch the App
    runApp(const MyApp());
  } catch (e) {
    debugPrint("=== BOOT CRASH ===: $e");
    // If we fail, we still launch MyApp so the engine doesn't just hang
    runApp(const MyApp());
  }
}
