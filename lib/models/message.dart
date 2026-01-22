import 'choice.dart';

enum MessageType { text, image, choice }
enum Sender { nadia, ethan, claire, olivia, daniel, liam, system, other } // Added 'other' for generic sender mapping

class Message {
  final String id;
  final Sender sender;
  final String? recipient;
  final String content;
  final MessageType type;
  final int delay;
  final int orderIndex;
  final String? sceneId;
  final List<Choice>? choices;
  final Map<String, dynamic>? metadata;
  final DateTime? timestamp; // ✅ Added timestamp

  Message({
    required this.id,
    required this.sender,
    this.recipient,
    required this.content,
    this.type = MessageType.text,
    this.delay = 1000,
    this.orderIndex = 0,
    this.sceneId,
    this.choices,
    this.metadata,
    this.timestamp,
  });

  /// 🔐 Safe enum parser
  static T _parseEnum<T>(
    List<T> values,
    String? value,
    T fallback,
  ) {
    if (value == null) return fallback;
    return values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => fallback,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',

      sender: _parseEnum(
        Sender.values,
        json['sender']?.toString(),
        Sender.system,
      ),

      recipient: json['recipient']?.toString(),

      content: json['content']?.toString() ?? '',

      type: _parseEnum(
        MessageType.values,
        json['type']?.toString(),
        MessageType.text,
      ),

      delay: json['delay'] is int
          ? json['delay'] as int
          : int.tryParse(json['delay']?.toString() ?? '') ?? 1000,

      /// ✅ Supports BOTH naming styles
      orderIndex: json['orderIndex'] is int
          ? json['orderIndex'] as int
          : json['order_index'] is int
              ? json['order_index'] as int
              : 0,

      /// ✅ Supports BOTH naming styles
      sceneId: json['sceneId']?.toString() ??
          json['scene_id']?.toString(),

      choices: (json['choices'] as List?)
          ?.map((e) => Choice.fromJson(e as Map<String, dynamic>))
          .toList(),

      metadata: json['metadata'] as Map<String, dynamic>?,

      timestamp: json['timestamp'] != null
          ? (json['timestamp'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
              : DateTime.tryParse(json['timestamp'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.toString().split('.').last,
      'recipient': recipient,
      'content': content,
      'type': type.toString().split('.').last,
      'delay': delay,
      'orderIndex': orderIndex,
      'sceneId': sceneId,
      'choices': choices?.map((e) => e.toJson()).toList(),
      'metadata': metadata,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}
