import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_config.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/common.dart';

/// Frame 1 of the boot sequence.
///
/// It holds the screen for as long as it takes [bootstrapProvider] to open the
/// database — and never less than [_minimumHold], so a warm start does not
/// flash past. The studio sting only begins once the player's profile, wallet
/// and settings are in memory.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const Duration _minimumHold = Duration(milliseconds: 1500);

  Timer? _timer;
  bool _held = false;
  bool _moved = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_minimumHold, () {
      if (mounted) setState(() => _held = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Bootstrap> boot = ref.watch(bootstrapProvider);

    if (_held && boot.hasValue && !_moved) {
      _moved = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(Routes.studio);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      body: Center(
        child: boot.hasError
            ? Padding(
                padding: const EdgeInsets.all(28),
                child: EmptyState(
                  icon: Icons.storage_rounded,
                  title: 'Local storage is unavailable',
                  message: '${boot.error}',
                  action: FilledButton(
                    onPressed: () => ref.invalidate(bootstrapProvider),
                    child: const Text('Try again'),
                  ),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    'assets/logo/logo.png',
                    width: 132,
                    errorBuilder:
                        (BuildContext _, Object _, StackTrace? _) =>
                            const Icon(Icons.blur_on_rounded,
                                size: 92, color: AppColors.ember),
                  )
                      .animate()
                      .fadeIn(duration: 700.ms, curve: Curves.easeOut)
                      .scale(
                        begin: const Offset(0.94, 0.94),
                        end: const Offset(1, 1),
                        duration: 900.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 26),
                  Text(
                    AppConfig.appName.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 26,
                      letterSpacing: 12,
                      fontWeight: FontWeight.w200,
                    ),
                  ).animate(delay: 260.ms).fadeIn(duration: 800.ms),
                  const SizedBox(height: 8),
                  const Text(
                    AppConfig.subtitle,
                    style: TextStyle(
                      color: AppColors.textFaint,
                      fontSize: 11,
                      letterSpacing: 4,
                    ),
                  ).animate(delay: 520.ms).fadeIn(duration: 800.ms),
                ],
              ),
      ),
    );
  }
}
