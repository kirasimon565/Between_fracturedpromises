import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'auth_service.dart';
import '../models/episode.dart';
import '../models/scene.dart';
import '../models/message.dart';
import '../models/choice.dart';
import 'dart:convert';

class FirestoreService extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _auth = Get.find<AuthService>();

  // Progress Sync
  Future<void> saveProgress(String episodeId, String sceneId, Map<String, dynamic> choices) async {
    final uid = _auth.uid;
    if (uid.isEmpty) return;

    await _db.collection('users').doc(uid).set({
      'current_episode': episodeId,
      'current_scene': sceneId,
      'choices': choices,
      'last_updated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Listen to User Data (Progress, Contacts)
  Stream<DocumentSnapshot> streamUser(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // Listen to Character Data (Online Status)
  Stream<DocumentSnapshot> streamCharacter(String characterId) {
    return _db.collection('characters').doc(characterId).snapshots();
  }

  // Listen to Thread Messages
  Stream<QuerySnapshot> streamMessages(String episodeId, String threadId) {
    return _db
        .collection('episodes')
        .doc(episodeId)
        .collection('threads')
        .doc(threadId)
        .collection('messages')
        .orderBy('order_index')
        .snapshots();
  }

  // Episode Fetching
  Future<Map<String, dynamic>?> fetchEpisode(String episodeId) async {
    try {
      DocumentSnapshot doc = await _db.collection('episodes').doc(episodeId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching episode: $e");
    }
    return null;
  }

  // Admin Upload: Parses JSON and writes granular messages
  Future<void> uploadEpisodeScript(String episodeId, String jsonString) async {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final Episode episode = Episode.fromJson(json);

      final WriteBatch batch = _db.batch();

      // Save Episode Metadata
      final episodeRef = _db.collection('episodes').doc(episodeId);
      batch.set(episodeRef, {
        'id': episode.id,
        'title': episode.title,
        'uploaded_at': FieldValue.serverTimestamp(),
      });

      // Process Scenes
      for (final Scene scene in episode.scenes) {
        // Iterate messages
        for (int i = 0; i < scene.messages.length; i++) {
          final Message originalMsg = scene.messages[i];

          // Determine Thread ID
          // If Nadia sends, thread is recipient. If partner sends, thread is partner.
          String threadId = 'unknown';
          if (originalMsg.sender == Sender.nadia) {
            threadId = originalMsg.recipient?.toLowerCase() ?? 'unknown';
          } else {
            threadId = originalMsg.sender.name.toLowerCase();
          }

          // Check if this is the last message of the scene AND if the scene has choices
          List<Choice>? choicesForMsg = originalMsg.choices;
          if (i == scene.messages.length - 1 && (scene.choices?.isNotEmpty ?? false)) {
            choicesForMsg = scene.choices;
          }

          // Create new Message object with SceneID, OrderIndex, and potentially injected Choices
          final Message newMsg = Message(
            id: originalMsg.id,
            sender: originalMsg.sender,
            recipient: originalMsg.recipient,
            content: originalMsg.content,
            type: originalMsg.type,
            delay: originalMsg.delay,
            orderIndex: i, // Order within the scene
            sceneId: scene.id,
            choices: choicesForMsg
          );

          final msgRef = _db
              .collection('episodes')
              .doc(episodeId)
              .collection('threads')
              .doc(threadId)
              .collection('messages')
              .doc(newMsg.id); // Use ID from JSON if available, or auto-id if empty? Assumed ID exists.

          batch.set(msgRef, newMsg.toJson());
        }
      }

      await batch.commit();
      print("Episode $episodeId uploaded with granular messages.");

    } catch (e) {
      print("Error uploading episode: $e");
      rethrow;
    }
  }

  // Admin Upload (Legacy - kept for reference if needed, but replaced by above)
  Future<void> uploadEpisode(String episodeId, Map<String, dynamic> data) async {
    await _db.collection('episodes').doc(episodeId).set(data);
  }
}
