// lib/services/firestore_service.dart

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
  Future<void> saveProgress(
    String episodeId,
    String sceneId,
    Map<String, dynamic> choices,
  ) async {
    final uid = _auth.uid;
    if (uid.isEmpty) return;

    await _db.collection('users').doc(uid).set({
      'current_episode': episodeId,
      'current_scene': sceneId,
      'choices': choices,
      'last_updated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Listen to User Data
  Stream<DocumentSnapshot> streamUser(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // Listen to Character Data
  Stream<DocumentSnapshot> streamCharacter(String characterId) {
    return _db
        .collection('characters')
        .doc(characterId.toLowerCase().trim())
        .snapshots();
  }

  /// Stream Messages (sanitized + ordered by orderIndex)
  Stream<QuerySnapshot> streamMessages(String episodeId, String threadId) {
    final String sanitizedId = threadId.toLowerCase().trim();

    // ignore: avoid_print
    print(
      "FIRESTORE: Streaming /episodes/$episodeId/threads/$sanitizedId/messages",
    );

    return _db
        .collection('episodes')
        .doc(episodeId)
        .collection('threads')
        .doc(sanitizedId)
        .collection('messages')
        .orderBy('orderIndex', descending: false)
        .snapshots();
  }

  /// Real-time thread discovery
  Stream<List<String>> streamActiveThreadIds(String episodeId) {
    return _db
        .collection('episodes')
        .doc(episodeId)
        .collection('threads')
        .snapshots()
        .map((snapshot) {
      final ids = snapshot.docs.map((doc) => doc.id).toList();
      // ignore: avoid_print
      print("FIRESTORE DEBUG: Found threads in DB: $ids");
      return ids;
    });
  }

  // Episode Fetching
  Future<Map<String, dynamic>?> fetchEpisode(String episodeId) async {
    try {
      final doc = await _db.collection('episodes').doc(episodeId).get();
      if (doc.exists) return doc.data() as Map<String, dynamic>;
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching episode: $e");
    }
    return null;
  }

  /// Upload Episode Script (batch)
  ///
  /// ✅ Update included:
  /// - Writes `app` to thread docs AND messages (so UI can reliably separate Messenger vs Makelove).
  /// - Uses a simple rule: Daniel => makelove, everyone else => messenger (you can expand later).
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
        for (int i = 0; i < scene.messages.length; i++) {
          final Message originalMsg = scene.messages[i];

          // Determine threadId (always lowercase)
          String threadId = 'unknown';
          if (originalMsg.sender == Sender.nadia) {
            threadId = originalMsg.recipient?.toLowerCase().trim() ?? 'unknown';
          } else {
            threadId =
                originalMsg.sender.toString().split('.').last.toLowerCase().trim();
          }

          // ✅ Decide which app this thread belongs to
          // Expand this mapping later if you add more Makelove-only characters.
          final String app = (threadId == 'daniel') ? 'makelove' : 'messenger';

          final threadRef = _db
              .collection('episodes')
              .doc(episodeId)
              .collection('threads')
              .doc(threadId);

          // Solidify parent doc so it shows up in thread lists + includes app
          batch.set(threadRef, {
            'last_updated': FieldValue.serverTimestamp(),
            'id': threadId,
            'app': app, // ✅ NEW
          }, SetOptions(merge: true));

          // If last message in scene and scene has choices, attach them there
          List<Choice>? choicesForMsg = originalMsg.choices;
          if (i == scene.messages.length - 1 && (scene.choices?.isNotEmpty ?? false)) {
            choicesForMsg = scene.choices;
          }

          // Message data (keys match StoryEngine expectations)
          final Map<String, dynamic> messageData = {
            'id': originalMsg.id,
            'sender': originalMsg.sender.toString().split('.').last,
            'content': originalMsg.content,
            'type': originalMsg.type.toString().split('.').last,
            'delay': originalMsg.delay,
            'orderIndex': i,
            'sceneId': scene.id,
            'choices': choicesForMsg?.map((c) => c.toJson()).toList(),
            'timestamp': FieldValue.serverTimestamp(),
            'app': app, // ✅ NEW (lets you infer app from first message too)
          };

          final msgRef = threadRef.collection('messages').doc(originalMsg.id);
          batch.set(msgRef, messageData);
        }
      }

      await batch.commit();
      // ignore: avoid_print
      print("SUCCESS: Episode $episodeId transmitted. Open the chat now.");
    } catch (e) {
      // ignore: avoid_print
      print("UPLOAD ERROR: $e");
      rethrow;
    }
  }

  Future<void> uploadEpisode(String episodeId, Map<String, dynamic> data) async {
    await _db.collection('episodes').doc(episodeId).set(data);
  }
}
