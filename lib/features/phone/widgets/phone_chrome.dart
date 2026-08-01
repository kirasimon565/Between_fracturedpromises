import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/engine_providers.dart';
import '../../../core/providers/world_providers.dart';
import '../../../engine/engine.dart';
import '../../../shared/theme/app_theme.dart';

/// The in-fiction status bar: story clock, battery and signal come from the
/// script (`@time`, `@phone_battery`, `@network`), never from the real device.
class PhoneStatusBar extends ConsumerWidget {
  const PhoneStatusBar({super.key, this.tint});

  final Color? tint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PhoneState phone = ref.watch(phoneStateProvider);
    final Color color = tint ?? AppColors.text;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 18, 6),
      child: Row(
        children: <Widget>[
          Text(
            phone.clock.isEmpty ? '--:--' : phone.clock,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          if (phone.location.isNotEmpty) ...<Widget>[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                phone.location,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color.withValues(alpha: 0.45),
                  fontSize: 11,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (phone.airplaneMode)
            Icon(Icons.airplanemode_active, size: 13, color: color)
          else
            _SignalBars(strength: phone.signal, color: color),
          const SizedBox(width: 6),
          Icon(
            phone.wifi ? Icons.wifi : Icons.wifi_off,
            size: 14,
            color: phone.networkState == 'offline'
                ? AppColors.danger
                : color.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 8),
          _Battery(level: phone.battery, charging: phone.charging, color: color),
        ],
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  const _SignalBars({required this.strength, required this.color});

  final int strength;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List<Widget>.generate(4, (int i) {
        final bool on = i < strength;
        return Container(
          margin: const EdgeInsets.only(right: 1.5),
          width: 3,
          height: 4.0 + i * 2.5,
          decoration: BoxDecoration(
            color: color.withValues(alpha: on ? 0.9 : 0.22),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}

class _Battery extends StatelessWidget {
  const _Battery({
    required this.level,
    required this.charging,
    required this.color,
  });

  final int level;
  final bool charging;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final Color fill = level <= 15
        ? AppColors.danger
        : (level <= 30 ? AppColors.warning : color);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '$level',
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 22,
          height: 11,
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.45)),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: (level / 100).clamp(0.02, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
        ),
        if (charging)
          const Icon(Icons.bolt, size: 12, color: AppColors.success),
      ],
    );
  }
}

/// A single home-screen icon.
class AppIconTile extends StatelessWidget {
  const AppIconTile({
    super.key,
    required this.app,
    required this.onTap,
    this.badge = 0,
    this.freshlyInstalled = false,
  });

  final InstalledApp app;
  final VoidCallback onTap;
  final int badge;
  final bool freshlyInstalled;

  static IconData iconFor(String id) {
    switch (id) {
      case 'messenger':
        return Icons.forum_rounded;
      case 'makelove':
        return Icons.favorite_rounded;
      case 'browser':
        return Icons.language_rounded;
      case 'gallery':
        return Icons.photo_library_rounded;
      case 'contacts':
        return Icons.contacts_rounded;
      case 'calls':
        return Icons.call_rounded;
      case 'settings':
        return Icons.settings_rounded;
      case 'store':
        return Icons.diamond_rounded;
      case 'files':
        return Icons.folder_rounded;
      case 'camera':
        return Icons.photo_camera_rounded;
      case 'journal':
        return Icons.menu_book_rounded;
      default:
        return Icons.apps_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = app.accent != null
        ? Color(app.accent!)
        : AppColors.forApp(app.id);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.card,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: AppRadii.icon,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      accent.withValues(alpha: 0.92),
                      accent.withValues(alpha: 0.42),
                    ],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: accent.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(iconFor(app.id), color: Colors.white, size: 27),
              ),
              if (badge > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    constraints: const BoxConstraints(minWidth: 20),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: AppRadii.pill,
                      border: Border.all(color: AppColors.night, width: 2),
                    ),
                    child: Text(
                      badge > 99 ? '99+' : '$badge',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              if (freshlyInstalled)
                Positioned(
                  left: -2,
                  bottom: -2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: AppRadii.pill,
                      border: Border.all(color: AppColors.night, width: 1.5),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: 70,
            child: Text(
              app.name,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.text, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// The home screen: wallpaper, clock widget, app grid, dock.
class PhoneHomeScreen extends ConsumerWidget {
  const PhoneHomeScreen({super.key});

  static const List<String> dockApps = <String>[
    'calls',
    'messenger',
    'browser',
    'gallery',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<InstalledApp> apps = ref.watch(installedAppsProvider);
    final PhoneState phone = ref.watch(phoneStateProvider);
    final GameSessionController session =
        ref.read(gameSessionProvider.notifier);

    final List<InstalledApp> grid = apps
        .where((InstalledApp a) => !dockApps.contains(a.id))
        .toList(growable: false);
    final List<InstalledApp> dock = <InstalledApp>[
      for (final String id in dockApps)
        ...apps.where((InstalledApp a) => a.id == id),
    ];

    int badgeFor(String appId) {
      final int notifications = phone.notifications
          .where((GameNotification n) => n.appId == appId && !n.read)
          .length;
      final InstalledApp? app = phone.app(appId);
      return notifications + (app?.badge ?? 0);
    }

    return Column(
      children: <Widget>[
        const SizedBox(height: 26),
        _HomeClock(clock: phone.clock, date: phone.date),
        const SizedBox(height: 30),
        Expanded(
          child: GridView.count(
            crossAxisCount: 4,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            mainAxisSpacing: 22,
            crossAxisSpacing: 6,
            childAspectRatio: 0.82,
            children: <Widget>[
              for (final InstalledApp app in grid)
                AppIconTile(
                  app: app,
                  badge: badgeFor(app.id),
                  freshlyInstalled: app.source != 'system',
                  onTap: () => session.openApp(app.id),
                ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: AppRadii.card,
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              for (final InstalledApp app in dock)
                AppIconTile(
                  app: app,
                  badge: badgeFor(app.id),
                  onTap: () => session.openApp(app.id),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeClock extends StatelessWidget {
  const _HomeClock({required this.clock, required this.date});

  final String clock;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          clock.isEmpty ? '--:--' : clock,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 56,
            fontWeight: FontWeight.w200,
            letterSpacing: -1.5,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date.isEmpty ? 'Tonight' : date,
          style: const TextStyle(
            color: AppColors.textDim,
            fontSize: 13,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

/// Header shown at the top of every phone app.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.accent,
    this.leading,
    this.actions = const <Widget>[],
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final Color? accent;
  final Widget? leading;
  final List<Widget> actions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final Color color = accent ?? AppColors.text;
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 8, 14, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outline.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: <Widget>[
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              color: AppColors.textDim,
            )
          else
            const SizedBox(width: 12),
          if (leading != null) ...<Widget>[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textFaint,
                      fontSize: 11.5,
                    ),
                  ),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
