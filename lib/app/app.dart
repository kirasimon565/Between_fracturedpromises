import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_config.dart';
import '../core/providers/audio_controller.dart';
import '../shared/theme/app_theme.dart';
import 'router.dart';

/// Root widget.
///
/// Everything below this point is offline: the router, the Drift database and
/// the story interpreter are all created inside the [ProviderScope] that wraps
/// this widget in `main()`.
class BetweenApp extends ConsumerStatefulWidget {
  const BetweenApp({super.key});

  @override
  ConsumerState<BetweenApp> createState() => _BetweenAppState();
}

class _BetweenAppState extends ConsumerState<BetweenApp> {
  @override
  void initState() {
    super.initState();
    // Create the audio engine up front so the first `@music` has no latency.
    ref.read(audioControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '${AppConfig.appName}: ${AppConfig.subtitle}',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      darkTheme: AppTheme.build(),
      themeMode: ThemeMode.dark,
      routerConfig: router,
      builder: (BuildContext context, Widget? child) {
        // The whole game is a phone screen: never let the OS font scale
        // break a chat bubble layout.
        final MediaQueryData media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.15,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
