import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/audio_controller.dart';
import '../../../core/providers/engine_providers.dart';
import '../../../core/providers/world_providers.dart';
import '../../../engine/engine.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/common.dart';
import 'phone_chrome.dart';

/// Renders every transient [EngineEffect] on top of the phone.
///
/// The engine says *what* happened; this widget decides how it looks. Adding a
/// new visual effect means adding a case here, not touching the interpreter.
class EffectOverlayHost extends ConsumerStatefulWidget {
  const EffectOverlayHost({
    super.key,
    required this.child,
    this.onNavigate,
    this.onOpenStore,
  });

  final Widget child;
  final void Function(String route)? onNavigate;
  final void Function(StoreEffect effect)? onOpenStore;

  @override
  ConsumerState<EffectOverlayHost> createState() => _EffectOverlayHostState();
}

class _EffectOverlayHostState extends ConsumerState<EffectOverlayHost>
    with TickerProviderStateMixin {
  ToastEffect? _toast;
  BannerEffect? _banner;
  ShowImageEffect? _image;
  TitleCardEffect? _titleCard;
  AppInstallEffect? _install;
  AchievementEffect? _achievement;

  Timer? _toastTimer;
  Timer? _bannerTimer;
  Timer? _imageTimer;
  Timer? _titleTimer;
  Timer? _achievementTimer;

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  Color? _flash;

  @override
  void dispose() {
    _toastTimer?.cancel();
    _bannerTimer?.cancel();
    _imageTimer?.cancel();
    _titleTimer?.cancel();
    _achievementTimer?.cancel();
    _shake.dispose();
    super.dispose();
  }

  void _handle(EngineEffect effect) {
    final AudioController audio = ref.read(audioControllerProvider);
    unawaited(audio.handle(effect));

    if (effect is ToastEffect) {
      setState(() => _toast = effect);
      _toastTimer?.cancel();
      _toastTimer = Timer(effect.duration, () {
        if (mounted) setState(() => _toast = null);
      });
      return;
    }
    if (effect is BannerEffect) {
      setState(() => _banner = effect);
      _bannerTimer?.cancel();
      _bannerTimer = Timer(effect.duration, () {
        if (mounted) setState(() => _banner = null);
      });
      return;
    }
    if (effect is ShowImageEffect) {
      setState(() => _image = effect);
      _imageTimer?.cancel();
      if (effect.duration != null) {
        _imageTimer = Timer(effect.duration!, () {
          if (mounted) setState(() => _image = null);
        });
      }
      return;
    }
    if (effect is HideImageEffect) {
      setState(() => _image = null);
      return;
    }
    if (effect is TitleCardEffect) {
      setState(() => _titleCard = effect);
      _titleTimer?.cancel();
      _titleTimer = Timer(effect.duration, () {
        if (mounted) setState(() => _titleCard = null);
      });
      return;
    }
    if (effect is AppInstallEffect) {
      setState(() => _install = effect);
      Timer(effect.duration + const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _install = null);
      });
      return;
    }
    if (effect is AchievementEffect) {
      setState(() => _achievement = effect);
      _achievementTimer?.cancel();
      _achievementTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _achievement = null);
      });
      return;
    }
    if (effect is ScreenEffect) {
      _playScreenEffect(effect);
      return;
    }
    if (effect is DialogEffect) {
      _showDialog(effect);
      return;
    }
    if (effect is StoreEffect) {
      widget.onOpenStore?.call(effect);
      return;
    }
    if (effect is NavigateEffect) {
      widget.onNavigate?.call(effect.route);
      return;
    }
  }

  void _playScreenEffect(ScreenEffect effect) {
    switch (effect.effect) {
      case 'shake':
      case 'glitch':
      case 'shatter':
        _shake
          ..duration = effect.duration
          ..forward(from: 0);
        break;
      case 'flash':
        setState(
          () => _flash = effect.color == null
              ? Colors.white
              : Color(effect.color!),
        );
        Timer(effect.duration, () {
          if (mounted) setState(() => _flash = null);
        });
        break;
      case 'fade':
        setState(() => _flash = Colors.black);
        Timer(effect.duration, () {
          if (mounted) setState(() => _flash = null);
        });
        break;
    }
  }

  Future<void> _showDialog(DialogEffect effect) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(effect.title),
        content: Text(effect.body),
        actions: <Widget>[
          if (effect.cancelLabel != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(effect.cancelLabel!),
            ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(effect.confirmLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<EngineEffect>>(engineEffectProvider, (
      AsyncValue<EngineEffect>? previous,
      AsyncValue<EngineEffect> next,
    ) {
      final EngineEffect? effect = next.value;
      if (effect != null) _handle(effect);
    });

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        AnimatedBuilder(
          animation: _shake,
          builder: (BuildContext context, Widget? child) {
            if (_shake.value == 0 || _shake.isCompleted) return child!;
            final double amount =
                math.sin(_shake.value * math.pi * 8) * 8 * (1 - _shake.value);
            return Transform.translate(
              offset: Offset(amount, amount / 2),
              child: child,
            );
          },
          child: widget.child,
        ),
        if (_flash != null)
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: 0.75,
              duration: const Duration(milliseconds: 120),
              child: ColoredBox(color: _flash!),
            ),
          ),
        const NotificationLayer(),
        if (_install != null) _InstallOverlay(effect: _install!),
        if (_titleCard != null) _TitleCardOverlay(effect: _titleCard!),
        if (_image != null)
          _ImageOverlay(
            effect: _image!,
            onClose: () => setState(() => _image = null),
          ),
        if (_achievement != null)
          _AchievementToast(achievement: _achievement!.achievement),
        if (_banner != null) _BannerOverlay(effect: _banner!),
        if (_toast != null) _ToastOverlay(effect: _toast!),
      ],
    );
  }
}

