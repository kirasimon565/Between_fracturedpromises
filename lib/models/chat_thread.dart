import 'package:cloud_firestore/cloud_firestore.dart';
import 'message.dart';

class ChatThread {
  final String id;
  final List<Message> messages;
  final bool isUnread;

  /// Optional metadata (not required everywhere)
  final String? app; // 'messenger' | 'makelove'
  final DateTime? lastUpdated;

  ChatThread({
    required this.id,
    required this.messages,
    this.isUnread = false,
    this.app,
    this.lastUpdated,
  });

  /// Safe last message accessor
  Message? get lastMessage =>
      messages.isNotEmpty ? messages.last : null;

  /// Deserialize from Firestore thread doc + embedded messages (optional)
  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      id: json['id']?.toString() ?? 'unknown',

      isUnread: json['isUnread'] as bool? ?? false,

      app: json['app']?.toString(),

      lastUpdated: json['last_updated'] is Timestamp
          ? (json['last_updated'] as Timestamp).toDate()
          : null,

      messages: (json['messages'] as List?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  /// Serialize (mostly useful for local caching / testing)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isUnread': isUnread,
      'app': app,
      'last_updated': lastUpdated,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}
