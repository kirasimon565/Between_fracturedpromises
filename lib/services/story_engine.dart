// lib/services/story_engine.dart

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

  // ✅ Categorized lists for UI
  final RxList<String> messengerThreads = <String>[].obs;
  final RxList<String> makeloveThreads = <String>[].obs;

  // ✅ Raw thread ids discovered from Firestore
  final RxList<String> activeThreadIds = <String>[].obs;

  // ✅ NEW: threads that should remain visible once discovered / used
  final RxSet<String> unlockedThreads = <String>{}.obs;

  Rx<String?> get currentEpisode => _stateService.currentEpisodeId;

  final Map<String, StreamSubscription> _subscriptions = {};
  final Map<String, List<Message>> _incomingBuffers = {};
  final Map<String, bool> _isProcessingQueue = {};
  final Map<String, QuerySnapshot> _lastSnapshots = {};

  // ✅ Thread metadata (app, etc.)
  final Map<String, Map<String, dynamic>> _threadMeta = {};

  StreamSubscription? _threadsSubscription;

  String _sid(String id) => id.toLowerCase().trim();

  String _appForThread(String threadId) {
    final sid = _sid(threadId);

    final metaApp = _threadMeta[sid]?['app'];
    if (metaApp != null) return metaApp.toString().toLowerCase();

    // Fallback for older data
    if (sid == 'daniel') return 'makelove';
    return 'messenger';
  }

  @override
  void onInit() {
    super.onInit();

    ever(_stateService.currentSceneId, (sceneId) {
      // ignore: avoid_print
      print("ENGINE DEBUG: Scene transition to: $sceneId");
      // ✅ Do NOT hide threads just because a scene changed
      _updateThreadLists();
      _recheckAllThreads();
    });

    ever(_stateService.currentEpisodeId, (episodeId) {
      if (episodeId != null) _startDiscoveringThreads(episodeId);
    });

    final initialEpisode =
        _stateService.currentEpisodeId.value ?? 'ep1_the_spark';
    _startDiscoveringThreads(initialEpisode);
  }

  String? getMetadata(String key) {
    return _stateService.variables[key]?.toString();
  }

  /// ✅ NEW: Build thread lists from unlockedThreads + metadata (NOT scene)
  void _updateThreadLists() {
    messengerThreads.clear();
    makeloveThreads.clear();

    for (final rawId in activeThreadIds) {
      final id = _sid(rawId);
      if (id == 'system') continue;

      // Only show threads that are unlocked (seen/used) OR already have messages loaded
      final bool hasLoadedMessages = (_lastSnapshots[id]?.docs.isNotEmpty ?? false);
      final bool shouldShow = unlockedThreads.contains(id) || hasLoadedMessages;

      if (!shouldShow) continue;

      final app = _appForThread(id);
      if (app == 'makelove') {
        if (!makeloveThreads.contains(id)) makeloveThreads.add(id);
      } else {
        if (!messengerThreads.contains(id)) messengerThreads.add(id);
      }
    }

    // Safety rule: Daniel never appears in Messenger
    messengerThreads.removeWhere((id) => _sid(id) == 'daniel');
  }

  bool hasCompletedThread(String threadId) {
    return activeThreadIds.contains(_sid(threadId));
  }

  void loadEpisode(String episodeId) {
    _stateService.currentEpisodeId.value = episodeId;
  }

  void _startDiscoveringThreads(String episodeId) {
    // ignore: avoid_print
    print("ENGINE DEBUG: Discovering threads for: $episodeId");

    _threadsSubscription?.cancel();
    _threadMeta.clear();
    activeThreadIds.clear();
    messengerThreads.clear();
    makeloveThreads.clear();
    unlockedThreads.clear();

    // ✅ Uses streamThreads() (thread docs contain `app`)
    _threadsSubscription = _firestore.streamThreads(episodeId).listen((snapshot) {
      final ids = <String>[];

      for (final doc in snapshot.docs) {
        final id = _sid(doc.id);
        ids.add(id);

        final data = (doc.data() as Map<String, dynamic>?) ?? {};
        _threadMeta[id] = data;

        _visibleMessages.putIfAbsent(
          id,
          () => rx.BehaviorSubject<List<Message>>.seeded([]),
        );

        _startListeningToThread(id);
      }

      activeThreadIds.assignAll(ids);

      // ✅ Rebuild lists based on unlockedThreads (initially empty until messages arrive)
      _updateThreadLists();
    });
  }

  void _recheckAllThreads() {
    _lastSnapshots.forEach((threadId, snapshot) {
      _handleFirestoreUpdate(threadId, snapshot);
    });
  }

  Stream<Message?> getLastMessageStream(String threadId) {
    return getMessagesStream(threadId)
        .map((list) => list.isNotEmpty ? list.last : null);
  }

  Stream<List<Message>> getMessagesStream(String threadId) {
    final id = _sid(threadId);

    if (!_visibleMessages.containsKey(id)) {
      _visibleMessages[id] = rx.BehaviorSubject<List<Message>>.seeded([]);
      _startListeningToThread(id);
    }
    return _visibleMessages[id]!.stream;
  }

  void _startListeningToThread(String threadId) {
    final id = _sid(threadId);

    _visibleMessages.putIfAbsent(
      id,
      () => rx.BehaviorSubject<List<Message>>.seeded([]),
    );

    if (_subscriptions.containsKey(id)) return;

    final episodeId = _stateService.currentEpisodeId.value ?? 'ep1_the_spark';
    _subscriptions[id] =
        _firestore.streamMessages(episodeId, id).listen((snapshot) {
      _handleFirestoreUpdate(id, snapshot);
    });
  }

  void _handleFirestoreUpdate(String threadId, QuerySnapshot snapshot) {
    final id = _sid(threadId);
    _lastSnapshots[id] = snapshot;

    final List<Message> allMessages = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Message.fromJson(data);
    }).toList();

    // ✅ Unlock thread when it has any messages at all
    if (allMessages.isNotEmpty) {
      unlockedThreads.add(id);
    }

    final subject = _visibleMessages[id];
    if (subject == null) return;

    final currentVisible = subject.value;
    final currentSceneId = _stateService.currentSceneId.value ?? 'scene_1';

    // ✅ Chat screen filter: still show scene-relevant messages
    final relevantMessages = allMessages.where((m) {
      return m.sceneId == currentSceneId ||
          m.sceneId == null ||
          m.sender == Sender.nadia;
    }).toList();

    relevantMessages.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final visibleIds = currentVisible.map((m) => m.id).toSet();
    final newMessages =
        relevantMessages.where((m) => !visibleIds.contains(m.id)).toList();

    if (newMessages.isNotEmpty) {
      // ignore: avoid_print
      print("ENGINE DEBUG: Pushing ${newMessages.length} messages to $id");
      _incomingBuffers.putIfAbsent(id, () => []);
      _incomingBuffers[id]!.addAll(newMessages);
      _processQueue(id);
    }

    // ✅ Update lists AFTER unlock changes
    _updateThreadLists();
  }

  void _processQueue(String threadId) async {
    final id = _sid(threadId);

    if (_isProcessingQueue[id] == true) return;
    _isProcessingQueue[id] = true;

    final subject = _visibleMessages[id];
    if (subject == null) {
      _isProcessingQueue[id] = false;
      return;
    }

    while (_incomingBuffers[id]?.isNotEmpty ?? false) {
      final msg = _incomingBuffers[id]!.removeAt(0);

      if (msg.sender != Sender.nadia && msg.sender != Sender.system) {
        isTyping[id] = true;
        _audioService.playTyping();
        final int typeTime = msg.delay > 0 ? msg.delay : AppDelays.minTyping;
        await Future.delayed(Duration(milliseconds: typeTime));
        isTyping[id] = false;
      } else {
        await Future.delayed(Duration(milliseconds: AppDelays.messageGap));
      }

      final currentList = subject.value;
      subject.add([...currentList, msg]);
      _audioService.playPing();
    }

    _isProcessingQueue[id] = false;
  }

  /// ✅ NEW: makeChoice must know WHICH thread we are in,
  /// so it can inject Nadia's choice text into that chat.
  void makeChoice(String threadId, Choice choice) {
    final id = _sid(threadId);

    // ✅ 1) Inject choice as Nadia message so it appears instantly
    _injectChoiceMessage(id, choice.text);

    // ✅ 2) Apply state impacts
    if (choice.impact != null) {
      choice.impact!.forEach((key, value) {
        _stateService.setVariable(key, value);
      });
    }

    _audioService.playVibrate();

    // ✅ 3) Record + progress
    _stateService.recordChoice(choice.targetNode);

    final episodeId = _stateService.currentEpisodeId.value ?? 'ep1_the_spark';
    _stateService.updateProgress(episodeId, choice.targetNode);

    // ✅ 4) Ensure this thread stays visible forever once used
    unlockedThreads.add(id);
    _updateThreadLists();

    // Optional: clear typing only for this thread
    isTyping[id] = false;
  }

  void _injectChoiceMessage(String threadId, String text) {
    final id = _sid(threadId);

    final subject = _visibleMessages[id];
    if (subject == null) return;

    final currentList = subject.value;
    final int nextOrder = currentList.isNotEmpty
        ? (currentList.last.orderIndex + 1)
        : 0;

    final currentSceneId = _stateService.currentSceneId.value ?? 'scene_1';

    final localMsg = Message(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      sender: Sender.nadia,
      recipient: id,
      content: text,
      type: MessageType.text,
      delay: 0,
      orderIndex: nextOrder,
      sceneId: currentSceneId,
      choices: null,
      metadata: const {'local': true, 'kind': 'choice'},
    );

    subject.add([...currentList, localMsg]);
    _audioService.playPing();
  }

  @override
  void onClose() {
    _threadsSubscription?.cancel();
    for (final s in _subscriptions.values) {
      s.cancel();
    }
    for (final subject in _visibleMessages.values) {
      subject.close();
    }
    super.onClose();
  }
}
