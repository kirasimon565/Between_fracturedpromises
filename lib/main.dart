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
import 'screens/profile/profile_controller.dart';

void main() async {
  // 🛠️ SHIELD 1: Catch UI Rendering Errors
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Text(
              "🛑 UI CRASH:\n${details.exception}",
              style: const TextStyle(color: Colors.redAccent, fontFamily: 'monospace'),
            ),
          ),
        ),
      ),
    );
  };

  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 1. 🛠️ IMMEDIATE SETUP: Register services that don't require 'await' first.
    // This stops the "AudioService not found" error because it's available instantly.
    debugPrint("🚀 [BOOT]: Registering Audio and Theme...");
    Get.put(AudioService(), permanent: true);
    Get.put(ThemeService(), permanent: true);

    // 2. Initialize Firebase
    debugPrint("🚀 [BOOT]: Starting Firebase...");
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // 3. Initialize Isar (The Hard Path Foundation)
    debugPrint("🚀 [BOOT]: Opening Isar Database...");
    final playbackStore = PlaybackStore();
    await playbackStore.init(); 
    Get.put(playbackStore, permanent: true); 

    // 4. Register Logic Dependencies
    debugPrint("🚀 [BOOT]: Registering Repository & Scheduler...");
    Get.put(ScriptRepository(), permanent: true);
    Get.put(ChatScheduler(), permanent: true);

    // 5. Initialize StateService (Nadia's Memory)
    debugPrint("🚀 [BOOT]: Initializing StateService...");
    final stateService = StateService();
    await stateService.init(); 
    Get.put(stateService, permanent: true);

    // 6. Initialize StoryRuntime (The Game's Brain)
    debugPrint("🚀 [BOOT]: Starting StoryRuntime...");
    final storyRuntime = StoryRuntime();
    Get.put(storyRuntime, permanent: true);

    debugPrint("✅ [BOOT COMPLETE]: Launching MyApp");
    runApp(const MyApp());
  } catch (e, stack) {
    debugPrint("❌ [BOOT CRASH]: $e");
    debugPrint("❌ [STACK TRACE]: $stack");

    // 🛠️ SHIELD 2: Visual Boot Error
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Text(
                "❌ BOOT FAILED:\n\n$e\n\nCheck if all services are committed to GitHub.",
                style: const TextStyle(color: Colors.red, fontSize: 14, fontFamily: 'monospace'),
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
