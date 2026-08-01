import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/providers/engine_providers.dart';
import '../../core/providers/world_providers.dart';
import '../../engine/engine.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/common.dart';
import '../phone/widgets/phone_chrome.dart';

/// In-fiction Settings app. Playback preferences here are the *real* game
/// settings — the fiction and the options menu are the same screen.
class PhoneSettingsApp extends ConsumerWidget {
  const PhoneSettingsApp({super.key, this.onExit});

  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EngineSettings settings = ref.watch(settingsControllerProvider);
    final SettingsController controller = ref.read(
      settingsControllerProvider.notifier,
    );
    final PhoneState phone = ref.watch(phoneStateProvider);
    final PlayerProfile profile = ref.watch(profileProvider);
    final GameSession session = ref.watch(gameSessionProvider);

    return Column(
      children: <Widget>[
        AppHeader(
          title: 'Settings',
          accent: AppColors.forApp('settings'),
          onBack: onExit,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
            children: <Widget>[
              _ProfileCard(profile: profile, phone: phone),
              const SectionLabel('Playback'),
              _SliderTile(
                label: 'Text speed',
                value: settings.textSpeed,
                min: 0.5,
                max: 3,
                display: '${settings.textSpeed.toStringAsFixed(1)}×',
                onChanged: (double v) => controller.patch(
                  (EngineSettings s) => s.copyWith(textSpeed: v),
                ),
              ),
              _SliderTile(
                label: 'Typing speed',
                value: settings.typingSpeed,
                min: 0.5,
                max: 3,
                display: '${settings.typingSpeed.toStringAsFixed(1)}×',
                onChanged: (double v) => controller.patch(
                  (EngineSettings s) => s.copyWith(typingSpeed: v),
                ),
              ),
              _SwitchTile(
                label: 'Auto advance',
                subtitle: 'Continue without tapping',
                value: settings.autoAdvance,
                onChanged: (bool v) => controller.patch(
                  (EngineSettings s) => s.copyWith(autoAdvance: v),
                ),
              ),
              _SwitchTile(
                label: 'Skip seen scenes',
                subtitle: 'Fast-forward beats you already read',
                value: settings.skipSeen,
                onChanged: (bool v) => controller.patch(
                  (EngineSettings s) => s.copyWith(skipSeen: v),
                ),
              ),
              _SwitchTile(
                label: 'Reduced motion',
                subtitle: 'Fewer shakes, glitches and flashes',
                value: settings.reducedMotion,
                onChanged: (bool v) => controller.patch(
                  (EngineSettings s) => s.copyWith(reducedMotion: v),
                ),
              ),
              const SectionLabel('Sound'),
              _SwitchTile(
                label: 'Music',
                value: settings.musicEnabled,
                onChanged: (bool v) => controller.patch(
                  (EngineSettings s) => s.copyWith(musicEnabled: v),
                ),
              ),
              _SwitchTile(
                label: 'Sound effects',
                value: settings.soundEnabled,
                onChanged: (bool v) => controller.patch(
                  (EngineSettings s) => s.copyWith(soundEnabled: v),
                ),
              ),
              _SliderTile(
                label: 'Music volume',
                value: settings.musicVolume,
                min: 0,
                max: 1,
                display: '${(settings.musicVolume * 100).round()}%',
                onChanged: (double v) => controller.patch(
                  (EngineSettings s) => s.copyWith(musicVolume: v),
                ),
              ),
              const SectionLabel('Story'),
              _InfoTile(
                label: 'Episode',
                value: session.episodeTitle.isEmpty
                    ? '—'
                    : session.episodeTitle,
              ),
              _InfoTile(
                label: 'Current scene',
                value: session.state?.currentScene.isNotEmpty == true
                    ? session.state!.currentScene
                    : '—',
              ),
              _InfoTile(label: 'Runtime', value: session.status.name),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(gameSessionProvider.notifier).saveNow(),
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Save now'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile, required this.phone});

  final PlayerProfile profile;
  final PhoneState phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: <Widget>[
          CharacterAvatar(
            id: 'nadia',
            name: profile.displayName,
            image: profile.avatar,
            size: 52,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  profile.displayName,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${profile.pronouns} · ${phone.networkState}',
                  style: const TextStyle(
                    color: AppColors.textFaint,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: const TextStyle(color: AppColors.text, fontSize: 14.5),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: const TextStyle(color: AppColors.textFaint, fontSize: 12),
            ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: AppColors.text, fontSize: 14.5),
                ),
              ),
              Text(
                display,
                style: const TextStyle(
                  color: AppColors.textFaint,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textDim, fontSize: 13.5),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.text, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}
