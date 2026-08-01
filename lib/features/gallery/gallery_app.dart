import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/database_providers.dart';
import '../../core/providers/world_providers.dart';
import '../../engine/engine.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/common.dart';
import '../phone/widgets/phone_chrome.dart';

/// Everything the player has unlocked, merged from the running episode and the
/// profile-wide collection in Drift.
final FutureProvider<List<GalleryUnlock>> galleryLibraryProvider =
    FutureProvider<List<GalleryUnlock>>((ref) async {
      final List<GalleryUnlock> saved = await ref
          .watch(collectionRepositoryProvider)
          .gallery();
      final List<GalleryUnlock> live = ref.watch(galleryProvider);

      final Map<String, GalleryUnlock> merged = <String, GalleryUnlock>{
        for (final GalleryUnlock item in saved) item.id: item,
        for (final GalleryUnlock item in live) item.id: item,
      };
      final List<GalleryUnlock> all = merged.values.toList();
      all.sort(
        (GalleryUnlock a, GalleryUnlock b) => (b.unlockedAt ?? DateTime(0))
            .compareTo(a.unlockedAt ?? DateTime(0)),
      );
      return all;
    });

class GalleryApp extends ConsumerWidget {
  const GalleryApp({super.key, this.onExit});

  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<GalleryUnlock>> library = ref.watch(
      galleryLibraryProvider,
    );

    return Column(
      children: <Widget>[
        AppHeader(
          title: 'Gallery',
          subtitle: library.value == null
              ? null
              : '${library.value!.length} unlocked',
          accent: AppColors.forApp('gallery'),
          onBack: onExit,
        ),
        Expanded(
          child: library.when(
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (Object e, _) => EmptyState(
              icon: Icons.broken_image_outlined,
              title: 'Could not read the gallery',
              message: '$e',
            ),
            data: (List<GalleryUnlock> items) => items.isEmpty
                ? const EmptyState(
                    icon: Icons.photo_library_outlined,
                    title: 'Nothing saved yet',
                    message:
                        'Moments you live through get archived here — the good ones and the ones you will want to forget.',
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(14),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) =>
                        _GalleryTile(
                          item: items[index],
                          onTap: () => _open(context, items[index]),
                        ),
                  ),
          ),
        ),
      ],
    );
  }

  void _open(BuildContext context, GalleryUnlock item) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: AppRadii.card,
              child: Image.asset(
                item.image,
                errorBuilder: (_, _, _) => Container(
                  height: 260,
                  color: AppColors.surfaceHigh,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.textFaint,
                    size: 34,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.text, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({required this.item, required this.onTap});

  final GalleryUnlock item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.card,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadii.card,
          color: AppColors.surface,
          border: Border.all(color: AppColors.outline),
          image: DecorationImage(
            image: AssetImage(item.image),
            fit: BoxFit.cover,
            opacity: 0.9,
            onError: (_, _) {},
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 22, 12, 12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.transparent,
                    AppColors.voidBlack.withValues(alpha: 0.9),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.category,
                    style: const TextStyle(
                      color: AppColors.textFaint,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
