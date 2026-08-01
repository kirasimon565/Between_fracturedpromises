import '../engine_defaults.dart';
import '../events/engine_event.dart';
import '../runtime/engine_effect.dart';
import '../state/chat.dart';
import 'command.dart';
import 'command_helpers.dart';

/// `@message`, `@typing`, `@narration`, `@thought`, `@delay`, …
///
/// This family is what turns a text file into a conversation.
List<CommandHandler> messagingCommands() => <CommandHandler>[
      FunctionCommand(const <String>['message', 'msg', 'say'], _message),
      FunctionCommand(const <String>['typing'], _typing),
      FunctionCommand(
          const <String>['narration', 'narrate', 'narrator'], _narration),
      FunctionCommand(const <String>['thought', 'think'], _thought),
      FunctionCommand(const <String>['system'], _system),
      FunctionCommand(const <String>['delay', 'wait', 'pause_for'], _delay),
      FunctionCommand(const <String>['seen'], _seen),
      FunctionCommand(const <String>['reaction'], _reaction),
      FunctionCommand(const <String>['unsend'], _unsend),
      FunctionCommand(const <String>['clear_chat'], _clearChat),
      FunctionCommand(const <String>['thread'], _thread),
      FunctionCommand(const <String>['character'], _character),
    ];

CommandOutcome _message(CommandContext ctx) {
  // `@message ethan "text"` or `@message "text"` (narrator).
  String sender;
  String body;
  if (ctx.count >= 2) {
    sender = ctx.id(0);
    body = ctx.str(1);
  } else {
    sender = EngineDefaults.systemCharacterId;
    body = ctx.str(0);
  }
  if (body.isEmpty) return CommandOutcome.next;

  final bool fromPlayer = ctx.isPlayer(sender);
  final bool systemish = sender == EngineDefaults.systemCharacterId ||
      sender == EngineDefaults.narratorCharacterId;

  final String threadId = ctx.resolveThreadId(sender);
  final String app = ctx.currentApp;
  ctx.openThread(threadId, app: app);

  if (!fromPlayer && !systemish) {
    ctx.engine.state.activeThreadId = threadId;
    ctx.engine.state.ensureCharacter(sender);
  }

  final MessageKind kind = systemish
      ? (sender == EngineDefaults.narratorCharacterId
          ? MessageKind.narration
          : MessageKind.system)
      : MessageKind.message;

  final String? attachment =
      ctx.namedStrOrNull('image') ?? ctx.namedStrOrNull('attachment');

  final ChatMessage message = ChatMessage(
    id: ctx.uid('m'),
    threadId: threadId,
    senderId: sender,
    text: body,
    timestamp: ctx.engine.clock.now(),
    kind: kind,
    isPlayer: fromPlayer,
    status: fromPlayer ? MessageStatus.sent : MessageStatus.delivered,
    attachment: attachment,
    attachmentType: attachment == null
        ? null
        : (ctx.namedStrOrNull('audio') != null ? 'audio' : 'image'),
    replyToId: ctx.namedStrOrNull('reply'),
    style: ctx.namedStrOrNull('style'),
    clock: ctx.engine.state.phone.clock,
  );

  ctx.engine.state.appendMessage(message);
  ctx.engine.emitEvent(EngineEvents.messageSent, data: <String, Object?>{
    'thread': threadId,
    'sender': sender,
    'player': fromPlayer,
  });

  if (!systemish) {
    ctx.engine.emitEffect(PlaySoundEffect(
      fromPlayer ? 'msg_send' : 'msg_ping',
      volume: 0.7,
    ));
  }

  final Duration pause = ctx.has('delay')
      ? ctx.namedDuration('delay', Duration.zero)
      : ctx.readingTime(body);
  return CommandOutcome.wait(pause);
}

CommandOutcome _typing(CommandContext ctx) {
  final String sender = ctx.id(0);
  if (sender.isEmpty) return CommandOutcome.next;

  final num seconds = ctx.count > 1
      ? ctx.number(1, 1.5)
      : ctx.namedNum('seconds', 1.5);
  Duration duration = Duration(milliseconds: (seconds * 1000).round());
  if (duration > EngineDefaults.maxTypingDuration) {
    duration = EngineDefaults.maxTypingDuration;
  }
  duration = ctx.engine.settings.scaleTyping(duration);

  final String threadId = ctx.resolveThreadId(sender);
  ctx.openThread(threadId);
  ctx.engine.state.ensureCharacter(sender);

  if (!ctx.isPlayer(sender)) {
    ctx.engine.state.activeThreadId = threadId;
  }
  ctx.engine.state.setTyping(threadId, sender);
  ctx.engine.emitEffect(const PlaySoundEffect('typing', volume: 0.35));

  // Clear the bubble even if no message follows.
  ctx.engine.scheduler.after(
    duration,
    () => ctx.engine.state.setTyping(threadId, null),
    tag: 'typing',
  );

  return CommandOutcome.wait(duration);
}

CommandOutcome _narration(CommandContext ctx) =>
    _pushSpecial(ctx, MessageKind.narration,
        senderOverride: EngineDefaults.narratorCharacterId);

CommandOutcome _thought(CommandContext ctx) =>
    _pushSpecial(ctx, MessageKind.thought);

CommandOutcome _system(CommandContext ctx) => _pushSpecial(
      ctx,
      MessageKind.system,
      senderOverride: EngineDefaults.systemCharacterId,
    );

