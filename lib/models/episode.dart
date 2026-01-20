import 'scene.dart';

class Episode {
  final String id;
  final String title;
  final List<Scene> scenes;

  Episode({required this.id, required this.title, required this.scenes});

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Episode',
      scenes: (json['scenes'] as List?)
              ?.map((e) => Scene.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'scenes': scenes.map((e) => e.toJson()).toList(),
  };
}
