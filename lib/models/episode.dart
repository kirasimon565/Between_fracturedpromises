import 'package:json_annotation/json_annotation.dart';
import 'scene.dart';

part 'episode.g.dart';

@JsonSerializable()
class Episode {
  final String id;
  final String title;
  final List<Scene> scenes;

  Episode({required this.id, required this.title, required this.scenes});

  factory Episode.fromJson(Map<String, dynamic> json) => _$EpisodeFromJson(json);
  Map<String, dynamic> toJson() => _$EpisodeToJson(this);
}
