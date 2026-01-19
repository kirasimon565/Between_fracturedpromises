import 'package:json_annotation/json_annotation.dart';
import 'choice.dart';

part 'message.g.dart';

enum MessageType { text, image, choice }
enum Sender { nadia, ethan, claire, olivia, daniel, liam, system }

@JsonSerializable(explicitToJson: true)
class Message {
  final String id;
  final Sender sender;
  final String? recipient; 
  final String content;
  final MessageType type;
  final int delay; 

  @JsonKey(name: 'order_index')
  final int orderIndex;

  @JsonKey(name: 'scene_id')
  final String? sceneId;

  final List<Choice>? choices;

  // 🛠️ ADDED: For tracking secrets and image URLs
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
    this.metadata, // 🛠️ ADDED
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