CommandOutcome _pushSpecial(
  CommandContext ctx,
  MessageKind kind, {
  String? senderOverride,
}) {
  String sender = senderOverride ?? '';
  String body;
  if (ctx.count >= 2) {
    sender = senderOverride ?? ctx.id(0);
    body = ctx.str(1);
  } else {
    body = ctx.str(0);
    if (sender.isEmpty) sender = ctx.playerId;
  }
  if (body.isEmpty) return CommandOutcome.next;

  final String threadId = ctx.resolveThreadId(sender);
  ctx.openThread(threadId);

  ctx.engine.state.appendMessage(ChatMessage(
    id: ctx.uid('x'),
    threadId: threadId,
    senderId: sender,
    text: body,
    timestamp: ctx.engine.clock.now(),
    kind: kind,
    isPlayer: kind == MessageKind.thought,
    style: ctx.namedStrOrNull('style'),
    clock: ctx.engine.state.phone.clock,
  ));

  final Duration pause = ctx.has('delay')
      ? ctx.namedDuration('delay', Duration.zero)
      : ctx.readingTime(body);
  return CommandOutcome.wait(pause);
}

CommandOutcome _delay(CommandContext ctx) {
  final num seconds = ctx.count > 0
      ? ctx.number(0, 1)
      : ctx.namedNum('seconds', ctx.namedNum('ms', 1000) / 1000);
  final Duration duration =
      ctx.engine.pace(Duration(milliseconds: (seconds * 1000).round()));
  return CommandOutcome.wait(duration);
}

CommandOutcome _seen(CommandContext ctx) {
  final String threadId = ctx.count > 0
      ? ctx.id(0)
      : (ctx.engine.state.activeThreadId ?? '');
  if (threadId.isEmpty) return CommandOutcome.next;
  ctx.engine.state.updateThread(threadId, (ChatThread thread) {
    return thread.copyWith(
      messages: thread.messages
          .map((ChatMessage m) =>
              m.isPlayer ? m.copyWith(status: MessageStatus.seen) : m)
          .toList(),
    );
  });
  return CommandOutcome.next;
}

CommandOutcome _reaction(CommandContext ctx) {
  final String emoji = ctx.str(0, '❤️');
  final String threadId = ctx.namedStr('thread',
      ctx.engine.state.activeThreadId ?? '');
  if (threadId.isEmpty) return CommandOutcome.next;
  ctx.engine.state.updateThread(threadId, (ChatThread thread) {
    if (thread.messages.isEmpty) return thread;
    final List<ChatMessage> messages = List<ChatMessage>.of(thread.messages);
    final ChatMessage last = messages.removeLast();
    messages.add(last.copyWith(reactions: <String>[...last.reactions, emoji]));
    return thread.copyWith(messages: messages);
  });
  return CommandOutcome.next;
}

CommandOutcome _unsend(CommandContext ctx) {
  final String threadId = ctx.namedStr('thread',
      ctx.engine.state.activeThreadId ?? '');
  if (threadId.isEmpty) return CommandOutcome.next;
  ctx.engine.state.updateThread(threadId, (ChatThread thread) {
    if (thread.messages.isEmpty) return thread;
    final List<ChatMessage> messages = List<ChatMessage>.of(thread.messages)
      ..removeLast();
    return thread.copyWith(messages: messages);
  });
  return CommandOutcome.next;
}

CommandOutcome _clearChat(CommandContext ctx) {
  final String threadId =
      ctx.count > 0 ? ctx.id(0) : (ctx.engine.state.activeThreadId ?? '');
  if (threadId.isEmpty) return CommandOutcome.next;
  ctx.engine.state.updateThread(
    threadId,
    (ChatThread thread) =>
        thread.copyWith(messages: const <ChatMessage>[], unread: 0),
  );
  return CommandOutcome.next;
}

CommandOutcome _thread(CommandContext ctx) {
  final String id = ctx.id(0);
  if (id.isEmpty) return CommandOutcome.next;
  final String app = ctx.namedStr('app', ctx.currentApp);
  ctx.engine.state.ensureThread(
    id,
    app: app,
    title: ctx.namedStrOrNull('title'),
    avatar: ctx.namedStrOrNull('avatar'),
    participants: <String>{id, ctx.playerId}.toList(),
  );
  ctx.engine.state.updateThread(
      id,
      (ChatThread thread) => thread.copyWith(
            pinned: ctx.namedBool('pinned', thread.pinned),
            muted: ctx.namedBool('muted', thread.muted),
            title: ctx.namedStrOrNull('title') ?? thread.title,
          ));
  ctx.engine.state.activeThreadId = id;
  return CommandOutcome.next;
}

CommandOutcome _character(CommandContext ctx) {
  final String id = ctx.id(0);
  if (id.isEmpty) return CommandOutcome.next;
  ctx.engine.state.ensureCharacter(id, name: ctx.namedStrOrNull('name'));
  ctx.engine.state.updateCharacter(
    id,
    (CharacterState character) => character.copyWith(
      name: ctx.namedStrOrNull('name'),
      status: ctx.namedStrOrNull('status') ??
          (ctx.count > 1 ? ctx.str(1) : null),
      avatar: ctx.namedStrOrNull('avatar'),
      about: ctx.namedStrOrNull('about'),
      phone: ctx.namedStrOrNull('phone'),
      lastSeen: ctx.engine.clock.now(),
    ),
  );
  return CommandOutcome.next;
}
