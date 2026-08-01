/// Chat model shared by every messaging surface (Messenger, Makelove, SMS).
library;

/// Where a message is rendered.
enum MessageKind { message, narration, thought, system, attachment, call }

/// Delivery state shown next to player messages.
enum MessageStatus { sending, sent, delivered, seen, failed }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.kind = MessageKind.message,
    this.status = MessageStatus.sent,
    this.isPlayer = false,
    this.attachment,
    this.attachmentType,
    this.reactions = const <String>[],
    this.replyToId,
    this.style,
    this.clock,
  });

  final String id;
  final String threadId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final MessageKind kind;
  final MessageStatus status;
  final bool isPlayer;

  /// Asset path or url of an image / audio attachment.
  final String? attachment;
  final String? attachmentType;
  final List<String> reactions;
  final String? replyToId;

  /// Optional presentation hint coming from the script (`style whisper`).
  final String? style;

  /// In-fiction clock label ("23:47") shown in the bubble.
  final String? clock;

  ChatMessage copyWith({
    MessageStatus? status,
    List<String>? reactions,
    String? text,
  }) {
    return ChatMessage(
      id: id,
      threadId: threadId,
      senderId: senderId,
      text: text ?? this.text,
      timestamp: timestamp,
      kind: kind,
      status: status ?? this.status,
      isPlayer: isPlayer,
      attachment: attachment,
      attachmentType: attachmentType,
      reactions: reactions ?? this.reactions,
      replyToId: replyToId,
      style: style,
      clock: clock,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'thread': threadId,
        'sender': senderId,
        'text': text,
        'ts': timestamp.millisecondsSinceEpoch,
        'kind': kind.name,
        'status': status.name,
        'player': isPlayer,
        if (attachment != null) 'att': attachment,
        if (attachmentType != null) 'attType': attachmentType,
        if (reactions.isNotEmpty) 'react': reactions,
        if (replyToId != null) 'reply': replyToId,
        if (style != null) 'style': style,
        if (clock != null) 'clock': clock,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        threadId: json['thread'] as String,
        senderId: json['sender'] as String,
        text: json['text'] as String? ?? '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(
            (json['ts'] as num?)?.toInt() ?? 0),
        kind: MessageKind.values.firstWhere(
          (MessageKind k) => k.name == json['kind'],
          orElse: () => MessageKind.message,
        ),
        status: MessageStatus.values.firstWhere(
          (MessageStatus s) => s.name == json['status'],
          orElse: () => MessageStatus.sent,
        ),
        isPlayer: json['player'] as bool? ?? false,
        attachment: json['att'] as String?,
        attachmentType: json['attType'] as String?,
        reactions: (json['react'] as List<dynamic>?)
                ?.map((dynamic e) => e.toString())
                .toList() ??
            const <String>[],
        replyToId: json['reply'] as String?,
        style: json['style'] as String?,
        clock: json['clock'] as String?,
      );
}

class ChatThread {
  const ChatThread({
    required this.id,
    required this.app,
    required this.title,
    this.participants = const <String>[],
    this.messages = const <ChatMessage>[],
    this.unread = 0,
    this.typingBy,
    this.pinned = false,
    this.muted = false,
    this.archived = false,
    this.avatar,
    this.lastActivity,
  });

  final String id;

  /// Owning application id (`messenger`, `makelove`, `sms`).
  final String app;
  final String title;
  final List<String> participants;
  final List<ChatMessage> messages;
  final int unread;

  /// Character id currently shown as "typing…", if any.
  final String? typingBy;
  final bool pinned;
  final bool muted;
  final bool archived;
  final String? avatar;
  final DateTime? lastActivity;

  ChatMessage? get lastMessage =>
      messages.isEmpty ? null : messages[messages.length - 1];

