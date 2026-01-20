import 'package:get/get.dart';
import 'firestore_service.dart';
import '../models/episode.dart';

class EpisodeService extends GetxService {
  final FirestoreService _firestore = Get.find<FirestoreService>();

  /// Fetches the metadata for an episode (Title, ID, etc.)
  Future<Episode?> getEpisode(String episodeId) async {
    final data = await _firestore.fetchEpisode(episodeId);
    if (data != null) {
      return Episode.fromJson(data);
    }
    return null;
  }

  /// 🛠️ Updated: Fetches the ID the user is actually playing from Firestore
  Future<String> getActiveEpisodeId() async {
    // In our current setup, we default to the first episode
    // Later, this will pull from the user's 'current_episode' field in Firestore
    return 'ep1_the_spark';
  }
}
