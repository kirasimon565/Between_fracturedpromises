import 'package:json_annotation/json_annotation.dart';
import 'message.dart';
import 'choice.dart';

part 'scene.g.dart';

@JsonSerializable()
class Scene {
  final String id;
  final List<Message> messages;
  final List<Choice>? choices;
  final String? defaultNextScene; // If no choices, go here. If null and no choices, end episode.

  Scene({
    required this.id,
    required this.messages,
    this.choices,
    this.defaultNextScene,
  });

  factory Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);
  Map<String, dynamic> toJson() => _$SceneToJson(this);
}
