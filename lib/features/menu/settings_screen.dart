import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_config.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/database_providers.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/common.dart';
import '../phone/widgets/phone_chrome.dart';
import '../settings/phone_settings_app.dart';

/// Settings reached from the main menu.
///
/// It embeds the *in-fiction* settings app so there is exactly one options
/// screen in the game, then appends the things that only make sense outside
/// the story: the disclaimer, the debug console and erasing all data.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.night,
      body: NightBackdrop(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: PhoneSettingsApp(onExit: () => context.pop()),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => context.push(Routes.disclaimer),
                        icon: const Icon(Icons.policy_outlined, size: 17),
                        label: const Text('Disclaimer'),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => context.push(Routes.debug),
                        icon: const Icon(Icons.terminal_rounded, size: 17),
                        label: const Text('Debug'),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _eraseEverything(context, ref),
                        icon: const Icon(Icons.delete_forever_outlined,
                            size: 17, color: AppColors.danger),
                        label: const Text(
                          'Erase',
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _eraseEverything(BuildContext context, WidgetRef ref) async {
    final bool ok = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Erase everything?'),
            content: const Text(
              'Saves, crystals, unlocked scenes and achievements are deleted '
              'from this device. Purchases can be brought back with '
              '“Restore purchases”.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.danger),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Erase'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;

    await ref.read(appDatabaseProvider).eraseEverything();
    ref.invalidate(bootstrapProvider);
    ref.invalidate(saveSlotsProvider);
    if (context.mounted) context.go(Routes.splash);
  }
}
