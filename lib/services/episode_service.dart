import 'package:get/get.dart';
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
}
