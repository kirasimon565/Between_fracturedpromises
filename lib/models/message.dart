import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

enum MessageType { text, image, choice }
enum Sender { nadia, ethan, claire, olivia, daniel, liam, system }

@JsonSerializable()
class Message {
  final String id;
  final Sender sender;
  final String? recipient; // Name of the intended recipient (e.g. 'ethan', 'daniel')
  final String content;
  final MessageType type;
  final int delay; // milliseconds before showing

  Message({
    required this.id,
    required this.sender,
    this.recipient,
    required this.content,
    this.type = MessageType.text,
    this.delay = 1000,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
