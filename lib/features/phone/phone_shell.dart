import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_config.dart';
import '../../core/providers/engine_providers.dart';
import '../../core/providers/world_providers.dart';
import '../../engine/engine.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/common.dart';
import '../browser/browser_app.dart';
import '../calls/calls_app.dart';
import '../contacts/contacts_app.dart';
import '../files/files_app.dart';
import '../gallery/gallery_app.dart';
import '../makelove/makelove_app.dart';
import '../messenger/messenger_app.dart';
import '../settings/phone_settings_app.dart';
import '../store/store_screen.dart';
import 'widgets/overlays.dart';
import 'widgets/phone_chrome.dart';

/// The device the whole game is played on.
///
/// This widget is deliberately dumb: it never decides *what* the story does,
/// it only renders whichever app the [GameState] says is open. `@open_app`,
/// `@browser_open` and `@call_incoming` all move `phone.currentApp`, so the
/// script drives navigation and the player's taps go back through
/// [GameSessionController.openApp] — the same door.
class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key, this.initialApp});

  /// Set when the shell is entered through `/phone/app/:appId`.
  final String? initialApp;

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen>
    with WidgetsBindingObserver {
  bool _completeShown = false;
  StreamSubscription<EngineEffect>? _effectSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final String? initial = widget.initialApp;
    if (initial != null && initial.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(gameSessionProvider.notifier).openApp(initial);
      });
    }

    // Episode completion is an effect, not a status, so it is watched here
    // rather than derived from the session snapshot.
    _effectSub = ref
        .read(gameSessionProvider.notifier)
        .effects
        .listen(_onEffect);
  }

  @override
  void dispose() {
    unawaited(_effectSub?.cancel());
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final GameSessionController session =
        ref.read(gameSessionProvider.notifier);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        session.pause();
        unawaited(session.saveNow());
        break;
      case AppLifecycleState.resumed:
        unawaited(session.resume());
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _onEffect(EngineEffect effect) {
    if (effect is EpisodeCompleteEffect && !_completeShown) {
      _completeShown = true;
      unawaited(_showEpisodeComplete(effect));
    }
  }

  Future<void> _showEpisodeComplete(EpisodeCompleteEffect effect) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) =>
          _EpisodeCompleteSheet(effect: effect),
    );
  }

  void _openStore({int required = 0}) {
    ref.read(gameSessionProvider.notifier).openApp('store');
    if (required > 0) {
      StoreView.pendingRequirement.value = required;
    }
  }

  Future<bool> _handleBack() async {
    final String? app = ref.read(currentAppProvider);
    if (app != null) {
      ref.read(gameSessionProvider.notifier).closeApp();
      return false;
    }
    final bool leave = await _confirmLeave() ?? false;
    if (leave && mounted) {
      await ref.read(gameSessionProvider.notifier).saveNow();
    }
    return leave;
  }

  Future<bool?> _confirmLeave() => showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Put the phone down?'),
          content: const Text(
            'Your progress is saved automatically. You can pick the story '
            'back up from the main menu.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep reading'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save & exit'),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final GameSession session = ref.watch(gameSessionProvider);
    final String? appId = ref.watch(currentAppProvider);
    final PhoneCall? call = ref.watch(activeCallProvider);

    if (session.error != null) {
      return _PhoneFailure(message: session.error!);
    }
    if (!session.isLoaded) {
      return const _PhoneBooting();
    }

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final bool leave = await _handleBack();
        if (!context.mounted) return;
        if (leave) context.go(Routes.menu);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.overlayStyle,
        child: Scaffold(
          backgroundColor: AppColors.voidBlack,
          body: NightBackdrop(
            child: SafeArea(
              bottom: false,
              child: EffectOverlayHost(
                onNavigate: _navigate,
                onOpenStore: (StoreEffect effect) =>
                    _openStore(required: effect.requiredCrystals),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        PhoneStatusBar(tint: AppColors.forApp(appId)),
                        Expanded(child: _body(appId)),
                      ],
                    ),
                    if (call != null && call.state == CallState.incoming)
                      IncomingCallOverlay(call: call),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Engine-issued navigation (`@ui navigate`, `@call_end`).
  void _navigate(String route) {
    if (route == Routes.phone) {
      ref.read(gameSessionProvider.notifier).closeApp();
      return;
    }
    if (route == Routes.store) {
      _openStore();
      return;
    }
    if (route.startsWith('/phone/app/')) {
      ref
          .read(gameSessionProvider.notifier)
          .openApp(route.substring('/phone/app/'.length));
    }
  }

  Widget _body(String? appId) {
    void exit() => ref.read(gameSessionProvider.notifier).closeApp();

    switch (appId) {
      case null:
      case '':
      case 'home':
        return const PhoneHomeScreen();
      case 'messenger':
        return MessengerApp(
          onExit: exit,
          onOpenStore: (int required) => _openStore(required: required),
        );
      case 'makelove':
        return MakeloveApp(
          onExit: exit,
          onOpenStore: (int required) => _openStore(required: required),
        );
      case 'browser':
        return BrowserApp(onExit: exit);
      case 'gallery':
        return GalleryApp(onExit: exit);
      case 'contacts':
        return ContactsApp(onExit: exit);
      case 'calls':
        return CallsApp(onExit: exit);
      case 'settings':
        return PhoneSettingsApp(onExit: exit);
      case 'store':
        return StoreView(onExit: exit);
      case 'files':
        return FilesApp(onExit: exit);
      case 'camera':
        return CameraApp(onExit: exit);
      default:
        return _UnknownApp(appId: appId, onExit: exit);
    }
  }
}

class _PhoneBooting extends StatelessWidget {
  const _PhoneBooting();

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: AppColors.voidBlack,
        body: Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.ember,
            ),
          ),
        ),
      );
}

class _PhoneFailure extends ConsumerWidget {
  const _PhoneFailure({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        backgroundColor: AppColors.voidBlack,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'The story could not start',
              message: message,
              action: FilledButton(
                onPressed: () => ref
                    .read(gameSessionProvider.notifier)
                    .newGame(),
                child: const Text('Try again'),
              ),
            ),
          ),
        ),
      );
}

class _UnknownApp extends StatelessWidget {
  const _UnknownApp({required this.appId, required this.onExit});

  final String appId;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          AppHeader(title: appId, onBack: onExit),
          const Expanded(
            child: EmptyState(
              icon: Icons.hourglass_empty_rounded,
              title: 'Not installed yet',
              message: 'This app appears later in the story.',
            ),
          ),
        ],
      );
}

class _EpisodeCompleteSheet extends ConsumerWidget {
  const _EpisodeCompleteSheet({required this.effect});

  final EpisodeCompleteEffect effect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameSession session = ref.watch(gameSessionProvider);
    final EpisodeManifest manifest = AppConfig.episode(effect.episodeId);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.sheet,
      ),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'EPISODE ${manifest.number}',
            style: const TextStyle(
              color: AppColors.ember,
              fontSize: 12,
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            manifest.title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 28,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            effect.reason ??
                'The messages stop. What you chose tonight does not.',
            style: const TextStyle(
              color: AppColors.textDim,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 26),
          if (session.diagnostics.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(
                '${session.diagnostics.length} script notes',
                style: const TextStyle(
                  color: AppColors.textFaint,
                  fontSize: 11,
                ),
              ),
            ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(Routes.menu);
            },
            child: const Text('Back to the menu'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Stay on the phone'),
          ),
        ],
      ),
    );
  }
}
