import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Frosted panel used for sheets, cards and overlays.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = AppRadii.card,
    this.color,
    this.border = true,
    this.blur = 18,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius radius;
  final Color? color;
  final bool border;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? AppColors.surface.withValues(alpha: 0.86),
            borderRadius: radius,
            border: border
                ? Border.all(color: AppColors.outline.withValues(alpha: 0.8))
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Circular character avatar with initials fallback.
class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({
    super.key,
    required this.id,
    this.name,
    this.image,
    this.size = 42,
    this.online = false,
    this.ring,
  });

  final String id;
  final String? name;
  final String? image;
  final double size;
  final bool online;
  final Color? ring;

  @override
  Widget build(BuildContext context) {
    final Color color = AppColors.forCharacter(id);
    final String label = (name ?? id).trim();
    final String initials = label.isEmpty
        ? '?'
        : label
              .split(RegExp(r'\s+'))
              .take(2)
              .map((String p) => p.isEmpty ? '' : p[0].toUpperCase())
              .join();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  color.withValues(alpha: 0.85),
                  color.withValues(alpha: 0.35),
                ],
              ),
              border: ring == null ? null : Border.all(color: ring!, width: 2),
              image: image == null
                  ? null
                  : DecorationImage(
                      image: AssetImage(image!),
                      fit: BoxFit.cover,
                      onError: (_, _) {},
                    ),
            ),
            alignment: Alignment.center,
            child: image != null
                ? null
                : Text(
                    initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: size * 0.36,
                    ),
                  ),
          ),
          if (online)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.night, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The crystal balance pill shown in headers and the store.
class CrystalChip extends StatelessWidget {
  const CrystalChip({
    super.key,
    required this.amount,
    this.onTap,
    this.compact = false,
  });

  final int amount;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.pill,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 5 : 8,
        ),
        decoration: BoxDecoration(
          borderRadius: AppRadii.pill,
          border: Border.all(color: AppColors.crystal.withValues(alpha: 0.35)),
          color: AppColors.crystal.withValues(alpha: 0.12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.diamond_outlined,
              size: 15,
              color: AppColors.crystal,
            ),
            const SizedBox(width: 6),
            Text(
              '$amount',
              style: TextStyle(
                color: AppColors.crystal,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 12 : 14,
              ),
            ),
            if (onTap != null && !compact) ...<Widget>[
              const SizedBox(width: 4),
              const Icon(Icons.add, size: 14, color: AppColors.crystal),
            ],
          ],
        ),
      ),
    );
  }
}

/// Three-dot "is typing" animation.
class TypingDots extends StatefulWidget {
  const TypingDots({super.key, this.color = AppColors.textDim, this.size = 7});

  final Color color;
  final double size;

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(3, (int i) {
            final double t = ((_controller.value * 3) - i).clamp(0.0, 1.0);
            final double lift = (t < 0.5 ? t : 1 - t) * 2;
            return Padding(
              padding: EdgeInsets.only(right: i == 2 ? 0 : 4),
              child: Transform.translate(
                offset: Offset(0, -lift * 3),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.45 + lift * 0.45),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Empty-state placeholder used across the phone apps.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 42),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 44, color: AppColors.textFaint),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textDim,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (message != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textFaint, height: 1.5),
              ),
            ],
            if (action != null) ...<Widget>[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-bleed moody background used by every non-phone screen.
class NightBackdrop extends StatelessWidget {
  const NightBackdrop({super.key, required this.child, this.image});

  final Widget child;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.nightGradient,
        ),
        image: image == null
            ? null
            : DecorationImage(
                image: AssetImage(image!),
                fit: BoxFit.cover,
                opacity: 0.22,
                onError: (_, _) {},
              ),
      ),
      child: child,
    );
  }
}

/// Section header used inside settings / store / gallery.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textFaint,
                fontSize: 11,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
