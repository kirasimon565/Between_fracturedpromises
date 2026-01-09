import 'package:get/get.dart';
import '../models/episode.dart';
import '../models/message.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'firestore_service.dart';

class StoryEngine extends GetxService {
  final FirestoreService _firestore = Get.find<FirestoreService>();

  Rx<Episode?> currentEpisode = Rx<Episode?>(null);
  RxList<Message> messageLog = <Message>[].obs;

  Future<void> loadEpisode(String episodeId) async {
    // 1. Try local cache first (simulated here with assets for the demo)
    try {
      final String jsonString = await rootBundle.loadString('data/cache/${episodeId}_cache.json');
      final Map<String, dynamic> json = jsonDecode(jsonString);
      currentEpisode.value = Episode.fromJson(json);
    } catch (e) {
      print("Local load failed, trying remote: $e");
      // 2. Try Remote
      final data = await _firestore.fetchEpisode(episodeId);
      if (data != null) {
        currentEpisode.value = Episode.fromJson(data);
      }
    }
  }

  List<Message> getSceneMessages(String sceneId) {
    if (currentEpisode.value == null) return [];
    final scene = currentEpisode.value!.scenes.firstWhere(
      (s) => s.id == sceneId,
      orElse: () => Scene(id: 'error', messages: [])
    );
    return scene.messages;
  }
}
