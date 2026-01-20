import 'message.dart';
import 'choice.dart';

class Scene {
  final String id;
  final List<Message> messages;
  final List<Choice>? choices;
  final String? defaultNextScene;

  Scene({
    required this.id,
    required this.messages,
    this.choices,
    this.defaultNextScene,
  });

  factory Scene.fromJson(Map<String, dynamic> json) {
    return Scene(
      id: json['id']?.toString() ?? '',
      messages: (json['messages'] as List?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      choices: (json['choices'] as List?)
          ?.map((e) => Choice.fromJson(e as Map<String, dynamic>))
          .toList(),
      defaultNextScene: json['defaultNextScene']?.toString() ?? json['default_next_scene']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'messages': messages.map((e) => e.toJson()).toList(),
    'choices': choices?.map((e) => e.toJson()).toList(),
    'defaultNextScene': defaultNextScene,
  };
}
