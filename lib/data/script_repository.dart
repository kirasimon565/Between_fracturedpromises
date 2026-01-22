import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

import 'package:between_fractured_promises/data/playback_store.dart';
import 'package:between_fractured_promises/data/models/script_models.dart';
// Note: Imports for Isar extensions will be available via playback_store exports or explicit imports of generated code if needed.
// But usually importing the model file with `part` directive is enough if we are in the same package.
// Actually, `isar.scriptMessages` comes from `script_models.g.dart`.
// Since `ScriptRepository` is in a different file, we rely on `playback_store.dart` exporting it OR importing it here.
// But `isar` object is passed from `_store`.

class ScriptRepository extends GetxService {
  final PlaybackStore _store = Get.find<PlaybackStore>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache of fetched episodes to prevent re-fetching in same session if needed
  final Set<String> _fetchedEpisodes = {};

  /// Ensures the script for an episode is loaded into Isar.
  /// Fetches from Firestore if not present or forced.
  Future<void> ensureEpisodeScript(String episodeId) async {
    if (_fetchedEpisodes.contains(episodeId)) return;

    // Check if we already have script data for this episode?
    final count = await _store.isar.scriptMessages
        .filter()
        .scriptIdStartsWith("${episodeId}_")
        .count();

    if (count > 0) {
      _fetchedEpisodes.add(episodeId);
      // ignore: avoid_print
      print("SCRIPT: Episode $episodeId already cached locally ($count msgs).");
      return;
    }

    // ignore: avoid_print
    print("SCRIPT: Fetching episode $episodeId from Firestore...");
    await _fetchAndSaveEpisode(episodeId);
    _fetchedEpisodes.add(episodeId);
  }

  Future<void> _fetchAndSaveEpisode(String episodeId) async {
    // 1. Fetch Threads
    final threadsSnapshot = await _firestore
        .collection('episodes')
        .doc(episodeId)
        .collection('threads')
        .get();

    final List<ScriptMessage> allMessages = [];
    final List<ThreadMeta> allMetas = [];

    for (final threadDoc in threadsSnapshot.docs) {
      final threadId = threadDoc.id;
      final threadData = threadDoc.data();

      // Save Thread Meta
      final meta = ThreadMeta()
        ..threadId = threadId.toLowerCase().trim()
        ..app = (threadData['app'] ?? 'messenger').toString().toLowerCase()
        ..characterId = (threadData['characterId'] ?? threadId).toString()
        ..unlockRuleJson = null; // Can implement later

      allMetas.add(meta);

      // 2. Fetch Messages for this thread
      final messagesSnapshot = await threadDoc.reference.collection('messages').get();

      for (final msgDoc in messagesSnapshot.docs) {
        final data = msgDoc.data();

        // Handle variations in field names (snake_case vs camelCase)
        final orderIndex = (data['orderIndex'] ?? data['order_index'] ?? 0) as int;
        final delay = (data['delay'] ?? 1000) as int;
        final type = (data['type'] ?? 'text').toString();
        final content = (data['content'] ?? '').toString();
        final sender = (data['sender'] ?? 'system').toString();
        final sceneId = (data['sceneId'] ?? data['scene_id'] ?? 'scene_1').toString();

        final choicesList = data['choices'] as List<dynamic>?;
        final choicesJson = choicesList != null ? jsonEncode(choicesList) : null;

        final scriptMsg = ScriptMessage()
          ..scriptId = "${episodeId}_${threadId}_${msgDoc.id}"
          ..threadId = threadId.toLowerCase().trim()
          ..sceneId = sceneId
          ..orderIndex = orderIndex
          ..sender = sender
          ..content = content
          ..type = type
          ..delay = delay
          ..choicesJson = choicesJson
          ..metadataJson = data['metadata'] != null ? jsonEncode(data['metadata']) : null;

        allMessages.add(scriptMsg);
      }
    }

    // Atomic write to Isar
    await _store.isar.writeTxn(() async {
      await _store.isar.threadMetas.putAll(allMetas);
      await _store.isar.scriptMessages.putAll(allMessages);
    });

    // ignore: avoid_print
    print("SCRIPT: Saved ${allMessages.length} messages and ${allMetas.length} threads for $episodeId.");
  }

  /// Returns the script messages for a specific thread/scene, sorted by orderIndex.
  Future<List<ScriptMessage>> getScript(String threadId, String sceneId) async {
    return await _store.isar.scriptMessages
        .filter()
        .threadIdEqualTo(threadId.toLowerCase().trim())
        .sceneIdEqualTo(sceneId)
        .sortByOrderIndex()
        .findAll();
  }

  /// Look up metadata for a thread (e.g. which app it belongs to)
  Future<ThreadMeta?> getThreadMeta(String threadId) async {
    return await _store.isar.threadMetas
        .filter()
        .threadIdEqualTo(threadId.toLowerCase().trim())
        .findFirst();
  }
}
