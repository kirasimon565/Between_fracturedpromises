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
              ?.whereType<Map<String, dynamic>>()
              .map((e) => Message.fromJson(e))
              .toList() ??
          const [],

      choices: (json['choices'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .map((e) => Choice.fromJson(e))
          .toList(),

      // ✅ supports both camelCase and snake_case
      defaultNextScene: json['defaultNextScene']?.toString() ??
          json['default_next_scene']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messages': messages.map((e) => e.toJson()).toList(),
      if (choices != null)
        'choices': choices!.map((e) => e.toJson()).toList(),
      if (defaultNextScene != null)
        'default_next_scene': defaultNextScene,
    };
  }
}
