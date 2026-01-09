import '../models/message.dart';

class ChatThread {
  final String id; // usually sender name for now
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

  DateTime get lastUpdated => DateTime.now(); // Placeholder for sorting
}
