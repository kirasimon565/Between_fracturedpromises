import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'dart:io';

// 🛠️ ABSOLUTE IMPORTS for robustness
import 'package:between_fractured_promises/data/models/runtime_models.dart';
import 'package:between_fractured_promises/data/models/playback_models.dart';
import 'package:between_fractured_promises/data/models/script_models.dart';

// 🛠️ Export schemas for visibility in consumers
export 'package:between_fractured_promises/data/models/runtime_models.dart';
export 'package:between_fractured_promises/data/models/playback_models.dart';
export 'package:between_fractured_promises/data/models/script_models.dart';

class PlaybackStore extends GetxService {
  late Isar _isar;
  final String saveSlotId = "slot_1"; // Hardcoded for now, can be dynamic later

  Future<PlaybackStore> init() async {
    final dir = await getApplicationDocumentsDirectory();

    // Ensure directory exists
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    _isar = await Isar.open(
      [
        ScriptMessageSchema,
        ThreadMetaSchema,
        RuntimeStateSchema,
        ChoiceRecordSchema,
        VisibleMessageSchema,
        PendingDeliverySchema,
        ThreadPlaybackStateSchema,
      ],
      directory: dir.path,
    );

    await _ensureRuntimeState();
    return this;
  }

  Isar get isar => _isar;

  // ---------------------------------------------------------------------------
  // Runtime State
  // ---------------------------------------------------------------------------

  Future<void> _ensureRuntimeState() async {
    final existing = await _isar.runtimeStates
        .filter()
        .saveSlotIdEqualTo(saveSlotId)
        .findFirst();

    if (existing == null) {
      final newState = RuntimeState()
        ..saveSlotId = saveSlotId
        ..currentEpisodeId = "ep1_the_spark" // Default start
        ..currentSceneId = "scene_1"
        ..variablesJson = "{}"
        ..unlockedThreads = []
        ..completedNodes = []
        ..scriptVersion = "1.0"
        ..userName = "Nadia"
        ..userBio = "Just looking for a spark..."
        ..unlockedGallery = [
           "assets/avatars/avatar_nadia.png" // AppConstants.avatarNadia
        ]
        ..isSfxEnabled = true
        ..isMusicEnabled = true
        ..isNotificationsEnabled = true;

      await _isar.writeTxn(() async {
        await _isar.runtimeStates.put(newState);
      });
    }
  }

  Future<RuntimeState> getRuntimeState() async {
    final state = await _isar.runtimeStates
        .filter()
        .saveSlotIdEqualTo(saveSlotId)
        .findFirst();
    return state!; // _ensureRuntimeState guarantees this exists
  }

  Stream<RuntimeState> watchRuntimeState() {
    return _isar.runtimeStates
        .filter()
        .saveSlotIdEqualTo(saveSlotId)
        .watch(fireImmediately: true)
        .map((event) => event.isNotEmpty ? event.first : RuntimeState());
  }

  Future<void> updateRuntime({
    String? sceneId,
    List<String>? newUnlockedThreads,
    String? variablesJson,
  }) async {
    await _isar.writeTxn(() async {
      final state = await getRuntimeState();

      if (sceneId != null) state.currentSceneId = sceneId;
      if (variablesJson != null) state.variablesJson = variablesJson;

      if (newUnlockedThreads != null) {
        final current = state.unlockedThreads.toList();
        for (final t in newUnlockedThreads) {
          if (!current.contains(t)) current.add(t);
        }
        state.unlockedThreads = current;
      }

      await _isar.runtimeStates.put(state);
    });
  }

  // ---------------------------------------------------------------------------
  // ⚙️ Settings & Profile Updates (New)
  // ---------------------------------------------------------------------------

  Future<void> updateProfile({String? name, String? bio}) async {
    await _isar.writeTxn(() async {
      final state = await getRuntimeState();
      if (name != null) state.userName = name;
      if (bio != null) state.userBio = bio;
      await _isar.runtimeStates.put(state);
    });
  }

  Future<void> updateSettings({
    bool? sfx,
    bool? music,
    bool? notif,
  }) async {
    await _isar.writeTxn(() async {
      final state = await getRuntimeState();
      if (sfx != null) state.isSfxEnabled = sfx;
      if (music != null) state.isMusicEnabled = music;
      if (notif != null) state.isNotificationsEnabled = notif;
      await _isar.runtimeStates.put(state);
    });
  }

