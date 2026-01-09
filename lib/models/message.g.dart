// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['id'] as String,
      sender: $enumDecode(_$SenderEnumMap, json['sender']),
      recipient: json['recipient'] as String?,
      content: json['content'] as String,
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.text,
      delay: json['delay'] as int? ?? 1000,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'sender': _$SenderEnumMap[instance.sender]!,
      'recipient': instance.recipient,
      'content': instance.content,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'delay': instance.delay,
    };

const _$SenderEnumMap = {
  Sender.nadia: 'nadia',
  Sender.ethan: 'ethan',
  Sender.claire: 'claire',
  Sender.olivia: 'olivia',
  Sender.daniel: 'daniel',
  Sender.liam: 'liam',
  Sender.system: 'system',
};

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.choice: 'choice',
};
