import 'choice.dart'; // 👈 ADD THIS IMPORT

enum MessageType { text, image, choice }
enum Sender { nadia, ethan, claire, olivia, daniel, liam, system }

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
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      // Safe Enum Parsing
      sender: Sender.values.firstWhere(
        (e) => e.toString().split('.').last == json['sender'],
        orElse: () => Sender.system,
      ),
      recipient: json['recipient']?.toString(),
      content: json['content']?.toString() ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MessageType.text,
      ),
      delay: json['delay'] as int? ?? 1000,
      orderIndex: json['order_index'] as int? ?? json['orderIndex'] as int? ?? 0,
      sceneId: json['scene_id']?.toString() ?? json['sceneId']?.toString(),
      choices: (json['choices'] as List?)
          ?.map((e) => Choice.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender': sender.toString().split('.').last,
    'content': content,
    'type': type.toString().split('.').last,
    'choices': choices?.map((e) => e.toJson()).toList(),
    'metadata': metadata,
  };
}
