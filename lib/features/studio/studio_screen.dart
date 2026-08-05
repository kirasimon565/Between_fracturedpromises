import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/app_config.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/theme/app_theme.dart';

/// The BlackMoon Studio intro sequence.
///
/// Combines the studio emblem with layered glow animations, real-time typing indicators,
/// dynamic app versioning, and auto-advance navigation.
class StudioAnimationScreen extends ConsumerStatefulWidget {
  const StudioAnimationScreen({super.key});

  @override
  ConsumerState<StudioAnimationScreen> createState() =>
      _StudioAnimationScreenState();
}

class _StudioAnimationScreenState extends ConsumerState<StudioAnimationScreen> {
  static const Duration _length = Duration(milliseconds: 4000);
  Timer? _timer;
  bool _moved = false;

  // Holds the runtime package version loaded from package_info_plus.
  String _version = '';

  @override
  void initState() {
    super.initState();
    _timer = Timer(_length, _advance);

    // Load the app version asynchronously and update the UI when available.
    PackageInfo.fromPlatform().then((PackageInfo info) {
      if (mounted) {
        setState(() => _version = info.version);
      }
    }).catchError((_) {
      // Ignore errors here; version will remain empty.
    });
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
    // Safely pull app version string from runtime package info or Bootstrap state
    final String versionString = _version;
    final String displayVersion =
        versionString.isNotEmpty ? 'v$versionString' : '';

    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _advance,
        child: Stack(
          children: <Widget>[
            // Ambient Radial Center Background Glow
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      AppColors.ember.withValues(alpha: 0.15),
                      AppColors.voidBlack.withValues(alpha: 0.0),
                    ],
                    stops: const <double>[0.0, 1.0],
                  ),
                ),
              ).animate().fadeIn(duration: 1200.ms),
            ),

            // Main Content Layer
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Hero Logo Composition
                  SizedBox(
                    width: 260,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // Layer 1: Outer Ember Aura
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: AppColors.ember.withValues(alpha: 0.45),
                                blurRadius: 65,
                                spreadRadius: 15,
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 900.ms)
                            .scale(
                              begin: const Offset(0.5, 0.5),
                              end: const Offset(1.2, 1.2),
                              duration: 1800.ms,
                              curve: Curves.easeOutBack,
                            ),

                        // Layer 2: Core Moonlight Halo
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.25),
                                blurRadius: 35,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        )
                            .animate(delay: 300.ms)
                            .fadeIn(duration: 800.ms)
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1.0, 1.0),
                              duration: 1200.ms,
                              curve: Curves.easeOutCubic,
                            ),

                        // Layer 3: Main Emblem Image
                        Image.asset(
                          'assets/images/blackmoon_studio_logo.png',
                          width: 220,
                          fit: BoxFit.contain,
                        )
                            .animate()
                            .fadeIn(duration: 1000.ms)
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1.0, 1.0),
                              duration: 1400.ms,
                              curve: Curves.easeOutExpo,
                            )
                            .then(delay: 300.ms)
                            .shimmer(
                              duration: 1500.ms,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PRESENTS Subtitle
                  const Text(
                    'PRESENTS',
                    style: TextStyle(
                      color: AppColors.textFaint,
                      fontSize: 10,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate(delay: 1400.ms).fadeIn(duration: 800.ms),
                ],
              ),
            ),

            // Bottom Interface Bar (Typing Indicator + Dynamic Version)
            Positioned(
              left: 24,
              right: 24,
              bottom: 36,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Left: Live Message Typing Indicator
                  const _TypingDotsIndicator()
                      .animate(delay: 1000.ms)
                      .fadeIn(duration: 600.ms),

                  // Right: Dynamic App Version Tag
                  Text(
                    displayVersion,
                    style: TextStyle(
                      color: AppColors.textFaint.withValues(alpha: 0.6),
                      fontSize: 11,
                      letterSpacing: 2,
                      fontFamily: 'Monospace',
                    ),
                  ).animate(delay: 1200.ms).fadeIn(duration: 600.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A custom real-time pulsing typing indicator widget (3 dots).
class _TypingDotsIndicator extends StatelessWidget {
  const _TypingDotsIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(3, (int index) {
        return Container(
          margin: const EdgeInsets.only(right: 4),
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.messenger.withValues(alpha: 0.85),
            shape: BoxShape.circle,
          ),
        )
            .animate(
              onPlay: (AnimationController controller) => controller.repeat(),
            )
            .fadeIn(
              duration: 400.ms,
              delay: Duration(milliseconds: index * 200),
            )
            .then(delay: 200.ms)
            .fadeOut(duration: 400.ms);
      }),
    );
  }
}
