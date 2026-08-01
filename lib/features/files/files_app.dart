import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/world_providers.dart';
import '../../engine/engine.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/common.dart';
import '../phone/widgets/phone_chrome.dart';

/// Files — currently a read-only view of what the browser downloaded and what
/// the story filed as evidence. Reserved for the document-forensics thread in
/// later episodes.
class FilesApp extends ConsumerWidget {
  const FilesApp({super.key, this.onExit});

  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BrowserState browser = ref.watch(browserStateProvider);
    final List<EvidenceEntry> evidence = ref.watch(evidenceProvider);

    final bool empty = browser.downloads.isEmpty && evidence.isEmpty;

    return Column(
      children: <Widget>[
        AppHeader(
          title: 'Files',
          accent: AppColors.forApp('files'),
          onBack: onExit,
        ),
        Expanded(
          child: empty
              ? const EmptyState(
                  icon: Icons.folder_open_outlined,
                  title: 'Nothing saved',
                  message: 'Downloads and anything you keep will show up here.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                  children: <Widget>[
                    if (browser.downloads.isNotEmpty) ...<Widget>[
                      const SectionLabel('Downloads'),
                      for (final BrowserDownload d in browser.downloads)
                        _FileRow(
                          icon: Icons.android_rounded,
                          title: '${d.name}.apk',
                          subtitle: d.sizeLabel,
                          trailing: d.completed ? 'Installed' : 'Pending',
                        ),
                    ],
                    if (evidence.isNotEmpty) ...<Widget>[
                      const SectionLabel('Kept'),
                      for (final EvidenceEntry e in evidence)
                        _FileRow(
                          icon: Icons.description_outlined,
                          title: e.title,
                          subtitle: e.description,
                          trailing: e.category,
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: AppColors.textDim),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title,
                    style: const TextStyle(
                        color: AppColors.text, fontSize: 13.5)),
                if (subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textFaint, fontSize: 11.5),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null)
            Text(trailing!,
                style: const TextStyle(
                    color: AppColors.textFaint, fontSize: 11)),
        ],
      ),
    );
  }
}

/// Camera — a deliberate dead end for now. Episode 3 opens it up.
class CameraApp extends StatelessWidget {
  const CameraApp({super.key, this.onExit});

  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AppHeader(
          title: 'Camera',
          accent: AppColors.forApp('camera'),
          onBack: onExit,
        ),
        const Expanded(
          child: EmptyState(
            icon: Icons.photo_camera_outlined,
            title: 'Not tonight',
            message:
                'You look at the lens, then at the ceiling, then you put the phone down.',
          ),
        ),
      ],
    );
  }
}
