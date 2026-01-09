import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'firestore_service.dart';
import '../models/episode.dart';

class EpisodeService extends GetxService {
  final FirestoreService _firestore = Get.find<FirestoreService>();

  // Logic to fetch, verify checksum, and cache episodes
  // This abstracts raw firestore calls from the StoryEngine

  Future<Episode?> getEpisode(String episodeId) async {
    // 1. Check Cache (Placeholder logic)
    // 2. Fetch Remote
    final data = await _firestore.fetchEpisode(episodeId);
    if (data != null) {
      return Episode.fromJson(data);
    }
    return null;
  }

  Future<String> getLatestEpisodeId() async {
    try {
      // Load local config as fallback
      final String jsonString = await rootBundle.loadString('data/cache/latest_episode.json');
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return json['episode_id'] ?? 'episode_1';
    } catch (e) {
      print("Error loading latest_episode.json: $e");
      return 'episode_1';
    }
  }
}
