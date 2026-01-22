import 'package:isar/isar.dart';

part 'script_models.g.dart';

@collection
class ScriptMessage {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String scriptId; // episodeId_threadId_msgId

  @Index()
  late String threadId;

  late String sceneId;
  late int orderIndex;

  late String sender;
  late String content;
  late String type; // text, image, choice

  late int delay; // milliseconds

  // Embedded choices (Isar doesn't support List<Object> directly well without Embedded)
  // We'll store choices as a JSON string for simplicity or use a separate collection if complex query needed.
  // For script, JSON string is fine as we just read it to display.
  String? choicesJson;

  String? metadataJson;
}

@collection
class ThreadMeta {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String threadId;

  late String app; // messenger, makelove
  late String characterId;

  String? unlockRuleJson; // optional: unlocked at node X
}
