import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_config.dart';
import '../../core/providers/app_providers.dart';
import '../../engine/engine.dart';
import '../../shared/theme/app_theme.dart';

/// The pitch. Sets the premise before the player is asked for a name.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  static const List<String> _lines = <String>[
    'You are Nadia.',
    'Six years married. Two of them quiet.',
    'Tonight a stranger answers a message you never should have sent.',
    'The whole story happens on this phone.',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/backgrounds/bg_welcome.jpg',
            fit: BoxFit.cover,
            errorBuilder: (BuildContext _, Object __, StackTrace? ___) =>
                const ColoredBox(color: AppColors.night),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xCC05060A),
                  Color(0xE605060A),
                  AppColors.voidBlack,
                ],
                stops: <double>[0, 0.55, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Spacer(),
                  Text(
                    AppConfig.appName.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 40,
                      letterSpacing: 14,
                      fontWeight: FontWeight.w200,
                      height: 1,
                    ),
                  ).animate().fadeIn(duration: 900.ms),
                  const SizedBox(height: 10),
                  Text(
                    AppConfig.subtitle.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.ember,
                      fontSize: 12,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate(delay: 300.ms).fadeIn(duration: 900.ms),
                  const SizedBox(height: 38),
                  for (int i = 0; i < _lines.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        _lines[i],
                        style: TextStyle(
                          color: i == _lines.length - 1
                              ? AppColors.textDim
                              : AppColors.text,
                          fontSize: 16,
                          height: 1.55,
                          fontWeight: FontWeight.w300,
                        ),
                      )
                          .animate(delay: (700 + i * 320).ms)
                          .fadeIn(duration: 800.ms)
                          .moveY(begin: 8, end: 0, duration: 800.ms),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => context.go(Routes.setup),
                    child: const Text('Begin'),
                  ).animate(delay: 2200.ms).fadeIn(duration: 700.ms),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      // Accepts the default identity so the router still sees
                      // a finished onboarding.
                      onPressed: () async {
                        await ref
                            .read(profileControllerProvider.notifier)
                            .save(const PlayerProfile(), onboarded: true);
                        if (context.mounted) context.go(Routes.menu);
                      },
                      child: const Text('Skip and play as Nadia'),
                    ),
                  ).animate(delay: 2500.ms).fadeIn(duration: 700.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
