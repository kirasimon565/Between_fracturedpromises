import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_config.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/common.dart';

/// Content warning and the offline promise, shown once before onboarding and
/// reachable again from Settings.
class DisclaimerScreen extends ConsumerWidget {
  const DisclaimerScreen({super.key});

  static const List<(IconData, String, String)>
  _points = <(IconData, String, String)>[
    (
      Icons.no_adult_content_rounded,
      'Adults only',
      'Infidelity, emotional manipulation, grief and sexual themes. '
          'Intended for players aged 18 and over.',
    ),
    (
      Icons.wifi_off_rounded,
      'Fully offline',
      'No account, no cloud, no analytics. Every choice you make lives in a '
          'database on this device and nowhere else.',
    ),
    (
      Icons.theater_comedy_outlined,
      'Fiction',
      'Every character, message and website in the game is invented. Any '
          'resemblance to real people is coincidental.',
    ),
    (
      Icons.diamond_outlined,
      'Optional purchases',
      'The story can be finished for free. Crystals only unlock extra '
          'scenes marked with a diamond.',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool onboarded =
        ref.watch(bootstrapProvider).value?.onboarded ?? false;

    return Scaffold(
      backgroundColor: AppColors.night,
      body: NightBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 30, 26, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'BEFORE YOU START',
                  style: TextStyle(
                    color: AppColors.ember,
                    fontSize: 11,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w700,
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 14),
                const Text(
                      'This is a story about\nbreaking a promise.',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 27,
                        height: 1.25,
                        fontWeight: FontWeight.w300,
                      ),
                    )
                    .animate(delay: 120.ms)
                    .fadeIn(duration: 600.ms)
                    .moveY(begin: 10, end: 0, duration: 600.ms),
                const SizedBox(height: 28),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _points.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final (IconData icon, String title, String body) =
                          _points[index];
                      return GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(icon, color: AppColors.textDim, size: 20),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          color: AppColors.text,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        body,
                                        style: const TextStyle(
                                          color: AppColors.textDim,
                                          fontSize: 12.5,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate(delay: (200 + index * 90).ms)
                          .fadeIn(duration: 500.ms)
                          .moveY(begin: 12, end: 0, duration: 500.ms);
                    },
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () =>
                      context.go(onboarded ? Routes.menu : Routes.welcome),
                  child: const Text('I understand'),
                ).animate(delay: 700.ms).fadeIn(duration: 500.ms),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    '${AppConfig.studio} · ${AppConfig.appName}: ${AppConfig.subtitle}',
                    style: TextStyle(
                      color: AppColors.textFaint,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
