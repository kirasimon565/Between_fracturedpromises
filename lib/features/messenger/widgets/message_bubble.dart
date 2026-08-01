import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../engine/engine.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/common.dart';

/// One line of the conversation.
///
/// The bubble shape is chosen from [ChatMessage.kind], so `@narration`,
/// `@thought` and `@system` render differently without the script having to
/// describe any styling.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.accent,
    this.senderName,
    this.avatar,
    this.showAvatar = true,
    this.showTail = true,
    this.onTapAttachment,
  });

  final ChatMessage message;
  final Color accent;
  final String? senderName;
  final String? avatar;
  final bool showAvatar;
  final bool showTail;
  final void Function(String asset)? onTapAttachment;

  @override
  Widget build(BuildContext context) {
    switch (message.kind) {
      case MessageKind.narration:
        return _Narration(text: message.text);
      case MessageKind.thought:
        return _Thought(text: message.text);
      case MessageKind.system:
        return _SystemLine(text: message.text);
      case MessageKind.call:
        return _CallLine(text: message.text);
      case MessageKind.message:
      case MessageKind.attachment:
        return _Bubble(
          message: message,
          accent: accent,
          senderName: senderName,
          avatar: avatar,
          showAvatar: showAvatar,
          showTail: showTail,
          onTapAttachment: onTapAttachment,
        );
    }
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.accent,
    required this.showAvatar,
    required this.showTail,
    this.senderName,
    this.avatar,
    this.onTapAttachment,
  });

  final ChatMessage message;
  final Color accent;
  final bool showAvatar;
  final bool showTail;
  final String? senderName;
  final String? avatar;
  final void Function(String asset)? onTapAttachment;

  @override
  Widget build(BuildContext context) {
    final bool mine = message.isPlayer;
    final Color bubbleColor = mine
        ? accent.withValues(alpha: 0.9)
        : AppColors.surfaceHigh;
    final Color textColor = mine ? Colors.white : AppColors.text;

    final Radius corner = const Radius.circular(20);
    final Radius pinched = const Radius.circular(6);

    return Padding(
      padding: EdgeInsets.only(
        left: mine ? 56 : 8,
        right: mine ? 8 : 56,
        top: 2,
        bottom: showTail ? 8 : 2,
      ),
      child: Row(
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (!mine)
            SizedBox(
              width: 34,
              child: showAvatar && showTail
                  ? CharacterAvatar(
                      id: message.senderId,
                      name: senderName,
                      image: avatar,
                      size: 30,
                    )
                  : null,
            ),
          if (!mine) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: message.attachment != null
                      ? const EdgeInsets.all(5)
                      : const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: corner,
                      topRight: corner,
                      bottomLeft: mine || !showTail ? corner : pinched,
                      bottomRight: mine && showTail ? pinched : corner,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (message.attachment != null)
                        _Attachment(
                          asset: message.attachment!,
                          type: message.attachmentType,
                          onTap: onTapAttachment,
                        ),
                      if (message.text.isNotEmpty)
                        Padding(
                          padding: message.attachment != null
                              ? const EdgeInsets.fromLTRB(10, 8, 10, 4)
                              : EdgeInsets.zero,
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14.5,
                              height: 1.4,
                              fontStyle: message.style == 'whisper'
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (message.reactions.isNotEmpty)
                  Transform.translate(
                    offset: const Offset(0, -6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadii.pill,
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Text(message.reactions.join(' '),
                          style: const TextStyle(fontSize: 11)),
                    ),
                  ),
                if (showTail)
                  Padding(
                    padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          message.clock ?? '',
                          style: const TextStyle(
                              color: AppColors.textFaint, fontSize: 10),
                        ),
                        if (mine) ...<Widget>[
                          const SizedBox(width: 4),
                          Icon(
                            message.status == MessageStatus.seen
                                ? Icons.done_all_rounded
                                : Icons.done_rounded,
                            size: 12,
                            color: message.status == MessageStatus.seen
                                ? accent
                                : AppColors.textFaint,
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.15, end: 0, duration: 220.ms);
  }
}

class _Attachment extends StatelessWidget {
  const _Attachment({required this.asset, this.type, this.onTap});

  final String asset;
  final String? type;
  final void Function(String asset)? onTap;

  @override
  Widget build(BuildContext context) {
    if (type == 'audio') {
      return Container(
        width: 190,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: <Widget>[
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('0:14',
                style: TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(asset),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset(
          asset,
          width: 210,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 210,
            height: 130,
            color: AppColors.outline,
            alignment: Alignment.center,
            child: const Icon(Icons.image_outlined,
                color: AppColors.textFaint, size: 26),
          ),
        ),
      ),
    );
  }
}

class _Narration extends StatelessWidget {
  const _Narration({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 12, 30, 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textDim,
          fontSize: 13.5,
          height: 1.65,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.2,
        ),
      ),
    ).animate().fadeIn(duration: 520.ms);
  }
}

class _Thought extends StatelessWidget {
  const _Thought({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 8, 26, 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.ember.withValues(alpha: 0.06),
          borderRadius: AppRadii.card,
          border: Border(
            left: BorderSide(
                color: AppColors.ember.withValues(alpha: 0.55), width: 2),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.ember.withValues(alpha: 0.92),
            fontSize: 13.5,
            height: 1.55,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 480.ms).slideX(begin: -0.05, end: 0);
  }
}

class _SystemLine extends StatelessWidget {
  const _SystemLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final bool divider = text.trim().isNotEmpty &&
        RegExp(r'^[═─—=_\s]+$').hasMatch(text.trim());

    if (divider) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        child: Divider(color: AppColors.outline),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 7),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textFaint,
          fontSize: 12,
          height: 1.6,
          letterSpacing: 0.4,
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _CallLine extends StatelessWidget {
  const _CallLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.call_rounded, size: 13, color: AppColors.textFaint),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textFaint, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Ethan is typing…" row.
class TypingRow extends StatelessWidget {
  const TypingRow({
    super.key,
    required this.characterId,
    required this.accent,
    this.name,
    this.avatar,
  });

  final String characterId;
  final Color accent;
  final String? name;
  final String? avatar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 56, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          CharacterAvatar(
            id: characterId,
            name: name,
            image: avatar,
            size: 30,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(6),
              ),
            ),
            child: TypingDots(color: accent),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
