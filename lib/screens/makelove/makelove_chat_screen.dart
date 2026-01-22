// lib/screens/makelove/makelove_chat_screen.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../models/message.dart'; // Keeping UI model
import '../../models/choice.dart'; // ✅ Added import for Choice
import '../../services/audio_service.dart';
import '../../widgets/typing_indicator.dart';
import '../../app/constants.dart';
import '../../theme/colors.dart';
import '../../data/playback_store.dart';
import '../../logic/story_runtime.dart';
import '../../logic/chat_scheduler.dart';
import 'makelove_bubble.dart';
import '../profile/character_profile_screen.dart';
import 'dart:convert';
import 'package:isar/isar.dart';

class MakeloveChatScreen extends StatefulWidget {
  @override
  State<MakeloveChatScreen> createState() => _MakeloveChatScreenState();
}

class _MakeloveChatScreenState extends State<MakeloveChatScreen> {
  final StoryRuntime _runtime = Get.find<StoryRuntime>();
  final PlaybackStore _store = Get.find<PlaybackStore>();
  final ChatScheduler _scheduler = Get.find<ChatScheduler>();
  final AudioService _audio = Get.find<AudioService>();
  final ScrollController _scrollController = ScrollController();

  late final String threadId;      // ✅ always lowercase/trim
  late final String partnerName;   // ✅ display name only

  @override
  void initState() {
    super.initState();

    final arg = Get.arguments;
    final raw = (arg is String && arg.trim().isNotEmpty) ? arg.trim() : 'Unknown';

    threadId = raw.toLowerCase().trim();
    partnerName = _toDisplayName(raw);
  }

  String _toDisplayName(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return "UNKNOWN";
    // If raw is already "daniel", show "DANIEL" (your Makelove header style)
    return s.toUpperCase();
  }

  void _navigateToProfile() {
    String bio = "No data.";
    String avatar = AppConstants.avatarDaniel; // Default for Makelove is Daniel

    if (threadId == 'daniel') {
      bio = "A freelance UI/UX designer and part-time digital nomad.\nLives an unrooted life fueled by attention, novelty, and online connections.\nDrawn to secrecy and conquest, mistaking obsession for intimacy.";
      avatar = AppConstants.avatarDaniel;
    } else if (threadId == 'liam') {
      bio = "A product analyst at the same company as Nadia.\nCharming, sociable, and casually flirtatious without long-term intentions.\nSees Nadia as an escape from routine.";
      avatar = AppConstants.avatarLiam;
    }

    Get.to(() => CharacterProfileScreen(
      characterId: threadId,
      name: partnerName,
      bio: bio,
      avatarPath: avatar,
      themeColor: AppColors.makelovePrimary,
    ));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Helper to convert VisibleMessage (Isar) to UI Message Model
  Message _convertToUiMessage(VisibleMessage vm) {
    return Message(
      id: vm.id.toString(),
      sender: vm.sender == 'nadia' ? Sender.nadia : Sender.other,
      content: vm.content,
      type: vm.type == 'image' ? MessageType.image : MessageType.text,
      timestamp: vm.deliveredAt,
      // Choices are handled via the overlay logic querying the script or runtime state
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050000),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Ambient Red Glow
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.red.withOpacity(0.05), Colors.transparent],
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: StreamBuilder<List<VisibleMessage>>(
                  stream: _store.watchMessages(threadId),
                  builder: (context, snapshot) {
                    final visibleMsgs = snapshot.data ?? [];
                    final messages = visibleMsgs.map(_convertToUiMessage).toList();

                    // Auto-scroll
                    if (messages.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(
                            _scrollController.position.maxScrollExtent,
                          );
                        }
                      });
                    }

                    if (messages.isEmpty &&
                        snapshot.connectionState == ConnectionState.active) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Opacity(
                              opacity: 0.1,
                              child: const Icon(Icons.favorite_border,
                                  color: Colors.redAccent, size: 30),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "NO SIGNAL FOUND",
                              style: TextStyle(
                                color: Colors.white10,
                                letterSpacing: 2,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Obx(() {
                      final typing = _scheduler.typingStates[threadId] ?? false;

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        itemCount: messages.length + (typing ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (typing && index == messages.length) {
                            return const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 10, bottom: 20),
                                child: TypingIndicator(color: Colors.redAccent),
                              ),
                            );
                          }

                          final msg = messages[index];
                          return MakeloveBubble(
                            message: msg,
                            isMe: msg.sender == Sender.nadia,
                          );
                        },
                      );
                    });
                  },
                ),
              ),
              _buildMakeloveInput(threadId),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            size: 18, color: Colors.redAccent),
        onPressed: () => Get.back(),
      ),
      title: GestureDetector(
        onTap: _navigateToProfile,
        child: Column(
          children: [
            Text(
              partnerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 5,
                fontFamily: 'Didot',
                fontWeight: FontWeight.w200,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _LivePulseDot(),
                SizedBox(width: 6),
                Text(
                  "LIVE",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMakeloveInput(String threadId) {
    return Container(
      padding: const EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 45),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.red.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showRopeChoices(threadId),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: const Icon(Icons.favorite_rounded,
                  color: Colors.redAccent, size: 22),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Whisper a response...",
                style: TextStyle(
                    color: Colors.white12, fontSize: 13, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRopeChoices(String threadId) {
    _audio.playVibrate();
    Get.bottomSheet(
      _MakeloveRopeOverlay(threadId: threadId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _MakeloveRopeOverlay extends StatelessWidget {
  final String threadId;
  final StoryRuntime _runtime = Get.find<StoryRuntime>();
  final PlaybackStore _store = Get.find<PlaybackStore>();

  _MakeloveRopeOverlay({required this.threadId});

  Future<List<Choice>> _fetchChoices() async {
    // 1. Get last visible message to find scriptId
    final visible = await _store.watchLastMessage(threadId).first;
    if (visible == null) return [];

    // 2. Look up ScriptMessage
    final scriptMsg = await _store.isar.scriptMessages
      .filter()
      .scriptIdEqualTo(visible.scriptId)
      .findFirst();

    if (scriptMsg == null || scriptMsg.choicesJson == null) return [];

    try {
      final List<dynamic> raw = jsonDecode(scriptMsg.choicesJson!);
      return raw.map((e) => Choice(
        id: e['id'] ?? 'unknown',
        text: e['text'] ?? '...',
        targetNodeId: e['targetNodeId'] ?? 'scene_1', // assuming schema
        impact: e['impact'], // map
      )).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Choice>>(
      future: _fetchChoices(),
      builder: (context, snapshot) {
        final choices = snapshot.data ?? [];
        final hasChoices = choices.isNotEmpty;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: const Color(0xFF080000),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 1, height: 50, color: Colors.red.withOpacity(0.3)),
              const SizedBox(height: 12),
              const Text(
                "DESIRE ACCESS",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 10,
                    letterSpacing: 5,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              if (!hasChoices)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text(
                      "Waiting for a heartbeat...",
                      style: TextStyle(
                        color: Colors.white12,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              else
                ...choices.map(
                  (choice) => Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 40),
                    child: GestureDetector(
                      onTap: () {
                        _runtime.handleChoice(threadId, choice.text, choice.targetNodeId);
                        Get.back();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.05),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          choice.text.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            letterSpacing: 2,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LivePulseDot extends StatefulWidget {
  const _LivePulseDot();

  @override
  State<_LivePulseDot> createState() => __LivePulseDotState();
}

class __LivePulseDotState extends State<_LivePulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(_controller.value),
              blurRadius: 4,
            )
          ],
        ),
      ),
    );
  }
}