  Future<void> unlockGalleryItem(String path) async {
    await _isar.writeTxn(() async {
      final state = await getRuntimeState();
      final current = state.unlockedGallery.toList();
      if (!current.contains(path)) {
        current.add(path);
        state.unlockedGallery = current;
        await _isar.runtimeStates.put(state);
      }
    });
  }

  Future<void> recordEnding(String endingId) async {
    await _isar.writeTxn(() async {
      final state = await getRuntimeState();
      final current = state.endingHistory.toList();
      if (!current.contains(endingId)) {
        current.add(endingId);
        state.endingHistory = current;
        await _isar.runtimeStates.put(state);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Playback State (Per Thread)
  // ---------------------------------------------------------------------------

  Future<ThreadPlaybackState> getThreadState(String threadId) async {
    final compositeId = ThreadPlaybackState.getCompositeId(saveSlotId, threadId);
    final state = await _isar.threadPlaybackStates
        .filter()
        .compositeIdEqualTo(compositeId)
        .findFirst();

    if (state != null) return state;

    // Create default if missing
    final newState = ThreadPlaybackState()
      ..saveSlotId = saveSlotId
      ..threadId = threadId
      ..compositeId = compositeId
      ..currentSceneId = "scene_1"
      ..cursor = 0;

    await _isar.writeTxn(() async {
      await _isar.threadPlaybackStates.put(newState);
    });

    return newState;
  }

  Future<void> updateThreadCursor(String threadId, int newCursor, {String? sceneId}) async {
    final compositeId = ThreadPlaybackState.getCompositeId(saveSlotId, threadId);

    await _isar.writeTxn(() async {
      final state = await _isar.threadPlaybackStates
          .filter()
          .compositeIdEqualTo(compositeId)
          .findFirst();

      if (state != null) {
        state.cursor = newCursor;
        if (sceneId != null) state.currentSceneId = sceneId;
        await _isar.threadPlaybackStates.put(state);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Pending Deliveries
  // ---------------------------------------------------------------------------

  Future<List<PendingDelivery>> getPendingDeliveries(String threadId) async {
    // 🛠️ Isar Generated Accessor: pendingDeliverys
    return await _isar.pendingDeliverys
        .filter()
        .saveSlotIdEqualTo(saveSlotId)
        .threadIdEqualTo(threadId)
        .sortByDeliverAt()
        .findAll();
  }

  Future<List<PendingDelivery>> getAllPendingDeliveries() async {
    // 🛠️ Isar Generated Accessor: pendingDeliverys
    return await _isar.pendingDeliverys
        .filter()
        .saveSlotIdEqualTo(saveSlotId)
        .sortByDeliverAt()
        .findAll();
  }

  Future<void> addPendingDeliveries(List<PendingDelivery> items) async {
    await _isar.writeTxn(() async {
      // 🛠️ Isar Generated Accessor: pendingDeliverys
      await _isar.pendingDeliverys.putAll(items);
    });
  }

  Future<void> removePendingDelivery(int id) async {
    await _isar.writeTxn(() async {
      // 🛠️ Isar Generated Accessor: pendingDeliverys
      await _isar.pendingDeliverys.delete(id);
    });
  }

  Future<void> clearPendingForThread(String threadId) async {
    await _isar.writeTxn(() async {
      // 🛠️ Isar Generated Accessor: pendingDeliverys
      await _isar.pendingDeliverys
          .filter()
          .saveSlotIdEqualTo(saveSlotId)
          .threadIdEqualTo(threadId)
          .deleteAll();
    });
  }

  // ---------------------------------------------------------------------------
  // Visible Messages
  // ---------------------------------------------------------------------------

  Stream<List<VisibleMessage>> watchMessages(String threadId) {
    return _isar.visibleMessages
        .filter()
        .saveSlotIdEqualTo(saveSlotId)
        .threadIdEqualTo(threadId)
        .sortByDeliveredAt() // Ensure chronological order
        .watch(fireImmediately: true);
  }

  Future<void> addVisibleMessage(VisibleMessage msg) async {
    await _isar.writeTxn(() async {
      await _isar.visibleMessages.put(msg);
    });
  }
}
