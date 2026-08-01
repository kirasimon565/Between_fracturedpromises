import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/engine_providers.dart';
import '../../core/providers/world_providers.dart';
import '../../engine/engine.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/common.dart';
import '../phone/widgets/phone_chrome.dart';

/// Contacts, populated by the script (`@character`, `@contact`).
///
/// Tapping a contact shows the relationship the engine is tracking, which makes
/// the invisible state of the story legible without ever spelling out numbers
/// the writer did not intend to expose.
class ContactsApp extends ConsumerWidget {
  const ContactsApp({super.key, this.onExit});

  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, CharacterState> characters =
        ref.watch(charactersProvider);
    final List<CharacterState> people = characters.values
        .where((CharacterState c) => c.id != 'system' && c.id != 'narrator')
        .toList()
      ..sort((CharacterState a, CharacterState b) => a.name.compareTo(b.name));

    return Column(
      children: <Widget>[
        AppHeader(
          title: 'Contacts',
          subtitle: '${people.length} people',
          accent: AppColors.forApp('contacts'),
          onBack: onExit,
        ),
        Expanded(
          child: people.isEmpty
              ? const EmptyState(
                  icon: Icons.contacts_outlined,
                  title: 'Nobody yet',
                  message: 'People appear here as they enter your life.',
                )
              : ListView.separated(
                  itemCount: people.length,
                  separatorBuilder: (_, _) => const Divider(
                      indent: 76, height: 1, color: AppColors.outline),
                  itemBuilder: (BuildContext context, int index) => _ContactTile(
                    character: people[index],
                    onTap: () => _showProfile(context, ref, people[index]),
                  ),
                ),
        ),
      ],
    );
  }

  void _showProfile(
    BuildContext context,
    WidgetRef ref,
    CharacterState character,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => _ContactSheet(character: character),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.character, required this.onTap});

  final CharacterState character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: CharacterAvatar(
        id: character.id,
        name: character.name,
        image: character.avatar,
        size: 44,
        online: character.isOnline,
      ),
      title: Text(
        character.name,
        style: const TextStyle(color: AppColors.text, fontSize: 15),
      ),
      subtitle: Text(
        character.about ?? character.status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textFaint, fontSize: 12),
      ),
      trailing: character.favorite
          ? const Icon(Icons.star_rounded, size: 16, color: AppColors.warning)
          : null,
    );
  }
}

class _ContactSheet extends ConsumerWidget {
  const _ContactSheet({required this.character});

  final CharacterState character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Relationship relationship =
        ref.watch(relationshipsProvider)[character.id] ??
            Relationship(characterId: character.id);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.sheet,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            CharacterAvatar(
              id: character.id,
              name: character.name,
              image: character.avatar,
              size: 76,
              online: character.isOnline,
            ),
            const SizedBox(height: 14),
            Text(
              character.name,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (character.about != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                character.about!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textFaint, fontSize: 12.5, height: 1.5),
              ),
            ],
            const SizedBox(height: 22),
            for (final RelationshipAxis axis in RelationshipAxis.values)
              _AxisBar(
                label: axis.name,
                value: relationship.axis(axis).toDouble(),
              ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ref
                          .read(gameSessionProvider.notifier)
                          .openApp('messenger', threadId: character.id);
                    },
                    icon: const Icon(Icons.forum_outlined, size: 17),
                    label: const Text('Message'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ref.read(gameSessionProvider.notifier).emitUiEvent(
                        'call_requested',
                        data: <String, Object?>{'character': character.id},
                      );
                    },
                    icon: const Icon(Icons.call_outlined, size: 17),
                    label: const Text('Call'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AxisBar extends StatelessWidget {
  const _AxisBar({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    // Axes run −100…100; map to 0…1 for the bar.
    final double normalised = ((value + 100) / 200).clamp(0.0, 1.0);
    final Color color = switch (label) {
      'trust' => AppColors.messenger,
      'friendship' => AppColors.success,
      'love' => AppColors.makelove,
      'tension' => AppColors.warning,
      _ => AppColors.danger,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(
                  color: AppColors.textFaint, fontSize: 11.5),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: normalised,
                minHeight: 5,
                color: color,
                backgroundColor: AppColors.surfaceHigh,
              ),
            ),
          ),
          SizedBox(
            width: 38,
            child: Text(
              value.round().toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.textDim, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }
}
