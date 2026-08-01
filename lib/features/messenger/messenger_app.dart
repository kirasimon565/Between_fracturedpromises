import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/engine_providers.dart';
import '../../core/providers/world_providers.dart';
import '../../engine/engine.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/common.dart';
import '../phone/widgets/phone_chrome.dart';
import 'conversation_view.dart';

/// Messenger — the app where the marriage lives.
///
/// Shows the thread list until a conversation is open; the script controls
/// which thread is active through `@message` / `@open_app thread`.
class MessengerApp extends ConsumerStatefulWidget {
  const MessengerApp({
    super.key,
    this.appId = 'messenger',
    this.title = 'Messenger',
    this.accent,
    this.onExit,
    this.onOpenStore,
  });

  final String appId;
  final String title;
  final Color? accent;
  final VoidCallback? onExit;
  final void Function(int requiredCrystals)? onOpenStore;

  @override
  ConsumerState<MessengerApp> createState() => _MessengerAppState();
}

class _MessengerAppState extends ConsumerState<MessengerApp> {
  String? _openThreadId;
  String? _lastAutoThread;

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.accent ?? AppColors.forApp(widget.appId);
    final List<ChatThread> threads =
        ref.watch(threadsForAppProvider(widget.appId));
    final ChatThread? active = ref.watch(activeThreadProvider);

    // Follow the story: when the script moves the conversation, follow it.
    if (active != null &&
        active.app == widget.appId &&
        active.id != _lastAutoThread) {
      _lastAutoThread = active.id;
      _openThreadId = active.id;
    }

    if (_openThreadId != null) {
      return ConversationView(
        threadId: _openThreadId!,
        accent: accent,
        onOpenStore: widget.onOpenStore,
        onBack: () => setState(() => _openThreadId = null),
      );
    }

    return Column(
      children: <Widget>[
        AppHeader(
          title: widget.title,
          subtitle: threads.isEmpty
              ? 'No conversations'
              : '${threads.length} conversation${threads.length == 1 ? '' : 's'}',
          accent: accent,
          onBack: widget.onExit,
        ),
        Expanded(
          child: threads.isEmpty
              ? const EmptyState(
                  icon: Icons.forum_outlined,
                  title: 'Quiet for once',
                  message: 'Nobody has messaged you yet tonight.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: threads.length,
                  separatorBuilder: (_, __) => const Divider(
                    indent: 76,
                    height: 1,
                    color: AppColors.outline,
                  ),
                  itemBuilder: (BuildContext context, int index) =>
                      _ThreadTile(
                    thread: threads[index],
                    accent: accent,
                    onTap: () {
                      ref
                          .read(gameSessionProvider.notifier)
                          .openThread(threads[index].id);
                      setState(() => _openThreadId = threads[index].id);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _ThreadTile extends ConsumerWidget {
  const _ThreadTile({
    required this.thread,
    required this.accent,
    required this.onTap,
  });

  final ChatThread thread;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CharacterState? character = ref.watch(characterProvider(thread.id));
    final ChatMessage? last = thread.lastMessage;
    final String preview = thread.typingBy != null
        ? 'typing…'
        : (last == null
            ? 'Say something.'
            : '${last.isPlayer ? 'You: ' : ''}${last.text}');

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      leading: CharacterAvatar(
        id: thread.id,
        name: character?.name ?? thread.title,
        image: character?.avatar ?? thread.avatar,
        size: 46,
        online: character?.isOnline ?? false,
      ),
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              character?.name ?? thread.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.text,
                fontWeight:
                    thread.unread > 0 ? FontWeight.w700 : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            last?.clock ?? '',
            style: const TextStyle(color: AppColors.textFaint, fontSize: 11),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                preview,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: thread.typingBy != null
                      ? accent
                      : (thread.unread > 0
                          ? AppColors.text
                          : AppColors.textFaint),
                  fontSize: 12.5,
                  fontStyle: thread.typingBy != null
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),
            if (thread.unread > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: AppRadii.pill,
                ),
                child: Text(
                  '${thread.unread}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