  ChatThread copyWith({
    String? title,
    List<String>? participants,
    List<ChatMessage>? messages,
    int? unread,
    Object? typingBy = _sentinel,
    bool? pinned,
    bool? muted,
    bool? archived,
    String? avatar,
    DateTime? lastActivity,
  }) {
    return ChatThread(
      id: id,
      app: app,
      title: title ?? this.title,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      unread: unread ?? this.unread,
      typingBy: identical(typingBy, _sentinel)
          ? this.typingBy
          : typingBy as String?,
      pinned: pinned ?? this.pinned,
      muted: muted ?? this.muted,
      archived: archived ?? this.archived,
      avatar: avatar ?? this.avatar,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  static const Object _sentinel = Object();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'app': app,
        'title': title,
        'participants': participants,
        'messages':
            messages.map((ChatMessage m) => m.toJson()).toList(growable: false),
        'unread': unread,
        if (typingBy != null) 'typing': typingBy,
        'pinned': pinned,
        'muted': muted,
        'archived': archived,
        if (avatar != null) 'avatar': avatar,
        if (lastActivity != null)
          'last': lastActivity!.millisecondsSinceEpoch,
      };

  factory ChatThread.fromJson(Map<String, dynamic> json) => ChatThread(
        id: json['id'] as String,
        app: json['app'] as String? ?? 'messenger',
        title: json['title'] as String? ?? '',
        participants: (json['participants'] as List<dynamic>?)
                ?.map((dynamic e) => e.toString())
                .toList() ??
            const <String>[],
        messages: (json['messages'] as List<dynamic>?)
                ?.map((dynamic e) =>
                    ChatMessage.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            const <ChatMessage>[],
        unread: (json['unread'] as num?)?.toInt() ?? 0,
        typingBy: json['typing'] as String?,
        pinned: json['pinned'] as bool? ?? false,
        muted: json['muted'] as bool? ?? false,
        archived: json['archived'] as bool? ?? false,
        avatar: json['avatar'] as String?,
        lastActivity: json['last'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                (json['last'] as num).toInt()),
      );
}

/// A character known to the story (also used for the Contacts app).
class CharacterState {
  const CharacterState({
    required this.id,
    required this.name,
    this.status = 'offline',
    this.avatar,
    this.about,
    this.phone,
    this.blocked = false,
    this.favorite = false,
    this.lastSeen,
  });

  final String id;
  final String name;

  /// `online`, `offline`, `typing`, `away`, `busy`, custom values allowed.
  final String status;
  final String? avatar;
  final String? about;
  final String? phone;
  final bool blocked;
  final bool favorite;
  final DateTime? lastSeen;

  bool get isOnline => status.toLowerCase() == 'online';

  CharacterState copyWith({
    String? name,
    String? status,
    String? avatar,
    String? about,
    String? phone,
    bool? blocked,
    bool? favorite,
    DateTime? lastSeen,
  }) {
    return CharacterState(
      id: id,
      name: name ?? this.name,
      status: status ?? this.status,
      avatar: avatar ?? this.avatar,
      about: about ?? this.about,
      phone: phone ?? this.phone,
      blocked: blocked ?? this.blocked,
      favorite: favorite ?? this.favorite,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'status': status,
        if (avatar != null) 'avatar': avatar,
        if (about != null) 'about': about,
        if (phone != null) 'phone': phone,
        'blocked': blocked,
        'favorite': favorite,
        if (lastSeen != null) 'seen': lastSeen!.millisecondsSinceEpoch,
      };

  factory CharacterState.fromJson(Map<String, dynamic> json) => CharacterState(
        id: json['id'] as String,
        name: json['name'] as String? ?? json['id'] as String,
        status: json['status'] as String? ?? 'offline',
        avatar: json['avatar'] as String?,
        about: json['about'] as String?,
        phone: json['phone'] as String?,
        blocked: json['blocked'] as bool? ?? false,
        favorite: json['favorite'] as bool? ?? false,
        lastSeen: json['seen'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                (json['seen'] as num).toInt()),
      );
}
