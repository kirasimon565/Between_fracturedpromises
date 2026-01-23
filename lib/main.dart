import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'theme/theme.dart';
import 'services/state_service.dart';
import 'services/audio_service.dart';
import 'services/firestore_service.dart'; 
import 'services/auth_service.dart'; // 🛠️ ADDED: Required for Firebase & UI checks
import 'data/playback_store.dart'; 
import 'data/script_repository.dart';
import 'logic/story_runtime.dart'; 
import 'logic/chat_scheduler.dart';
import 'screens/profile/profile_controller.dart'; 
import 'screens/episodes/episode_controller.dart'; 

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
    // 1. 🛠️ CORE FOUNDATION
    debugPrint("🚀 [BOOT]: Registering Core Services...");
    Get.put(AudioService(), permanent: true);
    Get.put(ThemeService(), permanent: true);

    // 2. 🛠️ DATABASE FOUNDATION (Local First)
    debugPrint("🚀 [BOOT]: Opening Isar Database...");
    final playbackStore = PlaybackStore();
    await playbackStore.init(); 
    Get.put(playbackStore, permanent: true); 

    // 3. 🛠️ CLOUD FOUNDATION
    debugPrint("🚀 [BOOT]: Starting Firebase...");
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    
    // 🛠️ Register AuthService immediately after Firebase
    debugPrint("🚀 [BOOT]: Initializing Auth Service...");
    Get.put(AuthService(), permanent: true); 
    
    debugPrint("🚀 [BOOT]: Connecting Firestore...");
    Get.put(FirestoreService(), permanent: true);

    // 4. 🛠️ DATA REPOSITORIES
    debugPrint("🚀 [BOOT]: Connecting Repositories...");
    Get.put(ScriptRepository(), permanent: true);
    Get.put(ChatScheduler(), permanent: true);

    // 5. 🛠️ STATE & LOGIC
    debugPrint("🚀 [BOOT]: Initializing StateService...");
    final stateService = StateService();
    await stateService.init(); 
    Get.put(stateService, permanent: true);

    // 6. 🛠️ FEATURE CONTROLLERS
    debugPrint("🚀 [BOOT]: Initializing Feature Controllers...");
    Get.put(ProfileController(), permanent: true); 
    Get.put(EpisodeController(), permanent: true); 

    // 7. 🛠️ GAME BRAIN
    debugPrint("🚀 [BOOT]: Starting StoryRuntime...");
    Get.put(StoryRuntime(), permanent: true);

    debugPrint("✅ [BOOT COMPLETE]: Launching MyApp");
    runApp(const MyApp());
  } catch (e, stack) {
    debugPrint("❌ [BOOT CRASH]: $e");
    debugPrint("❌ [STACK TRACE]: $stack");

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
