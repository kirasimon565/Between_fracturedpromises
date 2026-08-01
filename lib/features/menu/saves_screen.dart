import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/app_config.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/database_providers.dart';
import '../../core/providers/engine_providers.dart';
import '../../database/repositories/save_repository.dart';
import '../../database/schema.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/common.dart';
import '../phone/widgets/phone_chrome.dart';

/// Manual save slots plus the autosave.
///
/// Loading a slot copies it over the autosave and restarts the interpreter
/// from the stored [EngineSnapshot], so the player lands on the exact line.
class SavesScreen extends ConsumerStatefulWidget {
  const SavesScreen({super.key});

  @override
  ConsumerState<SavesScreen> createState() => _SavesScreenState();
}

class _SavesScreenState extends ConsumerState<SavesScreen> {
  static const int slotCount = 6;
  int? _busySlot;

  Future<void> _load(SaveSlotSummary summary) async {
    setState(() => _busySlot = summary.slot);
    final bool ok = summary.slot == AppSchema.autoSlot
        ? await ref.read(gameSessionProvider.notifier).continueGame()
        : await ref.read(gameSessionProvider.notifier).loadSlot(summary.slot);
    if (!mounted) return;
    setState(() => _busySlot = null);
    if (ok) {
      context.go(Routes.phone);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That slot could not be opened.')),
      );
    }
  }

  Future<void> _saveInto(int slot) async {
    setState(() => _busySlot = slot);
    await ref
        .read(gameSessionProvider.notifier)
        .saveToSlot(slot, name: 'Slot $slot');
    if (!mounted) return;
    setState(() => _busySlot = null);
    ref.invalidate(saveSlotsProvider);
    ref.invalidate(bootstrapProvider);
  }

  Future<void> _delete(int slot) async {
    await ref.read(saveRepositoryProvider).deleteSlot(slot);
    if (!mounted) return;
    ref.invalidate(saveSlotsProvider);
    ref.invalidate(bootstrapProvider);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<SaveSlotSummary>> slots =
        ref.watch(saveSlotsProvider);
    final bool sessionLive = ref.watch(gameSessionProvider).isLoaded;

    return Scaffold(
      backgroundColor: AppColors.night,
      body: NightBackdrop(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              AppHeader(
                title: 'Saves',
                subtitle: 'Stored on this device',
                onBack: () => context.pop(),
              ),
              Expanded(
                child: slots.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.ember,
                    ),
                  ),
                  error: (Object e, StackTrace _) => Center(
                    child: EmptyState(
                      icon: Icons.sd_card_alert_outlined,
                      title: 'Saves unavailable',
                      message: '$e',
                    ),
                  ),
                  data: (List<SaveSlotSummary> list) {
                    final Map<int, SaveSlotSummary> bySlot =
                        <int, SaveSlotSummary>{
                      for (final SaveSlotSummary s in list) s.slot: s,
                    };
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
                      children: <Widget>[
                        const SectionLabel('AUTOSAVE'),
                        const SizedBox(height: 10),
                        _SlotCard(
                          slot: AppSchema.autoSlot,
                          summary: bySlot[AppSchema.autoSlot],
                          busy: _busySlot == AppSchema.autoSlot,
                          canWrite: false,
                          onLoad: _load,
                          onSave: _saveInto,
                          onDelete: _delete,
                        ),
                        const SizedBox(height: 24),
                        const SectionLabel('MANUAL SLOTS'),
                        const SizedBox(height: 10),
                        for (int slot = 1; slot <= slotCount; slot++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _SlotCard(
                              slot: slot,
                              summary: bySlot[slot],
                              busy: _busySlot == slot,
                              canWrite: sessionLive,
                              onLoad: _load,
                              onSave: _saveInto,
                              onDelete: _delete,
                            ),
                          ),
                      ],
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

class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.slot,
    required this.summary,
    required this.busy,
    required this.canWrite,
    required this.onLoad,
    required this.onSave,
    required this.onDelete,
  });

  final int slot;
  final SaveSlotSummary? summary;
  final bool busy;
  final bool canWrite;
  final void Function(SaveSlotSummary) onLoad;
  final void Function(int) onSave;
  final void Function(int) onDelete;

  @override
  Widget build(BuildContext context) {
    // Bind the non-empty case to its own non-nullable local: Dart's flow
    // analysis cannot promote `summary` through a separate boolean.
    final SaveSlotSummary? s =
        (summary == null || summary!.isEmpty) ? null : summary;
    final bool empty = s == null;
    final String title = slot == AppSchema.autoSlot ? 'Autosave' : 'Slot $slot';

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: empty
                  ? AppColors.surfaceHigh
                  : AppColors.ember.withValues(alpha: 0.16),
              borderRadius: AppRadii.icon,
            ),
            child: Icon(
              slot == AppSchema.autoSlot
                  ? Icons.autorenew_rounded
                  : Icons.bookmark_border_rounded,
              size: 19,
              color: empty ? AppColors.textFaint : AppColors.ember,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (s == null)
                  const Text(
                    'Empty',
                    style:
                        TextStyle(color: AppColors.textFaint, fontSize: 12),
                  )
                else ...<Widget>[
                  Text(
                    s.summary.isEmpty
                        ? AppConfig.episode(s.episodeId).title
                        : s.summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textDim,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${DateFormat('d MMM · HH:mm').format(s.updatedAt)}'
                    '   ·   ${s.label.isEmpty ? 'start' : s.label}',
                    style: const TextStyle(
                      color: AppColors.textFaint,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (busy)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else ...<Widget>[
            if (s != null)
              IconButton(
                tooltip: 'Load',
                onPressed: () => onLoad(s),
                icon: const Icon(Icons.play_arrow_rounded),
                color: AppColors.ember,
              ),
            if (slot != AppSchema.autoSlot)
              PopupMenuButton<String>(
                color: AppColors.surfaceHigh,
                icon: const Icon(Icons.more_vert_rounded,
                    size: 18, color: AppColors.textDim),
                onSelected: (String value) {
                  if (value == 'save') onSave(slot);
                  if (value == 'delete') onDelete(slot);
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'save',
                    enabled: canWrite,
                    child: Text(empty ? 'Save here' : 'Overwrite'),
                  ),
                  if (!empty)
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
