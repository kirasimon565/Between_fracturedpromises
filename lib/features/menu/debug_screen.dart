import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_config.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/engine_providers.dart';
import '../../core/providers/world_providers.dart';
import '../../engine/engine.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/common.dart';
import '../phone/widgets/phone_chrome.dart';

/// Script console.
///
/// Compiles any episode without running it and prints the diagnostics the
/// parser produced, plus a live view of the interpreter: current label, program
/// counter, variables, flags and relationships. This is the writer's tool — it
/// is the only place in the app that talks about labels and line numbers.
class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  String _episodeId = AppConfig.defaultEpisodeId;
  CompiledStory? _compiled;
  String? _compileError;
  bool _compiling = false;

  Future<void> _compile() async {
    setState(() {
      _compiling = true;
      _compileError = null;
      _compiled = null;
    });
    try {
      final CompiledStory story = await ref
          .read(gameSessionProvider.notifier)
          .compileOnly(_episodeId);
      if (!mounted) return;
      setState(() {
        _compiled = story;
        _compiling = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _compileError = '$error';
        _compiling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final GameSession session = ref.watch(gameSessionProvider);
    final EngineSettings settings = ref.watch(settingsControllerProvider);
    final GameState? state = session.state;

    return Scaffold(
      backgroundColor: AppColors.night,
      body: NightBackdrop(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              AppHeader(
                title: 'Debug console',
                subtitle: 'Engine v2 · DSL interpreter',
                onBack: () => context.pop(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                  children: <Widget>[
                    const SectionLabel('COMPILER'),
                    const SizedBox(height: 10),
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Wrap(
                            spacing: 8,
                            children: <Widget>[
                              for (final EpisodeManifest e
                                  in AppConfig.episodes)
                                ChoiceChip(
                                  label: Text('EP${e.number}'),
                                  selected: _episodeId == e.id,
                                  showCheckmark: false,
                                  backgroundColor: AppColors.surfaceHigh,
                                  selectedColor: AppColors.ember.withValues(
                                    alpha: 0.22,
                                  ),
                                  onSelected: (_) =>
                                      setState(() => _episodeId = e.id),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _compiling ? null : _compile,
                              icon: _compiling
                                  ? const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.play_circle_outline,
                                      size: 18,
                                    ),
                              label: const Text('Compile script'),
                            ),
                          ),
                          if (_compileError != null) ...<Widget>[
                            const SizedBox(height: 12),
                            Text(
                              _compileError!,
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (_compiled != null) ...<Widget>[
                            const SizedBox(height: 14),
                            _kv('Title', _compiled!.title),
                            _kv('Episode', '${_compiled!.episodeNumber}'),
                            _kv(
                              'Sources',
                              '${_compiled!.sources.length} file(s)',
                            ),
                            _kv(
                              'Instructions',
                              '${_compiled!.program.instructions.length}',
                            ),
                            _kv(
                              'Labels',
                              '${_compiled!.program.labels.length}',
                            ),
                            _kv(
                              'Diagnostics',
                              '${_compiled!.diagnostics.length}',
                            ),
                            if (_compiled!.diagnostics.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 10),
                              for (final Diagnostic d
                                  in _compiled!.diagnostics.take(40))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    d.toString(),
                                    style: TextStyle(
                                      color: d.isError
                                          ? AppColors.danger
                                          : AppColors.warning,
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const SectionLabel('RUNTIME'),
                    const SizedBox(height: 10),
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _kv('Status', session.status.name),
                          _kv(
                            'Episode',
                            session.episodeId.isEmpty
                                ? '—'
                                : '${session.episodeId} · ${session.episodeTitle}',
                          ),
                          _kv('Revision', '${session.revision}'),
                          _kv(
                            'Label',
                            ref
                                    .read(gameSessionProvider.notifier)
                                    .runtime
                                    ?.currentLabel ??
                                '—',
                          ),
                          _kv(
                            'PC',
                            '${ref.read(gameSessionProvider.notifier).runtime?.programCounter ?? 0}',
                          ),
                          _kv(
                            'Pending choice',
                            session.choice?.options.length.toString() ?? '—',
                          ),
                          if (session.error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                session.error!,
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const SectionLabel('FAST PLAYBACK'),
                    const SizedBox(height: 10),
                    GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: <Widget>[
                          SwitchListTile(
                            title: const Text('Instant mode'),
                            subtitle: const Text('Ignore every story delay'),
                            value: settings.instantMode,
                            onChanged: (bool v) => ref
                                .read(settingsControllerProvider.notifier)
                                .patch(
                                  (EngineSettings s) =>
                                      s.copyWith(instantMode: v),
                                ),
                          ),
                          SwitchListTile(
                            title: const Text('Debug overlay'),
                            subtitle: const Text('Show labels while playing'),
                            value: settings.debugOverlay,
                            onChanged: (bool v) => ref
                                .read(settingsControllerProvider.notifier)
                                .patch(
                                  (EngineSettings s) =>
                                      s.copyWith(debugOverlay: v),
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (state != null) ...<Widget>[
                      const SizedBox(height: 22),
                      const SectionLabel('VARIABLES'),
                      const SizedBox(height: 10),
                      _MapCard(
                        entries: state.variables.toJson().map(
                          (String k, Object? v) =>
                              MapEntry<String, String>(k, '$v'),
                        ),
                        empty: 'No variables set yet.',
                      ),
                      const SizedBox(height: 22),
                      const SectionLabel('FLAGS'),
                      const SizedBox(height: 10),
                      _MapCard(
                        entries: <String, String>{
                          for (final String f in state.flags) f: 'true',
                        },
                        empty: 'No flags raised yet.',
                      ),
                      const SizedBox(height: 22),
                      const SectionLabel('RELATIONSHIPS'),
                      const SizedBox(height: 10),
                      _MapCard(
                        entries: <String, String>{
                          for (final MapEntry<String, Relationship> e
                              in ref.watch(relationshipsProvider).entries)
                            e.key:
                                'trust ${e.value.trust} · '
                                'love ${e.value.love} · '
                                'friendship ${e.value.friendship}',
                        },
                        empty: 'Nobody has met anybody yet.',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(String key, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 108,
          child: Text(
            key,
            style: const TextStyle(color: AppColors.textFaint, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    ),
  );
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.entries, required this.empty});

  final Map<String, String> entries;
  final String empty;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(16),
        child: Text(
          empty,
          style: const TextStyle(color: AppColors.textFaint, fontSize: 12),
        ),
      );
    }
    final List<String> keys = entries.keys.toList()..sort();
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final String key in keys)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: '$key  ',
                      style: const TextStyle(
                        color: AppColors.textDim,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                    TextSpan(
                      text: entries[key],
                      style: const TextStyle(
                        color: AppColors.crystal,
                        fontSize: 12,
                        fontFamily: 'monospace',
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
