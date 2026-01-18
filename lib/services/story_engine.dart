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

  // --- Internal State ---
  final Map<String, StreamSubscription> _subscriptions = {};
  final Map<String, List<Message>> _incomingBuffers = {};
  final Map<String, bool> _isProcessingQueue = {};

  // Cache the last snapshot to re-process on scene change
  final Map<String, QuerySnapshot> _lastSnapshots = {};

  @override
  void onInit() {
    super.onInit();
    // Listen to scene changes to re-evaluate visible messages
    ever(_stateService.currentSceneId, (_) => _recheckAllThreads());
  }

  void _recheckAllThreads() {
    // If the scene changes, we need to check if we have buffered messages for the NEW scene
    // in our _lastSnapshots.
    _lastSnapshots.forEach((threadId, snapshot) {
      _handleFirestoreUpdate(threadId, snapshot);
    });
  }

  // --- Public API ---

  Stream<List<Message>> getMessagesStream(String threadId) {
    if (!_visibleMessages.containsKey(threadId)) {
      _visibleMessages[threadId] = BehaviorSubject<List<Message>>.seeded([]);
      _startListeningToThread(threadId);
    }
    return _visibleMessages[threadId]!.stream;
  }

  void _startListeningToThread(String threadId) {
    if (_subscriptions.containsKey(threadId)) return;

    String episodeId = _stateService.currentEpisodeId.value;

    _subscriptions[threadId] = _firestore.streamMessages(episodeId, threadId).listen((snapshot) {
      _handleFirestoreUpdate(threadId, snapshot);
    });
  }

  // --- Logic ---

  void _handleFirestoreUpdate(String threadId, QuerySnapshot snapshot) {
    _lastSnapshots[threadId] = snapshot; // Cache for reactivity

    // 1. Parse all messages
    List<Message> allMessages = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Message.fromJson(data);
    }).toList();

    String currentSceneId = _stateService.currentSceneId.value;

    // 2. Identify New Messages for the CURRENT SCENE
    final currentVisible = _visibleMessages[threadId]?.value ?? [];

    // We only want messages that match the current scene ID.
    // Note: Past messages from previous scenes remain in `currentVisible` (history).
    // We append new ones.

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

    while (_incomingBuffers[threadId]?.isNotEmpty ?? false) {
      final msg = _incomingBuffers[threadId]!.removeAt(0);

      // 1. Typing Indicator
      if (msg.sender != Sender.nadia && msg.sender != Sender.system) {
        isTyping[threadId] = true;
        int typeTime = msg.delay > 0 ? msg.delay : AppDelays.minTyping;
        await Future.delayed(Duration(milliseconds: typeTime));
        isTyping[threadId] = false;
      } else {
        await Future.delayed(Duration(milliseconds: AppDelays.messageGap));
      }

      // 2. Add to Visible
      final currentList = _visibleMessages[threadId]?.value ?? [];
      _visibleMessages[threadId]?.add([...currentList, msg]);
    }

    _isProcessingQueue[threadId] = false;
  }

  // Handle Choice Selection
  void makeChoice(Choice choice) {
    if (choice.impact != null) {
      choice.impact!.forEach((key, value) {
        _stateService.setVariable(key, value);
      });
    }

    _stateService.recordChoice(choice.targetNode);
    _stateService.updateProgress(_stateService.currentEpisodeId.value, choice.targetNode);

    isTyping.clear();
    // The `ever` listener on currentSceneId will trigger _recheckAllThreads automatically.
  }
}