/// Heads-up notification banners posted with `@notification`.
class NotificationLayer extends ConsumerStatefulWidget {
  const NotificationLayer({super.key});

  @override
  ConsumerState<NotificationLayer> createState() => _NotificationLayerState();
}

class _NotificationLayerState extends ConsumerState<NotificationLayer> {
  String? _shownId;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<GameNotification> notifications = ref.watch(
      notificationsProvider,
    );
    final GameNotification? latest = notifications.isEmpty
        ? null
        : notifications.firstWhere(
            (GameNotification n) => !n.read,
            orElse: () => notifications.first,
          );

    if (latest == null || latest.read) return const SizedBox.shrink();

    if (_shownId != latest.id) {
      _shownId = latest.id;
      _timer?.cancel();
      if (!latest.sticky) {
        _timer = Timer(const Duration(seconds: 4), () {
          if (mounted) {
            ref
                .read(gameSessionProvider.notifier)
                .dismissNotification(latest.id);
          }
        });
      }
    }

    final Color accent = AppColors.forApp(latest.appId);

    return Positioned(
      top: 8,
      left: 12,
      right: 12,
      child:
          Dismissible(
                key: ValueKey<String>(latest.id),
                direction: DismissDirection.up,
                onDismissed: (_) => ref
                    .read(gameSessionProvider.notifier)
                    .dismissNotification(latest.id),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.2),
                          borderRadius: AppRadii.icon,
                        ),
                        child: Icon(
                          AppIconTile.iconFor(latest.appId),
                          size: 18,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              latest.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            if (latest.body.isNotEmpty)
                              Text(
                                latest.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textDim,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (latest.threadId != null)
                        TextButton(
                          onPressed: () {
                            final GameSessionController session = ref.read(
                              gameSessionProvider.notifier,
                            );
                            session.dismissNotification(latest.id);
                            session.openApp(
                              latest.appId,
                              threadId: latest.threadId,
                            );
                          },
                          child: const Text('Open'),
                        ),
                    ],
                  ),
                ),
              )
              .animate()
              .slideY(
                begin: -0.4,
                end: 0,
                duration: 320.ms,
                curve: Curves.easeOutCubic,
              )
              .fadeIn(duration: 240.ms),
    );
  }
}

class _ToastOverlay extends StatelessWidget {
  const _ToastOverlay({required this.effect});

  final ToastEffect effect;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 92,
      left: 40,
      right: 40,
      child: IgnorePointer(
        child: Center(
          child: GlassCard(
            radius: AppRadii.pill,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (effect.icon == 'crystal') ...<Widget>[
                  const Icon(
                    Icons.diamond_outlined,
                    size: 15,
                    color: AppColors.crystal,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    effect.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.text, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.3, end: 0);
  }
}

class _BannerOverlay extends StatelessWidget {
  const _BannerOverlay({required this.effect});

  final BannerEffect effect;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (effect.style) {
      'warning' => AppColors.warning,
      'danger' => AppColors.danger,
      'success' => AppColors.success,
      _ => AppColors.messenger,
    };
    return Positioned(
      top: 40,
      left: 14,
      right: 14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: AppRadii.card,
        ),
        child: Text(
          effect.text,
          style: TextStyle(color: color, fontSize: 13, height: 1.4),
        ),
      ),
    ).animate().fadeIn(duration: 220.ms);
  }
}

