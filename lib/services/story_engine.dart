import 'package:get/get.dart';
import '../models/episode.dart';
import '../models/message.dart';
import '../models/chat_thread.dart';
import '../models/choice.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'firestore_service.dart';
import 'state_service.dart';
import '../utils/delays.dart';
import '../models/scene.dart';

class StoryEngine extends GetxService {
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final StateService _stateService = Get.find<StateService>();

  // State
  Rx<Episode?> currentEpisode = Rx<Episode?>(null);
  RxList<Message> unlockedMessages = <Message>[].obs;
  RxMap<String, bool> isTyping = <String, bool>{}.obs;
  RxList<Choice> currentChoices = <Choice>[].obs;

  // Thread Views
  RxList<ChatThread> get activeThreads {
    final Map<String, List<Message>> groups = {};
    for (var m in unlockedMessages) {
      if (m.sender == Sender.system) continue;

      // Determine thread key: if I am sender, use recipient. If they are sender, use them.
      String key;
      if (m.sender == Sender.nadia) {
        key = m.recipient?.toLowerCase() ?? 'unknown';
      } else {
        key = m.sender.name.toLowerCase();
      }

      if (groups.containsKey(key)) {
        groups[key]!.add(m);
      } else {
        groups[key] = [m];
      }
    }
    return groups.entries.map((e) => ChatThread(id: e.key, messages: e.value)).toList().obs;
  }

  // Active Playback
  int _currentMessageIndex = 0;
  List<Message> _sceneQueue = [];

  Future<void> loadEpisode(String episodeId) async {
    try {
      unlockedMessages.clear();
      currentChoices.clear();

      final String jsonString = await rootBundle.loadString('data/cache/${episodeId}_cache.json');
      final Map<String, dynamic> json = jsonDecode(jsonString);
      currentEpisode.value = Episode.fromJson(json);

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

    // Persist progress
    _stateService.updateProgress(currentEpisode.value!.id, sceneId);

    _sceneQueue = scene.messages;
    _currentMessageIndex = 0;
    currentChoices.clear(); // Clear previous choices
    _playNextMessage(scene);
  }

  void _playNextMessage(dynamic currentScene) async {
    // If queue finished
    if (_currentMessageIndex >= _sceneQueue.length) {
      _handleSceneEnd(currentScene);
      return;
    }

    final msg = _sceneQueue[_currentMessageIndex];

    // Simulate Typing
    if (msg.sender != Sender.nadia && msg.sender != Sender.system) {
       isTyping[msg.sender.name.toLowerCase()] = true;
       await Future.delayed(Duration(milliseconds: AppDelays.minTyping));
       isTyping[msg.sender.name.toLowerCase()] = false;
    }

    unlockedMessages.add(msg);
    _currentMessageIndex++;

    await Future.delayed(Duration(milliseconds: msg.delay > 0 ? msg.delay : AppDelays.messageGap));

    _playNextMessage(currentScene);
  }

  void _handleSceneEnd(dynamic scene) {
    // Check for choices
    if (scene.choices != null && scene.choices!.isNotEmpty) {
      currentChoices.assignAll(scene.choices!);
    } else if (scene.defaultNextScene != null) {
      // Auto advance
      playScene(scene.defaultNextScene!);
    } else {
      print("Episode End");
      // Could trigger an "Episode Complete" screen here
    }
  }

  void makeChoice(Choice choice) {
    currentChoices.clear();

    // Apply impact
    if (choice.impact != null) {
      choice.impact!.forEach((key, value) {
        _stateService.setVariable(key, value);
      });
    }

    // Save choice to history
    _stateService.recordChoice(choice.id);

    // Next Scene
    playScene(choice.nextSceneId);
  }

  List<Message> getMessagesForThread(String partnerName) {
    return unlockedMessages.where((m) {
      if (m.sender == Sender.system) return false;

      final bool isFromPartner = m.sender.name.toLowerCase() == partnerName.toLowerCase();
      final bool isFromMeToPartner = m.sender == Sender.nadia &&
                                     m.recipient?.toLowerCase() == partnerName.toLowerCase();

      return isFromPartner || isFromMeToPartner;
    }).toList();
  }
}
