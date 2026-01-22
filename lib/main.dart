import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'theme/theme.dart';
import 'services/state_service.dart';
import 'services/audio_service.dart';
import 'services/firestore_service.dart'; 
import 'data/playback_store.dart'; 
import 'data/script_repository.dart';
import 'logic/story_runtime.dart'; 
import 'logic/chat_scheduler.dart';
import 'screens/profile/profile_controller.dart'; 
import 'screens/episodes/episode_controller.dart'; // 🛠️ Added for your Gallery

void main() async {
  // 🛡️ SHIELD 1: Catch UI Rendering Errors
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
    // 1. 🛠️ CORE FOUNDATION (Internal Only)
    // Audio and Theme have zero dependencies, so they go first.
    debugPrint("🚀 [BOOT]: Registering Core Services...");
    Get.put(AudioService(), permanent: true);
    Get.put(ThemeService(), permanent: true);

    // 2. 🛠️ DATABASE FOUNDATION (The Hard Path)
    // We open Isar BEFORE the controllers, because controllers NEED Isar to wake up.
    debugPrint("🚀 [BOOT]: Opening Isar Database...");
    final playbackStore = PlaybackStore();
    await playbackStore.init(); 
    Get.put(playbackStore, permanent: true); 

    // 3. 🛠️ CLOUD FOUNDATION
    debugPrint("🚀 [BOOT]: Starting Firebase...");
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    Get.put(FirestoreService(), permanent: true);

    // 4. 🛠️ DATA REPOSITORIES
    // These bridges sit between the Database and the Game Logic.
    debugPrint("🚀 [BOOT]: Connecting Repositories...");
    Get.put(ScriptRepository(), permanent: true);
    Get.put(ChatScheduler(), permanent: true);

    // 5. 🛠️ STATE & LOGIC
    // Initialize StateService which depends on PlaybackStore.
    debugPrint("🚀 [BOOT]: Initializing StateService...");
    final stateService = StateService();
    await stateService.init(); 
    Get.put(stateService, permanent: true);

    // 6. 🛠️ FEATURE CONTROLLERS
    // Now that Isar and State are ready, we can hire the Feature Controllers.
    debugPrint("🚀 [BOOT]: Initializing Feature Controllers...");
    Get.put(ProfileController(), permanent: true); 
    Get.put(EpisodeController(), permanent: true); // Now the Gallery has its brain

    // 7. 🛠️ GAME BRAIN
    // StoryRuntime is the last piece, as it coordinates everything above.
    debugPrint("🚀 [BOOT]: Starting StoryRuntime...");
    Get.put(StoryRuntime(), permanent: true);

    debugPrint("✅ [BOOT COMPLETE]: Launching MyApp");
    runApp(const MyApp());
  } catch (e, stack) {
    debugPrint("❌ [BOOT CRASH]: $e");
    debugPrint("❌ [STACK TRACE]: $stack");

    // 🛡️ SHIELD 2: Visual Boot Error fallback
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("❌ BOOT FAILED", style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Text("$e", style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace')),
                  const SizedBox(height: 20),
                  const Text("Try: Uninstalling and Reinstalling the app to clear Isar locks.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
