import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../models/message.dart';
import '../models/choice.dart';
import 'firestore_service.dart';
import 'state_service.dart';
import '../utils/delays.dart';

class StoryEngine extends GetxService {
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final StateService _stateService = Get.find<StateService>();

  // --- External Outputs (Streams) ---
  final Map<String, BehaviorSubject<List<Message>>> _visibleMessages = {};
  final RxMap<String, bool> isTyping = <String, bool>{}.obs;

  // New: Active Threads Stream for List Screens
  RxList<String> activeThreadIds = <String>[].obs;

  // --- Compatibility Getters (Fixes UI Errors) ---
  // These allow the MessengerListScreen and MakeloveListScreen to work
  Rx<String?> get currentEpisode => _stateService.currentEpisodeId;
  List<dynamic> get activeThreads => activeThreadIds.map((id) => _ThreadWrapper(id)).toList();

  // --- Internal State ---
  final Map<String, StreamSubscription> _subscriptions = {};
  final Map<String, List<Message>> _incomingBuffers = {};
  final Map<String, bool> _isProcessingQueue = {};
  final Map<String, QuerySnapshot> _lastSnapshots = {};

  StreamSubscription? _threadsSubscription;

  @override
  void onInit() {
    super.onInit();
    // Listen to scene changes to re-evaluate visible messages
    ever(_stateService.currentSceneId, (_) => _recheckAllThreads());

    // Listen to Episode changes to discover threads
    ever(_stateService.currentEpisodeId, (episodeId) {
      if (episodeId != null) _startDiscoveringThreads(episodeId);
    });

    // Initial start
    if (_stateService.currentEpisodeId.value != null) {
      _startDiscoveringThreads(_stateService.currentEpisodeId.value!);
    }
  }

  // --- Compatibility Methods (Fixes UI Errors) ---
  void loadEpisode(String episodeId) {
    _stateService.currentEpisodeId.value = episodeId;
  }

  Stream<List<Message>> getMessagesForThread(String threadId) {
    return getMessagesStream(threadId);
  }

  // --- Core Logic ---

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

  // Helper to get the last message for a thread (for List preview)
  Stream<Message?> getLastMessageStream(String threadId) {
     return getMessagesStream(threadId).map((list) => list.isNotEmpty ? list.last : null);
  }

  Stream<List<Message>> getMessagesStream(String threadId) {
    if (!_visibleMessages.containsKey(threadId)) {
      _visibleMessages[threadId] = BehaviorSubject<List<Message>>.seeded([]);
      _startListeningToThread(threadId);
    }
    return _visibleMessages[threadId]!.stream;
  }

  void _startListeningToThread(String threadId) {
    if (_subscriptions.containsKey(threadId)) return;

    String? episodeId = _stateService.currentEpisodeId.value;
    if (episodeId == null) return;

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

    String currentSceneId = _stateService.currentSceneId.value;

    final subject = _visibleMessages[threadId];
    if (subject == null) return;

    final currentVisible = subject.value;

    // Filter messages for current scene and sort by order
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

      // Trigger "Typing" animation for characters
      if (msg.sender != Sender.nadia && msg.sender != Sender.system) {
        isTyping[threadId] = true;
        int typeTime = msg.delay > 0 ? msg.delay : AppDelays.minTyping;
        await Future.delayed(Duration(milliseconds: typeTime));
        isTyping[threadId] = false;
      } else {
        await Future.delayed(Duration(milliseconds: AppDelays.messageGap));
      }

      // Add to visible stream - this triggers the Digital Dust in the UI
      final currentList = subject.value;
      subject.add([...currentList, msg]);
    }

    _isProcessingQueue[threadId] = false;
  }

  void makeChoice(Choice choice) {
    if (choice.impact != null) {
      choice.impact!.forEach((key, value) {
        _stateService.setVariable(key, value);
      });
    }

    _stateService.recordChoice(choice.targetNode);
    _stateService.updateProgress(_stateService.currentEpisodeId.value!, choice.targetNode);

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

// Simple wrapper to help the UI list screens find the thread ID
class _ThreadWrapper {
  final String id;
  _ThreadWrapper(this.id);
}
