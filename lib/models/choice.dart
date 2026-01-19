import 'package:json_annotation/json_annotation.dart';

part 'choice.g.dart';

@JsonSerializable()
class Choice {
  final String text;

  @JsonKey(name: 'target_node')
  final String targetNode;

  final Map<String, dynamic>? impact; // e.g. {'romance': 1, 'suspicion': 5}

  Choice({
    required this.text,
    required this.targetNode,
    this.impact,
  });

  factory Choice.fromJson(Map<String, dynamic> json) => _$ChoiceFromJson(json);
  Map<String, dynamic> toJson() => _$ChoiceToJson(this);
}
