import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/engine_providers.dart';
import '../../core/providers/world_providers.dart';
import '../../engine/engine.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/common.dart';
import '../phone/widgets/phone_chrome.dart';
import 'widgets/choice_panel.dart';
import 'widgets/message_bubble.dart';

/// A whole conversation: header, scrolling transcript, typing indicator and
/// the choice panel.
///
/// Messenger and Makelove are the same widget with a different accent colour —
/// which app a thread belongs to is decided by the script, not by Dart.
class ConversationView extends ConsumerStatefulWidget {
  const ConversationView({
    super.key,
    required this.threadId,
    required this.accent,
    this.onBack,
    this.onOpenStore,
  });

  final String threadId;
  final Color accent;
  final VoidCallback? onBack;
  final void Function(int requiredCrystals)? onOpenStore;

  @override
  ConsumerState<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends ConsumerState<ConversationView> {
  final ScrollController _scroll = ScrollController();
  int _lastCount = 0;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd({bool animate = true}) {
    if (!_scroll.hasClients) return;
    final double target = _scroll.position.maxScrollExtent + 220;
    if (animate) {
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scroll.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ChatThread? thread = ref.watch(threadProvider(widget.threadId));
    final GameSession session = ref.watch(gameSessionProvider);
    final Map<String, CharacterState> characters = ref.watch(
      charactersProvider,
    );

    if (thread == null) {
      return const Center(
        child: EmptyState(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'No conversation yet',
          message: 'Messages will appear here as the night goes on.',
        ),
      );
    }

    final List<ChatMessage> messages = thread.messages;
    if (messages.length != _lastCount) {
      _lastCount = messages.length;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }

    final CharacterState? partner =
        characters[thread.participants.firstWhere(
          (String id) => characters[id] != null && id != 'nadia',
          orElse: () => thread.id,
        )];

    final bool showChoice =
        session.waitingForChoice &&
        (session.state?.activeThreadId == thread.id ||
            session.state?.activeThreadId == null);

    return Column(
      children: <Widget>[
        AppHeader(
          title: partner?.name ?? thread.title,
          subtitle: thread.typingBy != null
              ? 'typing…'
              : (partner?.isOnline == true
                    ? 'online'
                    : (partner?.status ?? 'offline')),
          accent: widget.accent,
          onBack: widget.onBack,
          leading: CharacterAvatar(
            id: partner?.id ?? thread.id,
            name: partner?.name ?? thread.title,
            image: partner?.avatar ?? thread.avatar,
            size: 36,
            online: partner?.isOnline ?? false,
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'Call',
              onPressed: () => ref
                  .read(gameSessionProvider.notifier)
                  .emitUiEvent(
                    'call_requested',
                    data: <String, Object?>{
                      'character': partner?.id ?? thread.id,
                    },
                  ),
              icon: const Icon(Icons.call_outlined, size: 19),
              color: AppColors.textDim,
            ),
          ],
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => ref.read(gameSessionProvider.notifier).skipWait(),
            behavior: HitTestBehavior.opaque,
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(6, 14, 6, 18),
              itemCount: messages.length + (thread.typingBy != null ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (index >= messages.length) {
                  final String typist = thread.typingBy!;
                  return TypingRow(
                    characterId: typist,
                    accent: widget.accent,
                    name: characters[typist]?.name,
                    avatar: characters[typist]?.avatar,
                  );
                }

                final ChatMessage message = messages[index];
                final ChatMessage? next = index + 1 < messages.length
                    ? messages[index + 1]
                    : null;
                final bool tail =
                    next == null ||
                    next.senderId != message.senderId ||
                    next.kind != message.kind;

                return MessageBubble(
                  message: message,
                  accent: widget.accent,
                  senderName: characters[message.senderId]?.name,
                  avatar: characters[message.senderId]?.avatar,
                  showTail: tail,
                );
              },
            ),
          ),
        ),
        if (showChoice)
          ChoicePanel(
            choice: session.choice!,
            accent: widget.accent,
            onNeedCrystals: widget.onOpenStore,
          )
        else
          _StatusFooter(status: session.status, accent: widget.accent),
      ],
    );
  }
}

/// Replaces the composer while the story is talking.
class _StatusFooter extends ConsumerWidget {
  const _StatusFooter({required this.status, required this.accent});

  final RuntimeStatus status;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String label = switch (status) {
      RuntimeStatus.waiting => 'waiting…',
      RuntimeStatus.running => '…',
      RuntimeStatus.awaitingSignal => 'waiting for you',
      RuntimeStatus.paused => 'paused',
      RuntimeStatus.finished => 'Episode complete',
      RuntimeStatus.error => 'Something went wrong',
      _ => '',
    };

    return Container(
      height: 54,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            const SizedBox(width: 20),
            if (status == RuntimeStatus.waiting ||
                status == RuntimeStatus.running)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.6,
                  color: accent.withValues(alpha: 0.7),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textFaint,
                  fontSize: 12.5,
                ),
              ),
            ),
            if (status == RuntimeStatus.waiting)
              TextButton(
                onPressed: () =>
                    ref.read(gameSessionProvider.notifier).skipWait(),
                child: const Text('Skip'),
              ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
