import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_config.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/engine_providers.dart';
import '../../database/repositories/save_repository.dart';
import '../../engine/engine.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/common.dart';

/// Main menu: Continue, New Game, Episodes, Store, Settings.
class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> {
  bool _busy = false;

  Future<void> _continue() async {
    if (_busy) return;
    setState(() => _busy = true);
    final bool ok = await ref.read(gameSessionProvider.notifier).continueGame();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      context.go(Routes.phone);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That save could not be opened.')),
      );
    }
  }

  Future<void> _newGame({bool confirmOverwrite = true}) async {
    if (_busy) return;
    final bool hasSave = ref.read(bootstrapProvider).value?.hasSave ?? false;

    if (hasSave && confirmOverwrite) {
      final bool ok =
          await showDialog<bool>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Start over?'),
              content: const Text(
                'Beginning a new game replaces your autosave. Manual save '
                'slots are untouched.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('New game'),
                ),
              ],
            ),
          ) ??
          false;
      if (!ok) return;
    }

    setState(() => _busy = true);
    await ref.read(gameSessionProvider.notifier).newGame();
    if (!mounted) return;
    setState(() => _busy = false);

    final String? error = ref.read(gameSessionProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ref.invalidate(bootstrapProvider);
    context.go(Routes.phone);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Bootstrap> boot = ref.watch(bootstrapProvider);
    final PlayerProfile profile = ref.watch(profileControllerProvider);
    final SaveSlotSummary? last = boot.value?.lastSave;
    final int crystals = boot.value?.wallet.crystals ?? 0;

    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/backgrounds/bg_home.jpg',
            fit: BoxFit.cover,
            errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                const ColoredBox(color: AppColors.night),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xB305060A),
                  Color(0xF005060A),
                  AppColors.voidBlack,
                ],
                stops: <double>[0, 0.5, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 18, 26, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CharacterAvatar(
                        id: 'nadia',
                        name: profile.name,
                        image: profile.avatar,
                        size: 38,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              profile.displayName,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              profile.pronouns,
                              style: const TextStyle(
                                color: AppColors.textFaint,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CrystalChip(
                        amount: crystals,
                        onTap: () => context.push(Routes.store),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    AppConfig.appName.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 44,
                      letterSpacing: 15,
                      fontWeight: FontWeight.w200,
                      height: 1,
                    ),
                  ).animate().fadeIn(duration: 800.ms),
                  const SizedBox(height: 10),
                  Text(
                    AppConfig.subtitle.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.ember,
                      fontSize: 11,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 800.ms),
                  const Spacer(),
                  if (last != null)
                    _ContinueCard(summary: last, busy: _busy, onTap: _continue)
                        .animate(delay: 300.ms)
                        .fadeIn(duration: 600.ms)
                        .moveY(begin: 10, end: 0, duration: 600.ms),
                  if (last != null) const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _busy ? null : () => _newGame(),
                    style: last == null
                        ? null
                        : FilledButton.styleFrom(
                            backgroundColor: AppColors.surfaceHigh,
                            foregroundColor: AppColors.text,
                          ),
                    child: _busy && last == null
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('New game'),
                  ).animate(delay: 400.ms).fadeIn(duration: 600.ms),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _MenuLink(
                        icon: Icons.auto_stories_outlined,
                        label: 'Episodes',
                        onTap: () => context.push(Routes.episodes),
                      ),
                      _MenuLink(
                        icon: Icons.save_outlined,
                        label: 'Saves',
                        onTap: () => context.push(Routes.saves),
                      ),
                      _MenuLink(
                        icon: Icons.diamond_outlined,
                        label: 'Store',
                        onTap: () => context.push(Routes.store),
                      ),
                      _MenuLink(
                        icon: Icons.tune_rounded,
                        label: 'Settings',
                        onTap: () => context.push(Routes.settings),
                      ),
                    ],
                  ).animate(delay: 500.ms).fadeIn(duration: 600.ms),
                  const SizedBox(height: 14),
                  const Center(
                    child: Text(
                      '${AppConfig.studio} · plays entirely offline',
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
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.summary,
    required this.busy,
    required this.onTap,
  });

  final SaveSlotSummary summary;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final EpisodeManifest manifest = AppConfig.episode(summary.episodeId);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadii.card,
        onTap: busy ? null : onTap,
        child: GlassCard(
          padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
          color: AppColors.ember.withValues(alpha: 0.10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'CONTINUE · EPISODE ${manifest.number}',
                      style: const TextStyle(
                        color: AppColors.ember,
                        fontSize: 10,
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      summary.summary.isEmpty
                          ? manifest.title
                          : summary.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _played(summary.playtime),
                      style: const TextStyle(
                        color: AppColors.textFaint,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.emberGradient,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  static String _played(Duration d) {
    if (d.inMinutes < 1) return 'Just started';
    if (d.inHours < 1) return '${d.inMinutes} min played';
    return '${d.inHours}h ${d.inMinutes % 60}m played';
  }
}

class _MenuLink extends StatelessWidget {
  const _MenuLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: AppRadii.card,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: AppColors.textDim, size: 21),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: AppColors.textFaint, fontSize: 11),
          ),
        ],
      ),
    ),
  );
}
