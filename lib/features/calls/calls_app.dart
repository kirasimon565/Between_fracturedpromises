import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/engine_providers.dart';
import '../../core/providers/world_providers.dart';
import '../../engine/engine.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/common.dart';
import '../phone/widgets/phone_chrome.dart';

/// Call log. Entries are written by `@call_incoming`, `@missed_call`,
/// `@voicemail` and friends.
class CallsApp extends ConsumerWidget {
  const CallsApp({super.key, this.onExit});

  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PhoneState phone = ref.watch(phoneStateProvider);
    final Map<String, CharacterState> characters =
        ref.watch(charactersProvider);
    final List<PhoneCall> calls = phone.calls.reversed.toList(growable: false);

    return Column(
      children: <Widget>[
        AppHeader(
          title: 'Phone',
          subtitle: calls.isEmpty ? 'No recent calls' : '${calls.length} recent',
          accent: AppColors.forApp('calls'),
          onBack: onExit,
        ),
        Expanded(
          child: calls.isEmpty
              ? const EmptyState(
                  icon: Icons.call_outlined,
                  title: 'No calls',
                  message: 'Nobody has called. That is its own kind of answer.',
                )
              : ListView.separated(
                  itemCount: calls.length,
                  separatorBuilder: (_, __) => const Divider(
                      indent: 72, height: 1, color: AppColors.outline),
                  itemBuilder: (BuildContext context, int index) {
                    final PhoneCall call = calls[index];
                    final CharacterState? character =
                        characters[call.characterId];
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 18),
                      leading: CharacterAvatar(
                        id: call.characterId,
                        name: character?.name,
                        image: character?.avatar,
                        size: 42,
                      ),
                      title: Text(
                        character?.name ?? call.characterId,
                        style: const TextStyle(
                            color: AppColors.text, fontSize: 15),
                      ),
                      subtitle: Row(
                        children: <Widget>[
                          Icon(_iconFor(call.state),
                              size: 13, color: _colorFor(call.state)),
                          const SizedBox(width: 6),
                          Text(
                            _labelFor(call),
                            style: const TextStyle(
                                color: AppColors.textFaint, fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () =>
                            ref.read(gameSessionProvider.notifier).emitUiEvent(
                          'call_requested',
                          data: <String, Object?>{
                            'character': call.characterId
                          },
                        ),
                        icon: const Icon(Icons.call_rounded, size: 18),
                        color: AppColors.success,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  static IconData _iconFor(CallState state) => switch (state) {
        CallState.missed => Icons.call_missed_rounded,
        CallState.incoming => Icons.call_received_rounded,
        CallState.voicemail => Icons.voicemail_rounded,
        CallState.ended => Icons.call_made_rounded,
        _ => Icons.call_rounded,
      };

  static Color _colorFor(CallState state) => switch (state) {
        CallState.missed => AppColors.danger,
        CallState.voicemail => AppColors.warning,
        _ => AppColors.textFaint,
      };

  static String _labelFor(PhoneCall call) {
    final String kind = switch (call.state) {
      CallState.missed => 'Missed',
      CallState.voicemail => 'Voicemail',
      CallState.incoming => 'Incoming',
      CallState.ended => 'Outgoing',
      _ => 'Call',
    };
    final String time = '${call.startedAt.hour.toString().padLeft(2, '0')}'
        ':${call.startedAt.minute.toString().padLeft(2, '0')}';
    return '$kind · $time';
  }
}
