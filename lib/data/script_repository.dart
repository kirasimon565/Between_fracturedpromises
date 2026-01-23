import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

import 'package:between_fractured_promises/data/playback_store.dart';
import 'package:between_fractured_promises/data/models/script_models.dart';

class ScriptRepository extends GetxService {
  final PlaybackStore _store = Get.find<PlaybackStore>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache of fetched episodes to prevent re-fetching in same session
  final Set<String> _fetchedEpisodes = {};

  // 🛠️ NEW: Check if a specific scene exists locally in Isar
  // This is used by the StoryRuntime to trigger the "Coming Soon" screen
  Future<bool> doesSceneExist(String sceneId) async {
    final count = await _store.isar.scriptMessages
        .filter()
        .sceneIdEqualTo(sceneId)
        .count();
    return count > 0;
  }

  // 🛠️ NEW: Check if an episode is already fully downloaded
  Future<bool> isEpisodeLocal(String episodeId) async {
    final count = await _store.isar.scriptMessages
        .filter()
        .scriptIdStartsWith("${episodeId}_")
        .count();
    return count > 0;
  }

  // 🛠️ NEW: Bridge for the EpisodeController to trigger a download
  Future<void> saveScriptToLocal(Map<String, dynamic> scriptData) async {
    // We can pull the episodeId from the map passed by FirestoreService
    final String? episodeId = scriptData['episodeId'] ?? scriptData['id'];
    if (episodeId != null) {
      await _fetchAndSaveEpisode(episodeId);
    }
  }

  /// Ensures the script for an episode is loaded into Isar.
  Future<void> ensureEpisodeScript(String episodeId) async {
    if (_fetchedEpisodes.contains(episodeId)) return;

    final isLocal = await isEpisodeLocal(episodeId);
    if (isLocal) {
      _fetchedEpisodes.add(episodeId);
      debugPrint("SCRIPT: Episode $episodeId already cached locally.");
      return;
    }

    debugPrint("SCRIPT: Fetching episode $episodeId from Firestore...");
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
        ..characterId = (threadData['characterId'] ?? threadId).toString();

      allMetas.add(meta);

      // 2. Fetch Messages for this thread
      final messagesSnapshot = await threadDoc.reference.collection('messages').get();

      for (final msgDoc in messagesSnapshot.docs) {
        final data = msgDoc.data();

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

    debugPrint("SCRIPT: Saved ${allMessages.length} messages for $episodeId.");
  }

  /// Returns the script messages for a specific thread/scene
  Future<List<ScriptMessage>> getScript(String threadId, String sceneId) async {
    return await _store.isar.scriptMessages
        .filter()
        .threadIdEqualTo(threadId.toLowerCase().trim())
        .sceneIdEqualTo(sceneId)
        .sortByOrderIndex()
        .findAll();
  }

  /// Look up metadata for a thread
  Future<ThreadMeta?> getThreadMeta(String threadId) async {
    return await _store.isar.threadMetas
        .filter()
        .threadIdEqualTo(threadId.toLowerCase().trim())
        .findFirst();
  }
}
