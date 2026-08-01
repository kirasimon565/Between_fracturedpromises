import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_config.dart';
import '../../core/providers/app_providers.dart';
import '../../engine/engine.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/common.dart';

/// Player Setup.
///
/// Whatever is entered here becomes `$player_name` / `$player_pronoun` inside
/// the DSL, so the script can address the player directly without any Dart
/// knowing who they are.
class PlayerSetupScreen extends ConsumerStatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  ConsumerState<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends ConsumerState<PlayerSetupScreen> {
  static const List<String> _pronounOptions = <String>[
    'she/her',
    'they/them',
    'he/him',
  ];

  late final TextEditingController _name;
  late final TextEditingController _surname;
  String _pronouns = _pronounOptions.first;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final PlayerProfile profile = ref.read(profileControllerProvider);
    _name = TextEditingController(text: profile.name);
    final List<String> parts = profile.displayName.split(' ');
    _surname =
        TextEditingController(text: parts.length > 1 ? parts.last : 'Carter');
    if (_pronounOptions.contains(profile.pronouns)) {
      _pronouns = profile.pronouns;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _surname.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_saving) return;
    setState(() => _saving = true);

    final String first = _name.text.trim().isEmpty ? 'Nadia' : _name.text.trim();
    final String last = _surname.text.trim();

    final PlayerProfile profile = PlayerProfile(
      name: first,
      displayName: last.isEmpty ? first : '$first $last',
      pronouns: _pronouns,
      createdAt: DateTime.now(),
    );

    await ref
        .read(profileControllerProvider.notifier)
        .save(profile, onboarded: true);

    if (!mounted) return;
    context.go(Routes.menu);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.night,
      resizeToAvoidBottomInset: true,
      body: NightBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 26, 26, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      const SizedBox(height: 8),
                      const Text(
                        'WHO ARE YOU TONIGHT?',
                        style: TextStyle(
                          color: AppColors.ember,
                          fontSize: 11,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'The story was written for Nadia, but she answers to '
                        'whatever you call her.',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 14,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: CharacterAvatar(
                          id: 'nadia',
                          name: _name.text,
                          size: 92,
                          ring: AppColors.ember,
                        ),
                      ).animate().fadeIn(duration: 600.ms).scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1, 1),
                            duration: 600.ms,
                          ),
                      const SizedBox(height: 30),
                      const SectionLabel('FIRST NAME'),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 18,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Nadia',
                          counterText: '',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const SectionLabel('FAMILY NAME'),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _surname,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 18,
                        decoration: const InputDecoration(
                          hintText: 'Carter',
                          counterText: '',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const SectionLabel('PRONOUNS'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: <Widget>[
                          for (final String option in _pronounOptions)
                            ChoiceChip(
                              label: Text(option),
                              selected: _pronouns == option,
                              showCheckmark: false,
                              backgroundColor: AppColors.surfaceHigh,
                              selectedColor:
                                  AppColors.ember.withValues(alpha: 0.22),
                              side: BorderSide(
                                color: _pronouns == option
                                    ? AppColors.ember
                                    : AppColors.outline,
                              ),
                              labelStyle: TextStyle(
                                color: _pronouns == option
                                    ? AppColors.text
                                    : AppColors.textDim,
                                fontSize: 13,
                              ),
                              onSelected: (_) =>
                                  setState(() => _pronouns = option),
                            ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      const GlassCard(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Icon(Icons.lock_outline_rounded,
                                size: 18, color: AppColors.textFaint),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Saved to this device only. You can change it '
                                'later in ${AppConfig.appName} → Settings.',
                                style: TextStyle(
                                  color: AppColors.textFaint,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: _saving ? null : _continue,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
