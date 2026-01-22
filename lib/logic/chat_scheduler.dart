import 'dart:async';
import 'package:get/get.dart';
import '../data/playback_store.dart';
import '../data/models/playback_models.dart';
import '../data/models/script_models.dart';
import 'delay_model.dart';
import '../services/audio_service.dart';

class ChatScheduler extends GetxService {
  final PlaybackStore _store = Get.find<PlaybackStore>();
  final AudioService _audioService = Get.find<AudioService>();

  Timer? _tickTimer;
  bool _isDisposed = false;

  // In-memory cache of typing state for UI (threadId -> isTyping)
  final RxMap<String, bool> typingStates = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _startLoop();
  }

  @override
  void onClose() {
    _stopLoop();
    super.onClose();
  }

  void _startLoop() {
    _tickTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _processTick();
    });
  }

  void _stopLoop() {
    _isDisposed = true;
    _tickTimer?.cancel();
  }

  /// Main Heartbeat: Check pending deliveries and move them to visible
  Future<void> _processTick() async {
    if (_isDisposed) return;

    final now = DateTime.now();
    final pendingItems = await _store.getAllPendingDeliveries();

    if (pendingItems.isEmpty) {
      // Clear all typing states if nothing is pending
      if (typingStates.isNotEmpty) typingStates.clear();
      return;
    }

    final Set<String> activeThreads = {};

    for (final item in pendingItems) {
      activeThreads.add(item.threadId);

      // 1. Check if it's time to show "Typing..."
      if (now.isAfter(item.typingStartAt) && now.isBefore(item.deliverAt)) {
        typingStates[item.threadId] = true;
        // Optionally trigger typing sound once per burst
      }
      // 2. Check if it's time to Deliver
      else if (now.isAtSameMomentAs(item.deliverAt) || now.isAfter(item.deliverAt)) {
        await _deliverMessage(item);
        typingStates[item.threadId] = false;
      }
    }

    // Cleanup typing states for threads that finished
    typingStates.removeWhere((key, value) => !activeThreads.contains(key));
  }

  Future<void> _deliverMessage(PendingDelivery item) async {
    // 1. Move to Visible
    final visible = VisibleMessage()
      ..threadId = item.threadId
      ..saveSlotId = item.saveSlotId
      ..origin = 'script'
      ..sender = item.sender
      ..content = item.content
      ..type = item.type
      ..deliveredAt = DateTime.now()
      ..scriptId = item.scriptId;

    // TODO: Copy choices from script if this was the choice-prompting message?
    // For now, we assume scriptId lookup handles choices or we fetch them later.
    // Ideally, we'd look up the ScriptMessage here to get choicesJson.

    await _store.addVisibleMessage(visible);

    // 2. Remove from Pending
    await _store.removePendingDelivery(item.id);

    // 3. Play Sound
    if (item.sender == 'nadia') {
      // outgoing sound?
    } else {
       _audioService.playPing(); // Incoming
    }
  }

  /// Schedule a burst of messages for a thread.
  /// This is called by the Runtime when entering a node.
  Future<void> scheduleBurst(String threadId, List<ScriptMessage> messages) async {
    if (messages.isEmpty) return;

    DateTime simulatedClock = DateTime.now();

    // If there are already pending items, schedule after the last one
    final existing = await _store.getPendingDeliveries(threadId);
    if (existing.isNotEmpty) {
      simulatedClock = existing.last.deliverAt;
    }

    final List<PendingDelivery> newItems = [];

    for (final msg in messages) {
      final delays = DelayModel.computeDelays(
        sender: msg.sender,
        content: msg.content,
        type: msg.type,
        overrideDelay: msg.delay,
      );

      // Gap before typing starts
      simulatedClock = simulatedClock.add(Duration(milliseconds: delays.gap));

      final typingStart = simulatedClock;
      final deliverAt = typingStart.add(Duration(milliseconds: delays.typing));

      // Update clock for next message
      simulatedClock = deliverAt;

      final item = PendingDelivery()
        ..threadId = threadId
        ..saveSlotId = _store.saveSlotId
        ..scriptId = msg.scriptId
        ..sender = msg.sender
        ..content = msg.content
        ..type = msg.type
        ..typingStartAt = typingStart
        ..deliverAt = deliverAt;

      newItems.add(item);
    }

    await _store.addPendingDeliveries(newItems);
  }
}
