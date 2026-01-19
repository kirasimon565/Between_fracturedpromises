import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart' as rx; 
import '../models/message.dart';
import '../models/choice.dart';
import 'firestore_service.dart';
import 'state_service.dart';
import 'audio_service.dart'; // 🔊 Added for Noir sounds
import '../utils/delays.dart';

class StoryEngine extends GetxService {
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final StateService _stateService = Get.find<StateService>();
  final AudioService _audioService = Get.find<AudioService>(); // 🔊 Found service

  final Map<String, rx.BehaviorSubject<List<Message>>> _visibleMessages = {};
  final RxMap<String, bool> isTyping = <String, bool>{}.obs;

  RxList<String> activeThreadIds = <String>[].obs;

  Rx<String?> get currentEpisode => _stateService.currentEpisodeId;
  List<dynamic> get activeThreads => activeThreadIds.map((id) => _ThreadWrapper(id)).toList();

  final Map<String, StreamSubscription> _subscriptions = {};
  final Map<String, List<Message>> _incomingBuffers = {};
  final Map<String, bool> _isProcessingQueue = {};
  final Map<String, QuerySnapshot> _lastSnapshots = {};

  StreamSubscription? _threadsSubscription;

  @override
  void onInit() {
    super.onInit();
    ever(_stateService.currentSceneId, (_) => _recheckAllThreads());

    ever(_stateService.currentEpisodeId, (episodeId) {
      if (episodeId != null) _startDiscoveringThreads(episodeId);
    });

    // 🛠️ FIX: Null safety for starting threads
    final initialEpisode = _stateService.currentEpisodeId.value ?? 'episode_1';
    _startDiscoveringThreads(initialEpisode);
  }

  void loadEpisode(String episodeId) {
    _stateService.currentEpisodeId.value = episodeId;
  }

  Stream<List<Message>> getMessagesForThread(String threadId) {
    return getMessagesStream(threadId);
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

    // 🛠️ FIX: Default to episode_1 if state is null
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

    // 🛠️ FIX: Resolve the "String?" to "String" build error
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

      // Handle typing simulation
      if (msg.sender != Sender.nadia && msg.sender != Sender.system) {
        isTyping[threadId] = true;
        // 🔊 Audio Trigger: Start typing sound
        _audioService.playTyping();
        
        int typeTime = msg.delay > 0 ? msg.delay : AppDelays.minTyping;
        await Future.delayed(Duration(milliseconds: typeTime));
        isTyping[threadId] = false;
      } else {
        await Future.delayed(Duration(milliseconds: AppDelays.messageGap));
      }

      final currentList = subject.value;
      subject.add([...currentList, msg]);
      
      // 🔊 Audio Trigger: Notification ping on message arrival
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

    // 🔊 Audio Trigger: Optional feedback sound for making a choice
    _audioService.playVibrate();

    _stateService.recordChoice(choice.targetNode);
    
    // 🛠️ FIX: Null safety for updating progress
    final episodeId = _stateService.currentEpisodeId.value ?? 'episode_1';
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

class _ThreadWrapper {
  final String id;
  _ThreadWrapper(this.id);
}
