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
  
  // 🛠️ Track discovered secrets across all threads
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
    
    // Refresh UI if scene changes
    ever(_stateService.currentSceneId, (_) => _recheckAllThreads());

    // Switch thread listeners if episode changes
    ever(_stateService.currentEpisodeId, (episodeId) {
      if (episodeId != null) _startDiscoveringThreads(episodeId);
    });

    final initialEpisode = _stateService.currentEpisodeId.value ?? 'episode_1';
    _startDiscoveringThreads(initialEpisode);
  }

  /// 🛠️ Check if a specific story thread has been started
  bool hasCompletedThread(String threadId) {
    return activeThreadIds.contains(threadId);
  }

  /// 🛠️ Pull narrative flags (like ending IDs) from StateService
  String? getMetadata(String key) {
    return _stateService.variables[key]?.toString();
  }

  void loadEpisode(String episodeId) {
    _stateService.currentEpisodeId.value = episodeId;
  }

  void _startDiscoveringThreads(String episodeId) {
    _threadsSubscription?.cancel();
    _threadsSubscription = _firestore.streamActiveThreadIds(episodeId).listen((threads) {
      activeThreadIds.assignAll(threads);
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
    String episodeId = _stateService.currentEpisodeId.value ?? 'episode_1';

    _subscriptions[threadId] = _firestore.streamMessages(episodeId, threadId).listen((snapshot) {
      _handleFirestoreUpdate(threadId, snapshot);
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
    final subject = _visibleMessages[threadId];
    if (subject == null) return;

    final currentVisible = subject.value;
    final relevantMessages = allMessages.where((m) => m.sceneId == currentSceneId).toList();
    relevantMessages.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final visibleIds = currentVisible.map((m) => m.id).toSet();
    final newMessages = relevantMessages.where((m) => !visibleIds.contains(m.id)).toList();

    if (newMessages.isNotEmpty) {
      if (_incomingBuffers[threadId] == null) _incomingBuffers[threadId] = [];
      _incomingBuffers[threadId]!.addAll(newMessages);
      _processQueue(threadId);
    }
  }

  /// 🛠️ Core Simulation Logic: Handles typing, delays, and gallery unlocks
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

      // 1. Handle Typing Simulation
      if (msg.sender != Sender.nadia && msg.sender != Sender.system) {
        isTyping[threadId] = true;
        _audioService.playTyping();
        
        int typeTime = msg.delay > 0 ? msg.delay : AppDelays.minTyping;
        await Future.delayed(Duration(milliseconds: typeTime));
        isTyping[threadId] = false;
      } else {
        await Future.delayed(Duration(milliseconds: AppDelays.messageGap));
      }

      // 2. Add Message to UI
      final currentList = subject.value;
      subject.add([...currentList, msg]);
      _audioService.playPing();

      // 3. 🛠️ Robust Metadata Check for Gallery Unlocks
      final meta = msg.metadata;
      if (meta != null && meta['is_secret'] == true) {
        final String? imageUrl = meta['image_url'];
        if (imageUrl != null && !unlockedGlobalSecrets.contains(imageUrl)) {
          unlockedGlobalSecrets.add(imageUrl);
          // Trigger a vibration for finding a secret
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
    
    final episodeId = _stateService.currentEpisodeId.value ?? 'episode_1';
    _stateService.updateProgress(episodeId, choice.targetNode);

    // Clear typing states when player responds
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
