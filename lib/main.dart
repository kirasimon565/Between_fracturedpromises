import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'theme/theme.dart';
import 'services/state_service.dart';
import 'services/audio_service.dart';
// 🛠️ Import the new Hard Path store
import 'data/playback_store.dart'; 

void main() async {
  // 1. Connect Flutter to the Native Layer
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 2. Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 3. Initialize the Isar Database (THE CRITICAL STEP)
    // We must open the database BEFORE the StateService tries to read from it.
    final playbackStore = PlaybackStore();
    await playbackStore.init(); 
    Get.put(playbackStore); 

    // 4. Register Global Services
    // putAsync ensures the StateService finishes its logic before moving on.
    await Get.putAsync(() => StateService().init());
    
    Get.put(AudioService());
    Get.put(ThemeService());

    runApp(const MyApp());
  } catch (e) {
    // 🛑 If anything fails during boot, print the error and attempt to launch anyway
    // This prevents the "Infinite Launcher" hang.
    debugPrint("CRITICAL BOOT ERROR: $e");
    runApp(const MyApp());
  }
}
