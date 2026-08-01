import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/engine_providers.dart';
import '../../../core/providers/world_providers.dart';
import '../../../engine/engine.dart';
import '../../../shared/theme/app_theme.dart';

/// The reply picker.
///
/// Everything it renders — the options, their cost, whether they are locked,
/// and how long the player has — comes from the [PendingChoice] the runtime
/// published. There is no per-episode logic in here.
class ChoicePanel extends ConsumerStatefulWidget {
  const ChoicePanel({
    super.key,
    required this.choice,
    required this.accent,
    this.onNeedCrystals,
  });

  final PendingChoice choice;
  final Color accent;
  final void Function(int required)? onNeedCrystals;

  @override
  ConsumerState<ChoicePanel> createState() => _ChoicePanelState();
}

class _ChoicePanelState extends ConsumerState<ChoicePanel> {
  Timer? _ticker;
  Duration _remaining = Duration.zero;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant ChoicePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.choice != widget.choice) {
      _submitting = false;
      _startTimer();
    }
  }

  void _startTimer() {
    _ticker?.cancel();
    if (!widget.choice.isTimed) return;
    _remaining = widget.choice.remaining(DateTime.now());
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      setState(() => _remaining = widget.choice.remaining(DateTime.now()));
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _pick(ChoiceOptionView option) async {
    if (_submitting) return;
    if (option.isPremium && !option.alreadyOwned) {
      final Wallet wallet = ref.read(walletProvider);
      if (!wallet.canAfford(option.cost)) {
        widget.onNeedCrystals?.call(option.cost);
        return;
      }
    }
    if (!option.enabled) return;

    setState(() => _submitting = true);
    final bool accepted =
        await ref.read(gameSessionProvider.notifier).select(option.index);
    if (!accepted && mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final PendingChoice choice = widget.choice;
    final double progress = choice.isTimed && choice.timeout!.inMilliseconds > 0
        ? (_remaining.inMilliseconds / choice.timeout!.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
            top: BorderSide(color: widget.accent.withValues(alpha: 0.28))),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (choice.isTimed)
              LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                color: progress < 0.3 ? AppColors.danger : widget.accent,
                backgroundColor: AppColors.outline,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (choice.prompt != null && choice.prompt!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, left: 4),
                      child: Text(
                        choice.prompt!,
                        style: const TextStyle(
                          color: AppColors.textDim,
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  for (int i = 0; i < choice.options.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _OptionButton(
                        option: choice.options[i],
                        accent: widget.accent,
                        disabled: _submitting,
                        onTap: () => _pick(choice.options[i]),
                      )
                          .animate(delay: Duration(milliseconds: 60 * i))
                          .fadeIn(duration: 220.ms)
                          .slideY(begin: 0.25, end: 0),
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

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.option,
    required this.accent,
    required this.onTap,
    this.disabled = false,
  });

  final ChoiceOptionView option;
  final Color accent;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final bool premium = option.isPremium;
    final bool locked = !option.enabled && !premium;
    final Color border = premium
        ? AppColors.crystal.withValues(alpha: 0.55)
        : (locked
            ? AppColors.outline
            : accent.withValues(alpha: option.picked ? 0.25 : 0.45));

    final Color background = premium
        ? AppColors.crystal.withValues(alpha: 0.09)
        : AppColors.surfaceHigh;

    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Material(
        color: background,
        borderRadius: AppRadii.card,
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: AppRadii.card,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: AppRadii.card,
              border: Border.all(color: border),
            ),
            child: Row(
              children: <Widget>[
                if (premium) ...<Widget>[
                  const Icon(Icons.diamond_outlined,
                      size: 16, color: AppColors.crystal),
                  const SizedBox(width: 10),
                ] else if (locked) ...<Widget>[
                  const Icon(Icons.lock_outline_rounded,
                      size: 15, color: AppColors.textFaint),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        option.label,
                        style: TextStyle(
                          color: locked ? AppColors.textFaint : AppColors.text,
                          fontSize: 14.5,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (option.hint != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            option.hint!,
                            style: const TextStyle(
                              color: AppColors.textFaint,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (premium && !option.alreadyOwned) ...<Widget>[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.crystal.withValues(alpha: 0.16),
                      borderRadius: AppRadii.pill,
                    ),
                    child: Text(
                      '${option.cost}',
                      style: const TextStyle(
                        color: AppColors.crystal,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ] else if (premium && option.alreadyOwned)
                  const Icon(Icons.check_circle_outline_rounded,
                      size: 16, color: AppColors.success),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
