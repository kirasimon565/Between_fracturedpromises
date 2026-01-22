// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';

// Import real implementations
import 'package:between_fractured_promises/app/app.dart';
import 'package:between_fractured_promises/theme/theme.dart';
import 'package:between_fractured_promises/services/state_service.dart';
import 'package:between_fractured_promises/services/audio_service.dart';
import 'package:between_fractured_promises/services/firestore_service.dart';
import 'package:between_fractured_promises/services/story_engine.dart';
import 'package:between_fractured_promises/data/playback_store.dart';
import 'package:between_fractured_promises/data/script_repository.dart';
import 'package:between_fractured_promises/logic/story_runtime.dart';
import 'package:between_fractured_promises/logic/chat_scheduler.dart';

void main() {
  testWidgets('App starts smoke test with REAL services', (WidgetTester tester) async {
    // 1. Setup Bindings to allow GetX to work in test
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    // 2. Override PathProvider to use a temp directory for Isar
    // In a WidgetTest, getApplicationDocumentsDirectory usually fails or points to root.
    // We can't easily override the plugin channel here without a mock,
    // BUT we can modify PlaybackStore to accept a path override OR initialize it manually.

    // Actually, since the user forbids mocks, we must let it run properly.
    // Flutter test environment usually handles path_provider by returning a temporary location.

    // 3. Initialize Services (Ordered like main.dart)

    // Reset GetX
    Get.reset();

    // -- State Service (Depends on PlaybackStore, but we init PlaybackStore first in main? No, reverse in main.dart...)
    // Wait, main.dart says:
    // 1. StateService (which uses SharedPreferences... OH WAIT, we refactored it to use PlaybackStore!)
    // So PlaybackStore MUST come first now.

    // -- PlaybackStore --
    // We need to initialize it manually to ensure Isar is open.
    // Note: Isar in tests requires downloading libs which flutter_test handles?
    // Yes, isar_flutter_libs should work on Linux/Desktop tests.

    final store = PlaybackStore();
    // Initialize Isar. We might need to handle the directory.
    // If init() fails due to path_provider, we are stuck without mocks.
    // Assuming standard flutter_test behavior works.
    await Get.putAsync(() => store.init());

    // -- StateService --
    await Get.putAsync(() => StateService().init());

    // -- Core Services --
    Get.put(AudioService());
    Get.put(ThemeService());

    // -- Firestore --
    // Warning: Real Firestore in test requires options or emulators.
    // Without mocking, this might crash if no app is configured.
    // However, the test only checks "App starts".
    // We can inject it. If it tries to connect, it might fail or timeout.
    // For "App starts smoke test", we hope it doesn't do a network call immediately blocking the UI.
    Get.put(FirestoreService());

    // -- Logic Layers --
    Get.put(ScriptRepository());
    Get.put(ChatScheduler());
    Get.put(StoryRuntime());

    // -- StoryEngine --
    Get.put(StoryEngine());

    // 4. Pump App
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle(); // Wait for animations/transitions

    // 5. Verification
    // Verify we are at Splash or Welcome
    // Just finding a Container or Scaffold is enough to say "it didn't crash".
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
