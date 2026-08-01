import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/app_config.dart';
import '../core/providers/app_providers.dart';
import '../core/providers/engine_providers.dart';
import '../features/menu/debug_screen.dart';
import '../features/menu/episodes_screen.dart';
import '../features/menu/saves_screen.dart';
import '../features/menu/settings_screen.dart';
import '../features/phone/phone_shell.dart';
import '../features/store/store_screen.dart';
import '../features/studio/disclaimer_screen.dart';
import '../features/studio/main_menu_screen.dart';
import '../features/studio/player_setup_screen.dart';
import '../features/studio/splash_screen.dart';
import '../features/studio/studio_screen.dart';
import '../features/studio/welcome_screen.dart';

/// The app's navigation graph.
///
/// The intro is a straight line — Splash → Studio → Disclaimer → Welcome →
/// Player Setup → Main Menu — and the redirect below is what keeps it honest:
/// a player who has already been set up never sees onboarding again, and a
/// player who has not cannot skip past it into the story.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  // The redirect below reads Riverpod state, so the router has to be told when
  // that state moves: bootstrap finishing and an episode being loaded are the
  // two transitions that change where the player is allowed to be.
  final _RouterRefresh refresh = _RouterRefresh();
  ref.listen<AsyncValue<Bootstrap>>(
    bootstrapProvider,
    (AsyncValue<Bootstrap>? _, AsyncValue<Bootstrap> _) => refresh.bump(),
  );
  ref.listen<bool>(
    gameSessionProvider.select((GameSession s) => s.isLoaded),
    (bool? _, bool _) => refresh.bump(),
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: false,
    refreshListenable: refresh,
    redirect: (BuildContext context, GoRouterState state) {
      final String location = state.matchedLocation;
      final AsyncValue<Bootstrap> boot = ref.read(bootstrapProvider);

      // While the database opens, the splash is the only legal screen.
      if (boot.isLoading || boot.hasError) {
        return location == Routes.splash ? null : Routes.splash;
      }

      final bool onboarded = boot.value?.onboarded ?? false;
      const Set<String> introRoutes = <String>{
        Routes.splash,
        Routes.studio,
        Routes.disclaimer,
        Routes.welcome,
        Routes.setup,
      };

      // Not set up yet: everything outside the intro funnels back to Welcome.
      if (!onboarded && !introRoutes.contains(location)) {
        return Routes.welcome;
      }

      // The phone is meaningless without a running interpreter.
      if (location.startsWith(Routes.phone) &&
          !ref.read(gameSessionProvider).isLoaded) {
        return Routes.menu;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: Routes.splash,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: Routes.studio,
        builder: (BuildContext context, GoRouterState state) =>
            const StudioAnimationScreen(),
      ),
      GoRoute(
        path: Routes.disclaimer,
        builder: (BuildContext context, GoRouterState state) =>
            const DisclaimerScreen(),
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (BuildContext context, GoRouterState state) =>
            const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.setup,
        builder: (BuildContext context, GoRouterState state) =>
            const PlayerSetupScreen(),
      ),
      GoRoute(
        path: Routes.menu,
        builder: (BuildContext context, GoRouterState state) =>
            const MainMenuScreen(),
      ),
      GoRoute(
        path: Routes.phone,
        builder: (BuildContext context, GoRouterState state) =>
            const PhoneScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'app/:appId',
            builder: (BuildContext context, GoRouterState state) =>
                PhoneScreen(initialApp: state.pathParameters['appId']),
          ),
        ],
      ),
      GoRoute(
        path: Routes.store,
        builder: (BuildContext context, GoRouterState state) => StoreScreen(
          requiredCrystals:
              int.tryParse(state.uri.queryParameters['need'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: Routes.saves,
        builder: (BuildContext context, GoRouterState state) =>
            const SavesScreen(),
      ),
      GoRoute(
        path: Routes.episodes,
        builder: (BuildContext context, GoRouterState state) =>
            const EpisodesScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.debug,
        builder: (BuildContext context, GoRouterState state) =>
            const DebugScreen(),
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.explore_off_outlined, size: 42),
              const SizedBox(height: 16),
              Text('No screen at ${state.uri}'),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go(Routes.menu),
                child: const Text('Back to the menu'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});

/// Bridges Riverpod state changes into `GoRouter.refreshListenable`.
class _RouterRefresh extends ChangeNotifier {
  void bump() => notifyListeners();
}