class _ImageOverlay extends StatelessWidget {
  const _ImageOverlay({required this.effect, required this.onClose});

  final ShowImageEffect effect;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withValues(alpha: 0.9),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: ClipRRect(
                  borderRadius: AppRadii.card,
                  child: Image.asset(
                    effect.asset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const EmptyState(
                      icon: Icons.image_not_supported_outlined,
                      title: 'Image unavailable',
                    ),
                  ),
                ),
              ),
            ),
            if (effect.caption != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 6, 28, 30),
                child: Text(
                  effect.caption!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textDim,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 280.ms);
  }
}

class _TitleCardOverlay extends StatelessWidget {
  const _TitleCardOverlay({required this.effect});

  final TitleCardEffect effect;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        color: AppColors.voidBlack.withValues(alpha: 0.94),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              effect.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 26,
                letterSpacing: 5,
                fontWeight: FontWeight.w300,
              ),
            ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.2, end: 0),
            if (effect.subtitle != null) ...<Widget>[
              const SizedBox(height: 14),
              Container(width: 40, height: 1, color: AppColors.ember),
              const SizedBox(height: 14),
              Text(
                effect.subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textDim,
                  fontSize: 13,
                  letterSpacing: 1.5,
                ),
              ).animate(delay: 350.ms).fadeIn(duration: 700.ms),
            ],
          ],
        ),
      ),
    );
  }
}

/// The "downloading → installing → done" animation for `@browser_download`.
class _InstallOverlay extends StatelessWidget {
  const _InstallOverlay({required this.effect});

  final AppInstallEffect effect;

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.forApp(effect.appId);
    return Positioned(
      left: 20,
      right: 20,
      bottom: 40,
      child: GlassCard(
        child: Row(
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: AppRadii.icon,
                gradient: LinearGradient(
                  colors: <Color>[
                    accent.withValues(alpha: 0.9),
                    accent.withValues(alpha: 0.4),
                  ],
                ),
              ),
              child: Icon(
                AppIconTile.iconFor(effect.appId),
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    effect.name,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Installing…',
                    style: TextStyle(
                      color: AppColors.textFaint,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 9),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: effect.duration,
                    builder: (BuildContext context, double value, _) =>
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 4,
                            color: accent,
                            backgroundColor: AppColors.outline,
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.6, end: 0, duration: 340.ms).fadeIn();
  }
}

class _AchievementToast extends StatelessWidget {
  const _AchievementToast({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: GlassCard(
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: AppColors.crystalGradient),
              ),
              child: const Icon(
                Icons.military_tech_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'ACHIEVEMENT UNLOCKED',
                    style: TextStyle(
                      color: AppColors.crystal,
                      fontSize: 9,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    achievement.title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: -0.5, end: 0, duration: 380.ms).fadeIn();
  }
}

/// Full-screen incoming-call UI driven by `@call_incoming`.
class IncomingCallOverlay extends ConsumerWidget {
  const IncomingCallOverlay({super.key, required this.call});

  final PhoneCall call;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameSessionController session = ref.read(
      gameSessionProvider.notifier,
    );
    final CharacterState? character = ref.watch(
      characterProvider(call.characterId),
    );
    final bool ringing = call.state == CallState.incoming;

    return Container(
      color: AppColors.voidBlack.withValues(alpha: 0.97),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            const Spacer(flex: 2),
            CharacterAvatar(
                  id: call.characterId,
                  name: character?.name,
                  image: character?.avatar,
                  size: 106,
                )
                .animate(
                  onPlay: (AnimationController c) => c.repeat(reverse: true),
                )
                .scaleXY(begin: 1, end: 1.04, duration: 900.ms),
            const SizedBox(height: 22),
            Text(
              character?.name ?? call.characterId,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 26,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ringing ? 'Incoming call…' : 'On call',
              style: const TextStyle(color: AppColors.textFaint, fontSize: 13),
            ),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 46),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _CallButton(
                    color: AppColors.danger,
                    icon: Icons.call_end_rounded,
                    label: 'Decline',
                    onTap: () => session.emitUiEvent(
                      'call_declined',
                      data: <String, Object?>{'character': call.characterId},
                    ),
                  ),
                  if (ringing)
                    _CallButton(
                      color: AppColors.success,
                      icon: Icons.call_rounded,
                      label: 'Answer',
                      onTap: () => session.emitUiEvent(
                        'call_answered',
                        data: <String, Object?>{'character': call.characterId},
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        InkResponse(
          onTap: onTap,
          radius: 44,
          child: Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 27),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(color: AppColors.textDim, fontSize: 12),
        ),
      ],
    );
  }
}
