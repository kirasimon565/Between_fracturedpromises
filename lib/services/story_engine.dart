import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart' as rx; 
import '../models/message.dart';
import '../models/choice.dart';
import 'firestore_service.dart';
import 'state_service.dart';
import 'audio_service.dart'; 
import '../utils/delays.dart';

class StoryEngine extends GetxService {
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final StateService _stateService = Get.find<StateService>();
  final AudioService _audioService = Get.find<AudioService>(); 

  final Map<String, rx.BehaviorSubject<List<Message>>> _visibleMessages = {};
  final RxMap<String, bool> isTyping = <String, bool>{}.obs;
  
  final RxList<String> unlockedGlobalSecrets = <String>[].obs;
  
  // 🛠️ Categorized lists to solve the "Daniel in both apps" problem
  RxList<String> messengerThreads = <String>[].obs;
  RxList<String> makeloveThreads = <String>[].obs;
  
  // Keep the raw list for internal logic
  RxList<String> activeThreadIds = <String>[].obs;

  Rx<String?> get currentEpisode => _stateService.currentEpisodeId;

  final Map<String, StreamSubscription> _subscriptions = {};
  final Map<String, List<Message>> _incomingBuffers = {};
  final Map<String, bool> _isProcessingQueue = {};
  final Map<String, QuerySnapshot> _lastSnapshots = {};

  StreamSubscription? _threadsSubscription;

  @override
  void onInit() {
    super.onInit();
    
    ever(_stateService.currentSceneId, (sceneId) {
      print("ENGINE DEBUG: Scene transition to: $sceneId");
      _updateActiveThreads();
      _recheckAllThreads();
    });

    ever(_stateService.currentEpisodeId, (episodeId) {
      if (episodeId != null) _startDiscoveringThreads(episodeId);
    });

    final initialEpisode = _stateService.currentEpisodeId.value ?? 'ep1_the_spark';
    _startDiscoveringThreads(initialEpisode);
  }

  String? getMetadata(String key) {
    return _stateService.variables[key]?.toString();
  }

  void _updateActiveThreads() {
    // Clear display lists to rebuild them based on scene/app
    messengerThreads.clear();
    makeloveThreads.clear();

    _lastSnapshots.forEach((threadId, snapshot) {
      final messages = snapshot.docs;
      String currentScene = _stateService.currentSceneId.value ?? 'scene_1';
      
      // Check if character has messages in this scene
      bool hasMessagesInCurrentScene = messages.any((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['sceneId'] == currentScene || data['sceneId'] == null;
      });

      if (hasMessagesInCurrentScene) {
        if (!activeThreadIds.contains(threadId)) activeThreadIds.add(threadId);
        
        // 🛠️ Determine which app list the character belongs to
        final firstMsgData = messages.first.data() as Map<String, dynamic>;
        // We look for 'Makelove' or 'Messenger' in the message data
        String app = (firstMsgData['app'] ?? 'Messenger').toString().toLowerCase();
        
        if (app == 'makelove' || threadId == 'daniel') {
          if (!makeloveThreads.contains(threadId)) makeloveThreads.add(threadId);
        } else {
          if (!messengerThreads.contains(threadId)) messengerThreads.add(threadId);
        }
      }
    });
  }

  bool hasCompletedThread(String threadId) {
    return activeThreadIds.contains(threadId);
  }

  void loadEpisode(String episodeId) {
    _stateService.currentEpisodeId.value = episodeId;
  }

  void _startDiscoveringThreads(String episodeId) {
    print("ENGINE DEBUG: Discovering threads for: $episodeId");
    _threadsSubscription?.cancel();
    _threadsSubscription = _firestore.streamActiveThreadIds(episodeId).listen((threads) {
      activeThreadIds.assignAll(threads);
      for (var id in threads) {
        _startListeningToThread(id);
      }
    });
  }

  void _recheckAllThreads() {
    _lastSnapshots.forEach((threadId, snapshot) {
      _handleFirestoreUpdate(threadId, snapshot);
    });
  }

