import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'shared/theme/app_theme.dart';

/// Entry point.
///
/// *Between: Fractured Promises* runs entirely on-device. There is no Firebase,
/// no account, no sync and no network call in the story path — the episode is a
/// script in the asset bundle, the interpreter is in `lib/engine`, and every
/// byte of progress lives in a Drift database in the app's private storage.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The game is a phone inside a phone; landscape would break the fiction.
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyle);
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  runApp(const ProviderScope(child: BetweenApp()));
}
