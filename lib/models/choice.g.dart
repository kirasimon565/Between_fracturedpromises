// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'choice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Choice _$ChoiceFromJson(Map<String, dynamic> json) => Choice(
      text: json['text'] as String,
      targetNode: json['target_node'] as String,
      impact: json['impact'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ChoiceToJson(Choice instance) => <String, dynamic>{
      'text': instance.text,
      'target_node': instance.targetNode,
      'impact': instance.impact,
    };
