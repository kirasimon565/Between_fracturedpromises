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

  // Categorized lists to solve the "Daniel in both apps" problem
  RxList<String> messengerThreads = <String>[].obs;
  RxList<String> makeloveThreads = <String>[].obs;

  // Keep the raw list for internal logic
  RxList<String> activeThreadIds = <String>[].obs;

  Rx<String?> get currentEpisode => _stateService.currentEpisodeId;

  final Map<String, StreamSubscription> _subscriptions = {};
  final Map<String, List<Message>> _incomingBuffers = {};
  final Map<String, bool> _isProcessingQueue = {};
  final Map<String, QuerySnapshot> _lastSnapshots = {};

  // ✅ NEW: store thread-level metadata from /episodes/{ep}/threads
  final Map<String, Map<String, dynamic>> _threadMeta = {};

  StreamSubscription? _threadsSubscription;

  @override
  void onInit() {
    super.onInit();

    ever(_stateService.currentSceneId, (sceneId) {
      // ignore: avoid_print
      print("ENGINE DEBUG: Scene transition to: $sceneId");
      _updateActiveThreads();
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

  // ✅ Helper: always sanitize thread ids the same way everywhere
  String _sid(String id) => id.toLowerCase().trim();

  // ✅ Helper: reads app from thread doc metadata first; falls back safely
  String _appForThread(String threadId) {
    final sid = _sid(threadId);

    final metaApp = _threadMeta[sid]?['app'];
    if (metaApp != null) return metaApp.toString().toLowerCase();

    // Fallback (older episodes without thread.app):
    // hard rule for Daniel + default for others
    if (sid == 'daniel') return 'makelove';
    return 'messenger';
  }

  void _updateActiveThreads() {
    messengerThreads.clear();
    makeloveThreads.clear();

    final String currentScene = _stateService.currentSceneId.value ?? 'scene_1';

    _lastSnapshots.forEach((threadId, snapshot) {
      final docs = snapshot.docs;
      if (docs.isEmpty) return;

      final sid = _sid(threadId);

      // Check if character has messages in this scene (or global)
      final bool hasMessagesInCurrentScene = docs.any((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['sceneId'] == currentScene || data['sceneId'] == null;
      });

      if (!hasMessagesInCurrentScene) return;

      if (!activeThreadIds.contains(sid)) activeThreadIds.add(sid);

      // ✅ Use thread-level app metadata (no more guessing from first message)
      final app = _appForThread(sid);

      if (app == 'makelove') {
        if (!makeloveThreads.contains(sid)) makeloveThreads.add(sid);
      } else {
        if (!messengerThreads.contains(sid)) messengerThreads.add(sid);
      }
    });

    // ✅ Safety net: never allow Daniel to appear in Messenger list
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

    // ✅ Pull thread metadata too (including app)
    _threadsSubscription = _firestore
        .streamThreads(episodeId)
        .listen((QuerySnapshot snapshot) {
      final ids = <String>[];

      for (final doc in snapshot.docs) {
        final sid = _sid(doc.id);
        ids.add(sid);

        // Save metadata (app, etc.)
        final data = (doc.data() as Map<String, dynamic>?) ?? {};
        _threadMeta[sid] = data;

        // Ensure subject exists so updates aren't dropped
        _visibleMessages.putIfAbsent(
          sid,
          () => rx.BehaviorSubject<List<Message>>.seeded([]),
        );

        _startListeningToThread(sid);
      }

      activeThreadIds.assignAll(ids);

      // Rebuild categorized lists based on updated metadata
      _updateActiveThreads();
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
    final sanitizedId = _sid(threadId);

    if (!_visibleMessages.containsKey(sanitizedId)) {
      _visibleMessages[sanitizedId] =
          rx.BehaviorSubject<List<Message>>.seeded([]);
      _startListeningToThread(sanitizedId);
    }
    return _visibleMessages[sanitizedId]!.stream;
  }

  void _startListeningToThread(String threadId) {
    final sanitizedId = _sid(threadId);

    // ✅ Ensure subject exists so Firestore updates are not dropped
    _visibleMessages.putIfAbsent(
      sanitizedId,
      () => rx.BehaviorSubject<List<Message>>.seeded([]),
    );

    if (_subscriptions.containsKey(sanitizedId)) return;

    final String episodeId = _stateService.currentEpisodeId.value ?? 'ep1_the_spark';
    _subscriptions[sanitizedId] =
        _firestore.streamMessages(episodeId, sanitizedId).listen((snapshot) {
      _handleFirestoreUpdate(sanitizedId, snapshot);
    });
  }

  void _handleFirestoreUpdate(String threadId, QuerySnapshot snapshot) {
    final sid = _sid(threadId);
    _lastSnapshots[sid] = snapshot;

    final List<Message> allMessages = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Message.fromJson(data);
    }).toList();

    final String currentSceneId = _stateService.currentSceneId.value ?? 'scene_1';

    // Rebuild categorized lists
    _updateActiveThreads();

    final subject = _visibleMessages[sid];
    if (subject == null) return;

    final currentVisible = subject.value;

    // Show relevant messages even if sceneId is slightly wrong
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
      print("ENGINE DEBUG: Pushing ${newMessages.length} messages to $sid");
      _incomingBuffers.putIfAbsent(sid, () => []);
      _incomingBuffers[sid]!.addAll(newMessages);
      _processQueue(sid);
    }
  }

  void _processQueue(String threadId) async {
    final sid = _sid(threadId);

    if (_isProcessingQueue[sid] == true) return;
    _isProcessingQueue[sid] = true;

    final subject = _visibleMessages[sid];
    if (subject == null) {
      _isProcessingQueue[sid] = false;
      return;
    }

    while (_incomingBuffers[sid]?.isNotEmpty ?? false) {
      final msg = _incomingBuffers[sid]!.removeAt(0);

      if (msg.sender != Sender.nadia && msg.sender != Sender.system) {
        isTyping[sid] = true;
        _audioService.playTyping();
        final int typeTime = msg.delay > 0 ? msg.delay : AppDelays.minTyping;
        await Future.delayed(Duration(milliseconds: typeTime));
        isTyping[sid] = false;
      } else {
        await Future.delayed(Duration(milliseconds: AppDelays.messageGap));
      }

      final currentList = subject.value;
      subject.add([...currentList, msg]);
      _audioService.playPing();
    }

    _isProcessingQueue[sid] = false;
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
    for (final s in _subscriptions.values) {
      s.cancel();
    }
    for (final subject in _visibleMessages.values) {
      subject.close();
    }
    super.onClose();
  }
}
