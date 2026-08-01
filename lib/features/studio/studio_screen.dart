import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_config.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/theme/app_theme.dart';

/// The studio sting.
///
/// Two lines drift apart and never quite meet — the whole game in one shape.
/// Tapping skips it, and returning players who have already been through the
/// disclaimer go straight to the menu.
class StudioAnimationScreen extends ConsumerStatefulWidget {
  const StudioAnimationScreen({super.key});

  @override
  ConsumerState<StudioAnimationScreen> createState() =>
      _StudioAnimationScreenState();
}

class _StudioAnimationScreenState extends ConsumerState<StudioAnimationScreen> {
  static const Duration _length = Duration(milliseconds: 3400);
  Timer? _timer;
  bool _moved = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_length, _advance);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _advance() {
    if (_moved || !mounted) return;
    _moved = true;
    final Bootstrap? boot = ref.read(bootstrapProvider).value;
    context.go((boot?.onboarded ?? false) ? Routes.menu : Routes.disclaimer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _advance,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 190,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    const _Thread(
                          color: AppColors.messenger,
                          alignment: Alignment.topCenter,
                        )
                        .animate()
                        .fadeIn(duration: 700.ms)
                        .moveY(begin: 14, end: 0, duration: 1100.ms)
                        .then(delay: 300.ms)
                        .moveY(begin: 0, end: -8, duration: 900.ms),
                    const _Thread(
                          color: AppColors.makelove,
                          alignment: Alignment.bottomCenter,
                        )
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 700.ms)
                        .moveY(begin: -14, end: 0, duration: 1100.ms)
                        .then(delay: 300.ms)
                        .moveY(begin: 0, end: 8, duration: 900.ms),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              Text(
                    AppConfig.studio.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      letterSpacing: 8,
                      fontWeight: FontWeight.w300,
                    ),
                  )
                  .animate(delay: 1200.ms)
                  .fadeIn(duration: 900.ms)
                  .shimmer(
                    delay: 500.ms,
                    duration: 1400.ms,
                    color: AppColors.ember.withValues(alpha: 0.6),
                  ),
              const SizedBox(height: 12),
              const Text(
                'presents',
                style: TextStyle(
                  color: AppColors.textFaint,
                  fontSize: 10,
                  letterSpacing: 4,
                ),
              ).animate(delay: 1900.ms).fadeIn(duration: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thread extends StatelessWidget {
  const _Thread({required this.color, required this.alignment});

  final Color color;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Align(
    alignment: alignment,
    child: Container(
      width: 190,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Colors.transparent, color, Colors.transparent],
        ),
      ),
    ),
  );
}
