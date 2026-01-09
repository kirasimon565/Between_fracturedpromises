import 'package:get/get.dart';
import '../models/episode.dart';
import '../models/message.dart';
import '../models/chat_thread.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'firestore_service.dart';
import '../utils/delays.dart';

class StoryEngine extends GetxService {
  final FirestoreService _firestore = Get.find<FirestoreService>();

  // State
  Rx<Episode?> currentEpisode = Rx<Episode?>(null);
  RxList<Message> unlockedMessages = <Message>[].obs; // Messages user has "received"
  RxMap<String, bool> isTyping = <String, bool>{}.obs; // Sender -> isTyping

  // Thread Views
  RxList<ChatThread> get activeThreads {
    // Group unlocked messages by sender (or logic to group threads)
    final Map<String, List<Message>> groups = {};
    for (var m in unlockedMessages) {
      String key = m.sender.name;
      if (key == 'nadia') continue; // Don't make a thread for self
      if (groups.containsKey(key)) {
        groups[key]!.add(m);
      } else {
        groups[key] = [m];
      }
    }

    // Also include Nadia's messages in the relevant thread (simplified logic: find last other person)
    // For this engine, we will simplify:
    // If the sender is Nadia, we attach it to the PREVIOUS message's thread.

    // Better approach for display: We filter messages relevant to a specific partner.
    return groups.entries.map((e) => ChatThread(id: e.key, messages: e.value)).toList().obs;
  }

  // Active Playback
  int _currentMessageIndex = 0;
  List<Message> _sceneQueue = [];
  bool _isPlaying = false;

  Future<void> loadEpisode(String episodeId) async {
    try {
      final String jsonString = await rootBundle.loadString('data/cache/${episodeId}_cache.json');
      final Map<String, dynamic> json = jsonDecode(jsonString);
      currentEpisode.value = Episode.fromJson(json);

      // Auto-start first scene for demo
      if (currentEpisode.value != null && currentEpisode.value!.scenes.isNotEmpty) {
        playScene(currentEpisode.value!.scenes.first.id);
      }
    } catch (e) {
      print("Local load failed: $e");
    }
  }

  void playScene(String sceneId) {
    if (currentEpisode.value == null) return;

    final scene = currentEpisode.value!.scenes.firstWhere(
      (s) => s.id == sceneId,
      orElse: () => Scene(id: 'error', messages: [])
    );

    _sceneQueue = scene.messages;
    _currentMessageIndex = 0;
    _playNextMessage();
  }

  void _playNextMessage() async {
    if (_currentMessageIndex >= _sceneQueue.length) return;

    final msg = _sceneQueue[_currentMessageIndex];

    // Simulate Typing
    if (msg.sender != Sender.nadia && msg.sender != Sender.system) {
       isTyping[msg.sender.name] = true;
       await Future.delayed(Duration(milliseconds: AppDelays.minTyping)); // Simplified delay
       isTyping[msg.sender.name] = false;
    }

    // Add to unlocked
    unlockedMessages.add(msg);
    _currentMessageIndex++;

    // Wait before next
    await Future.delayed(Duration(milliseconds: msg.delay > 0 ? msg.delay : AppDelays.messageGap));

    _playNextMessage();
  }

  List<Message> getMessagesForThread(String partnerName) {
    // Return all messages where sender is partner OR sender is nadia (assuming single linear story context for now)
    // In a real complex graph, we'd need a threadId on the message.
    // For this demo, we assume if it's in the log, and it's Nadia, it belongs to the current context.
    // We will just filter by the partner for now + Nadia's adjacent messages.
    // SIMPLIFICATION: Just return all for now to test UI, or filter strictly.
    return unlockedMessages.where((m) => m.sender.name == partnerName || m.sender == Sender.nadia).toList();
  }
}
