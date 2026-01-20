import '../models/message.dart';

class ChatThread {
  final String id; 
  final List<Message> messages;
  final bool isUnread;

  ChatThread({
    required this.id,
    required this.messages,
    this.isUnread = false
  });

  Message get lastMessage => messages.isNotEmpty
      ? messages.last
      : Message(id: '0', sender: Sender.system, content: '', type: MessageType.text);

  DateTime get lastUpdated => DateTime.now(); 

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      id: json['id']?.toString() ?? 'Unknown',
      isUnread: json['isUnread'] as bool? ?? false,
      messages: (json['messages'] as List?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
    );
  }
}
