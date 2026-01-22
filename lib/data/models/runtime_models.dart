import 'package:isar/isar.dart';

part 'runtime_models.g.dart';

@collection
class RuntimeState {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String saveSlotId; // e.g. "slot_1"

  late String currentEpisodeId;
  late String currentSceneId;

  late String variablesJson; // Map<String, dynamic>

  late List<String> unlockedThreads;
  late List<String> completedNodes;

  late String scriptVersion;

  // ---------------------------------------------------------------------------
  // 👤 User Profile (Migrated from SharedPreferences)
  // ---------------------------------------------------------------------------
  String userName = "Nadia";
  String userBio = "Just looking for a spark...";

  // ---------------------------------------------------------------------------
  // 🖼️ Gallery & Collectibles
  // ---------------------------------------------------------------------------
  List<String> unlockedGallery = const [];

  // ---------------------------------------------------------------------------
  // ⚙️ System Settings
  // ---------------------------------------------------------------------------
  bool isSfxEnabled = true;
  bool isMusicEnabled = true;
  bool isNotificationsEnabled = true;

  // ---------------------------------------------------------------------------
  // 🏆 Endgame History (List of ending IDs achieved)
  // ---------------------------------------------------------------------------
  List<String> endingHistory = const [];
}

@collection
class ChoiceRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late String saveSlotId;

  @Index()
  late String nodeId;

  late String threadId;
  late String choiceText;
  late DateTime timestamp;
}
