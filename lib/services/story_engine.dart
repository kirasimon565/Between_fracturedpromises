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
    
    // Refresh list and messages if scene changes
    ever(_stateService.currentSceneId, (sceneId) {
      print("DEBUG: Scene changed to: $sceneId");
      _updateActiveThreads();
      _recheckAllThreads();
    });

    // Switch thread listeners if episode changes
    ever(_stateService.currentEpisodeId, (episodeId) {
      if (episodeId != null) _startDiscoveringThreads(episodeId);
    });

    // Default to the specific episode ID used in uploader
    final initialEpisode = _stateService.currentEpisodeId.value ?? 'ep1_the_spark';
    _startDiscoveringThreads(initialEpisode);
  }

  /// 🛠️ RESTORED: Required by EndingController to determine player outcomes
  String? getMetadata(String key) {
    return _stateService.variables[key]?.toString();
  }

  void _updateActiveThreads() {
    _lastSnapshots.forEach((threadId, snapshot) {
      final messages = snapshot.docs;
      String currentScene = _stateService.currentSceneId.value ?? 'scene_1';
      
      bool hasMessagesInCurrentScene = messages.any((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // 🛠️ Resilience: Allow messages with NO sceneId to show up during testing
        return data['sceneId'] == currentScene || data['sceneId'] == null;
      });

      if (hasMessagesInCurrentScene && !activeThreadIds.contains(threadId)) {
        activeThreadIds.add(threadId);
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
    print("DEBUG: Discovering threads for: $episodeId");
    _threadsSubscription?.cancel();
    _threadsSubscription = _firestore.streamActiveThreadIds(episodeId).listen((threads) {
      print("DEBUG: Threads found in DB: $threads");
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
    if (!_visibleMessages.containsKey(threadId)) {
      _visibleMessages[threadId] = rx.BehaviorSubject<List<Message>>.seeded([]);
      _startListeningToThread(threadId);
    }
    return _visibleMessages[threadId]!.stream;
  }

  void _startListeningToThread(String threadId) {
    if (_subscriptions.containsKey(threadId)) return;
    String episodeId = _stateService.currentEpisodeId.value ?? 'ep1_the_spark';

    print("DEBUG: Subscribing to $threadId in $episodeId");
    _subscriptions[threadId] = _firestore.streamMessages(episodeId, threadId).listen((snapshot) {
      _handleFirestoreUpdate(threadId, snapshot);
    });
  }

  void _handleFirestoreUpdate(String threadId, QuerySnapshot snapshot) {
    _lastSnapshots[threadId] = snapshot;
    print("DEBUG: Received ${snapshot.docs.length} docs for $threadId");

    List<Message> allMessages = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Message.fromJson(data);
    }).toList();

    String currentSceneId = _stateService.currentSceneId.value ?? 'scene_1';
    
    // Character list logic: show if they have messages for current scene OR null sceneId
    bool shouldBeActive = allMessages.any((m) => m.sceneId == currentSceneId || m.sceneId == null);
    if (shouldBeActive && !activeThreadIds.contains(threadId)) {
      activeThreadIds.add(threadId);
    }

    final subject = _visibleMessages[threadId];
    if (subject == null) return;

    final currentVisible = subject.value;
    
    // Filter relevant messages
    final relevantMessages = allMessages.where((m) {
      return m.sceneId == currentSceneId || m.sceneId == null;
    }).toList();
    
    relevantMessages.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final visibleIds = currentVisible.map((m) => m.id).toSet();
    final newMessages = relevantMessages.where((m) => !visibleIds.contains(m.id)).toList();

    if (newMessages.isNotEmpty) {
      print("DEBUG: Adding ${newMessages.length} new messages to $threadId queue");
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

      final meta = msg.metadata;
      if (meta != null && meta['is_secret'] == true) {
        final String? imageUrl = meta['image_url'];
        if (imageUrl != null && !unlockedGlobalSecrets.contains(imageUrl)) {
          unlockedGlobalSecrets.add(imageUrl);
          _audioService.playVibrate(); 
        }
      }
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