  Stream<Message?> getLastMessageStream(String threadId) {
     return getMessagesStream(threadId).map((list) => list.isNotEmpty ? list.last : null);
  }

  Stream<List<Message>> getMessagesStream(String threadId) {
    final sanitizedId = threadId.toLowerCase().trim();
    if (!_visibleMessages.containsKey(sanitizedId)) {
      _visibleMessages[sanitizedId] = rx.BehaviorSubject<List<Message>>.seeded([]);
      _startListeningToThread(sanitizedId);
    }
    return _visibleMessages[sanitizedId]!.stream;
  }

  void _startListeningToThread(String threadId) {
    final sanitizedId = threadId.toLowerCase().trim();
    if (_subscriptions.containsKey(sanitizedId)) return;
    
    String episodeId = _stateService.currentEpisodeId.value ?? 'ep1_the_spark';
    _subscriptions[sanitizedId] = _firestore.streamMessages(episodeId, sanitizedId).listen((snapshot) {
      _handleFirestoreUpdate(sanitizedId, snapshot);
    });
  }

  void _handleFirestoreUpdate(String threadId, QuerySnapshot snapshot) {
    _lastSnapshots[threadId] = snapshot;
    
    List<Message> allMessages = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Message.fromJson(data);
    }).toList();

    String currentSceneId = _stateService.currentSceneId.value ?? 'scene_1';
    
    // 🛠️ App Filtering Logic
    _updateActiveThreads();

    final subject = _visibleMessages[threadId];
    if (subject == null) return;

    final currentVisible = subject.value;
    
    // 🛠️ RESILIENCY: If we are in the chat screen, we want to see the messages
    // Even if the sceneId is slightly wrong, we show them to the player.
    final relevantMessages = allMessages.where((m) {
      return m.sceneId == currentSceneId || m.sceneId == null || m.sender == Sender.nadia;
    }).toList();
    
    relevantMessages.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final visibleIds = currentVisible.map((m) => m.id).toSet();
    final newMessages = relevantMessages.where((m) => !visibleIds.contains(m.id)).toList();

    if (newMessages.isNotEmpty) {
      print("ENGINE DEBUG: Pushing ${newMessages.length} messages to $threadId");
      if (_incomingBuffers[threadId] == null) _incomingBuffers[threadId] = [];
      _incomingBuffers[threadId]!.addAll(newMessages);
      _processQueue(threadId);
    }
  }

  void _processQueue(String threadId) async {
    if (_isProcessingQueue[threadId] == true) return;
    _isProcessingQueue[threadId] = true;

    final subject = _visibleMessages[threadId];
    if (subject == null) {
      _isProcessingQueue[threadId] = false;
      return;
    }

    while (_incomingBuffers[threadId]?.isNotEmpty ?? false) {
      final msg = _incomingBuffers[threadId]!.removeAt(0);

      if (msg.sender != Sender.nadia && msg.sender != Sender.system) {
        isTyping[threadId] = true;
        _audioService.playTyping();
        int typeTime = msg.delay > 0 ? msg.delay : AppDelays.minTyping;
        await Future.delayed(Duration(milliseconds: typeTime));
        isTyping[threadId] = false;
      } else {
        await Future.delayed(Duration(milliseconds: AppDelays.messageGap));
      }

      final currentList = subject.value;
      subject.add([...currentList, msg]);
      _audioService.playPing();
    }
    _isProcessingQueue[threadId] = false;
  }

  void makeChoice(Choice choice) {
    if (choice.impact != null) {
      choice.impact!.forEach((key, value) {
        _stateService.setVariable(key, value);
      });
    }
    _audioService.playVibrate();
    _stateService.recordChoice(choice.targetNode);
    
    final episodeId = _stateService.currentEpisodeId.value ?? 'ep1_the_spark';
    _stateService.updateProgress(episodeId, choice.targetNode);
    isTyping.clear();
  }

  @override
  void onClose() {
    _threadsSubscription?.cancel();
    _subscriptions.values.forEach((s) => s.cancel());
    _visibleMessages.values.forEach((subject) => subject.close());
    super.onClose();
  }
}
