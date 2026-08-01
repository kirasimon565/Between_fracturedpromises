import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/world_providers.dart';
import '../../engine/engine.dart';
import '../../shared/theme/app_theme.dart';
import '../messenger/messenger_app.dart';

/// Makelove — the app Nadia should not have installed.
///
/// It is the messenger with a hotter skin plus a "Discover" tab, and it only
/// exists on the home screen once the story installed it through
/// `@browser_download`.
class MakeloveApp extends ConsumerStatefulWidget {
  const MakeloveApp({super.key, this.onExit, this.onOpenStore});

  final VoidCallback? onExit;
  final void Function(int requiredCrystals)? onOpenStore;

  @override
  ConsumerState<MakeloveApp> createState() => _MakeloveAppState();
}

class _MakeloveAppState extends ConsumerState<MakeloveApp> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final List<ChatThread> threads = ref.watch(threadsForAppProvider('makelove'));
    final bool hasConversation = threads.isNotEmpty;

    // Once someone is actually talking, matches stop being the point.
    final int tab = hasConversation ? _tab : 1;

    return Column(
      children: <Widget>[
        Expanded(
          child: IndexedStack(
            index: tab,
            children: <Widget>[
              MessengerApp(
                appId: 'makelove',
                title: 'Makelove',
                accent: AppColors.makelove,
                onExit: widget.onExit,
                onOpenStore: widget.onOpenStore,
              ),
              _DiscoverTab(onExit: widget.onExit),
            ],
          ),
        ),
        _MakeloveTabBar(
          index: tab,
          badge: threads.fold<int>(
              0, (int sum, ChatThread t) => sum + t.unread),
          onChanged: (int value) => setState(() => _tab = value),
        ),
      ],
    );
  }
}

class _MakeloveTabBar extends StatelessWidget {
  const _MakeloveTabBar({
    required this.index,
    required this.onChanged,
    this.badge = 0,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: <Widget>[
              _tab(0, Icons.chat_bubble_rounded, 'Chats', badge),
              _tab(1, Icons.local_fire_department_rounded, 'Discover', 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(int value, IconData icon, String label, int badge) {
    final bool active = index == value;
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(value),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Icon(icon,
                    size: 20,
                    color: active ? AppColors.makelove : AppColors.textFaint),
                if (badge > 0)
                  Positioned(
                    right: -6,
                    top: -3,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.makelove,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: active ? AppColors.makelove : AppColors.textFaint,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Deliberately hollow: the app promises connection and delivers a carousel.
class _DiscoverTab extends StatelessWidget {
  const _DiscoverTab({this.onExit});

  final VoidCallback? onExit;

  static const List<(String, String, String)> _profiles =
      <(String, String, String)>[
    ('Daniel', '34 · 2 km away', 'Listens more than he talks.'),
    ('Marcus', '31 · 5 km away', 'Gym, dogs, bad jokes.'),
    ('Ari', '29 · 7 km away', 'Here by accident. Staying on purpose.'),
    ('Jonah', '38 · 11 km away', 'Recently divorced. Not sad about it.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.outline)),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.favorite_rounded,
                  color: AppColors.makelove, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'makelove',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              if (onExit != null)
                IconButton(
                  onPressed: onExit,
                  icon: const Icon(Icons.close_rounded, size: 19),
                  color: AppColors.textDim,
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _profiles.length,
            itemBuilder: (BuildContext context, int index) {
              final (String name, String meta, String bio) = _profiles[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: AppRadii.card,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      AppColors.makelove.withValues(alpha: 0.14),
                      AppColors.surface,
                    ],
                  ),
                  border: Border.all(
                      color: AppColors.makelove.withValues(alpha: 0.18)),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.makelove.withValues(alpha: 0.25),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        name[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            name,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(meta,
                              style: const TextStyle(
                                  color: AppColors.textFaint, fontSize: 11.5)),
                          const SizedBox(height: 6),
                          Text(bio,
                              style: const TextStyle(
                                  color: AppColors.textDim,
                                  fontSize: 12.5,
                                  height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  .animate(delay: Duration(milliseconds: 70 * index))
                  .fadeIn(duration: 320.ms)
                  .slideY(begin: 0.1, end: 0);
            },
          ),
        ),
      ],
    );
  }
}
