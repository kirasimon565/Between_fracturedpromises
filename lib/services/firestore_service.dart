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
    // 🛠️ FIX: Unified to 'orderIndex' to match the Message model's toJson()
    return _db
        .collection('episodes')
        .doc(episodeId)
        .collection('threads')
        .doc(threadId)
        .collection('messages')
        .orderBy('orderIndex') 
        .snapshots();
  }

  // Listen to Available Threads
  Stream<List<String>> streamActiveThreadIds(String episodeId) {
    // This streams the 'threads' subcollection. 
    // It will return the IDs (e.g., 'ethan', 'claire') as they are created.
    return _db
      .collection('episodes')
      .doc(episodeId)
      .collection('threads')
      .snapshots()
      .map((snapshot) {
        final ids = snapshot.docs.map((doc) => doc.id).toList();
        print("FIRESTORE DEBUG: Found threads for $episodeId: $ids");
        return ids;
      });
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

          // Determine threadId (lowercase to prevent path errors)
          String threadId = 'unknown';
          if (originalMsg.sender == Sender.nadia) {
            threadId = originalMsg.recipient?.toLowerCase() ?? 'unknown';
          } else {
            // Using .name for enum to string conversion
            threadId = originalMsg.sender.toString().split('.').last.toLowerCase();
          }

          // 🛠️ ENSURE THREAD DOCUMENT EXISTS (Crucial for the stream to see it)
          final threadRef = _db
              .collection('episodes')
              .doc(episodeId)
              .collection('threads')
              .doc(threadId);
          
          batch.set(threadRef, {
            'last_updated': FieldValue.serverTimestamp(),
            'thread_id': threadId,
          }, SetOptions(merge: true));

          List<Choice>? choicesForMsg = originalMsg.choices;
          // If it's the last message in a scene, attach the scene's branching choices
          if (i == scene.messages.length - 1 && (scene.choices?.isNotEmpty ?? false)) {
            choicesForMsg = scene.choices;
          }

          final Message newMsg = Message(
            id: originalMsg.id,
            sender: originalMsg.sender,
            recipient: originalMsg.recipient,
            content: originalMsg.content,
            type: originalMsg.type,
            delay: originalMsg.delay,
            orderIndex: i, // Matches the 'orderIndex' orderBy
            sceneId: scene.id,
            choices: choicesForMsg
          );

          final msgRef = threadRef.collection('messages').doc(newMsg.id);
          batch.set(msgRef, newMsg.toJson());
        }
      }

      await batch.commit();
      print("Episode $episodeId uploaded successfully.");

    } catch (e) {
      print("Error uploading episode: $e");
      rethrow;
    }
  }

  // Simple override for custom data
  Future<void> uploadEpisode(String episodeId, Map<String, dynamic> data) async {
    await _db.collection('episodes').doc(episodeId).set(data);
  }
}
