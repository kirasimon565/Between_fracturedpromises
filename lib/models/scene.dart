import 'package:json_annotation/json_annotation.dart';
import 'message.dart';

part 'scene.g.dart';

@JsonSerializable()
class Scene {
  final String id;
  final List<Message> messages;

  Scene({required this.id, required this.messages});

  factory Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);
  Map<String, dynamic> toJson() => _$SceneToJson(this);
}
