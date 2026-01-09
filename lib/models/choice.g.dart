// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'choice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Choice _$ChoiceFromJson(Map<String, dynamic> json) => Choice(
      id: json['id'] as String,
      text: json['text'] as String,
      nextSceneId: json['nextSceneId'] as String,
      impact: json['impact'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ChoiceToJson(Choice instance) => <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'nextSceneId': instance.nextSceneId,
      'impact': instance.impact,
    };
