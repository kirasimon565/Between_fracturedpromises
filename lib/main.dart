import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'theme/theme.dart';
// 🛠️ Import the missing services
import 'services/state_service.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Register Global Services BEFORE runApp
  // This ensures they are available the microsecond the app starts.
  await Get.putAsync(() => StateService().init());
  Get.put(AudioService());
  Get.put(ThemeService());

  runApp(const MyApp());
}
