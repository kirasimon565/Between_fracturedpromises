import 'package:isar/isar.dart';

part 'playback_models.g.dart';

@collection
class VisibleMessage {
  Id id = Isar.autoIncrement;

  @Index()
  late String threadId;

  late String saveSlotId; // for multi-save support

  @Index()
  late String origin; // script | choice | system

  late String sender;
  late String content;

  late String type; // text, image, choice

  late DateTime deliveredAt;

  // Link back to script
  String? scriptId;
  String? sceneId;

  // If it was a choice prompt, store choices here
  String? choicesJson;
}

@collection
class PendingDelivery {
  Id id = Isar.autoIncrement;

  @Index()
  late String threadId;

  late String saveSlotId;

  late String scriptId;

  late DateTime deliverAt;
  late DateTime typingStartAt;

  late String sender; // Needed for typing indicators
  late String content; // Needed for length calcs
  late String type;

  // Status not strictly needed if we just delete upon delivery,
  // but good for debugging.
  @Index()
  String status = 'pending'; // pending, typing
}

@collection
class ThreadPlaybackState {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String compositeId; // "$saveSlotId:$threadId"

  late String saveSlotId;
  late String threadId;

  late String currentSceneId;

  // Cursor: index of the next script message to schedule
  late int cursor;

  DateTime? lastReadAt;

  // Helper to construct composite ID
  static String getCompositeId(String slot, String thread) => "$slot:$thread";
}
