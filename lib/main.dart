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
  // 🛠️ SHIELD 1: Catch UI Rendering Errors
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            "🛑 UI CRASH:\n${details.exception}",
            style: const TextStyle(color: Colors.redAccent, fontFamily: 'monospace'),
          ),
        ),
      ),
    );
  };

  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    debugPrint("🚀 [BOOT]: Starting Firebase...");
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    debugPrint("🚀 [BOOT]: Opening Isar Database...");
    final playbackStore = PlaybackStore();
    await playbackStore.init(); 
    Get.put(playbackStore, permanent: true); 

    debugPrint("🚀 [BOOT]: Registering Repository & Scheduler...");
    Get.put(ScriptRepository(), permanent: true);
    Get.put(ChatScheduler(), permanent: true);

    debugPrint("🚀 [BOOT]: Initializing StateService...");
    final stateService = StateService();
    await stateService.init(); 
    Get.put(stateService, permanent: true);

    debugPrint("🚀 [BOOT]: Starting StoryRuntime...");
    final storyRuntime = StoryRuntime();
    Get.put(storyRuntime, permanent: true);

    debugPrint("🚀 [BOOT]: Audio and Theme Setup...");
    Get.put(AudioService(), permanent: true);
    Get.put(ThemeService(), permanent: true);

    debugPrint("✅ [BOOT COMPLETE]: Launching MyApp");
    runApp(const MyApp());
  } catch (e, stack) {
    debugPrint("❌ [BOOT CRASH]: $e");
    debugPrint("❌ [STACK TRACE]: $stack");

    // 🛠️ SHIELD 2: Show the BOOT error on screen instead of a grey screen
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "❌ BOOT FAILED:\n\n$e",
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      ),
    ));
  }
}
