import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_config.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/database_providers.dart';
import '../../core/providers/engine_providers.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/common.dart';
import '../phone/widgets/phone_chrome.dart';

/// Which episodes have been finished, read from `episode_progress`.
final FutureProvider<Map<String, bool>> completedEpisodesProvider =
    FutureProvider<Map<String, bool>>(
        (ref) => ref.watch(collectionRepositoryProvider).completedEpisodes());

/// Episode picker.
///
/// Adding Episode 2 is a data change: drop `ep2.txt` into `assets/story` and
/// flip `available` in [AppConfig.episodes]. Nothing on this screen changes.
class EpisodesScreen extends ConsumerStatefulWidget {
  const EpisodesScreen({super.key});

  @override
  ConsumerState<EpisodesScreen> createState() => _EpisodesScreenState();
}

class _EpisodesScreenState extends ConsumerState<EpisodesScreen> {
  String? _busy;

  Future<void> _start(EpisodeManifest episode) async {
    setState(() => _busy = episode.id);
    await ref
        .read(gameSessionProvider.notifier)
        .newGame(episodeId: episode.id);
    if (!mounted) return;
    setState(() => _busy = null);

    final String? error = ref.read(gameSessionProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ref.invalidate(bootstrapProvider);
    context.go(Routes.phone);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, bool> completed =
        ref.watch(completedEpisodesProvider).value ??
            const <String, bool>{};

    return Scaffold(
      backgroundColor: AppColors.night,
      body: NightBackdrop(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              AppHeader(
                title: 'Episodes',
                subtitle: '${AppConfig.appName}: ${AppConfig.subtitle}',
                onBack: () => context.pop(),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
                  itemCount: AppConfig.episodes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final EpisodeManifest episode = AppConfig.episodes[index];
                    return _EpisodeCard(
                      episode: episode,
                      done: completed[episode.id] ?? false,
                      busy: _busy == episode.id,
                      onStart: () => _start(episode),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard({
    required this.episode,
    required this.done,
    required this.busy,
    required this.onStart,
  });

  final EpisodeManifest episode;
  final bool done;
  final bool busy;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final bool locked = !episode.available;
    return Opacity(
      opacity: locked ? 0.55 : 1,
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'EPISODE ${episode.number}',
                  style: const TextStyle(
                    color: AppColors.ember,
                    fontSize: 10,
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (done)
                  const Icon(Icons.check_circle_rounded,
                      size: 16, color: AppColors.success),
                if (locked)
                  const Icon(Icons.lock_outline_rounded,
                      size: 16, color: AppColors.textFaint),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              episode.title,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              episode.tagline,
              style: const TextStyle(
                color: AppColors.textDim,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: locked
                  ? OutlinedButton(
                      onPressed: null,
                      child: const Text('Coming soon'),
                    )
                  : FilledButton(
                      onPressed: busy ? null : onStart,
                      style: done
                          ? FilledButton.styleFrom(
                              backgroundColor: AppColors.surfaceHigh,
                              foregroundColor: AppColors.text,
                            )
                          : null,
                      child: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(done ? 'Play again' : 'Start episode'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
