import 'package:json_annotation/json_annotation.dart';

part 'choice.g.dart';

@JsonSerializable()
class Choice {
  final String id;
  final String text;
  final String nextSceneId;
  final Map<String, dynamic>? impact; // e.g. {'romance': 1, 'suspicion': 5}

  Choice({
    required this.id,
    required this.text,
    required this.nextSceneId,
    this.impact,
  });

  factory Choice.fromJson(Map<String, dynamic> json) => _$ChoiceFromJson(json);
  Map<String, dynamic> toJson() => _$ChoiceToJson(this);
}
