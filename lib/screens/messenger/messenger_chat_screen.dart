// lib/screens/messenger/messenger_chat_screen.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../models/message.dart';
import '../../services/story_engine.dart';
import '../../services/firestore_service.dart';
import '../../services/audio_service.dart';
import '../../widgets/typing_indicator.dart';
import '../../app/constants.dart';
import 'messenger_bubble.dart';
import 'dart:math' as math;

class MessengerChatScreen extends StatefulWidget {
  @override
  State<MessengerChatScreen> createState() => _MessengerChatScreenState();
}

class _MessengerChatScreenState extends State<MessengerChatScreen> {
  final StoryEngine _engine = Get.find<StoryEngine>();
  final AudioService _audio = Get.find<AudioService>();
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final ScrollController _scrollController = ScrollController();

  late final String threadId;     // ✅ lowercase/trim for engine + firestore
  late final String partnerName;  // ✅ display name only

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
    if (s.isEmpty) return "Unknown";
    // Messenger display style: "Ethan"
    final lower = s.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _engine.getMessagesStream(threadId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];

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
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.blur_on, color: Colors.white10, size: 30),
                        SizedBox(height: 10),
                        Text(
                          "NO SIGNAL FOUND",
                          style: TextStyle(
                              color: Colors.white10,
                              letterSpacing: 2,
                              fontSize: 10),
                        ),
                      ],
                    ),
                  );
                }

                return Obx(() {
                  final typing = _engine.isTyping[threadId] ?? false;

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 20),
                    itemCount: messages.length + (typing ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (typing && index == messages.length) {
                        return const _CloudTypingIndicator();
                      }
                      final msg = messages[index];
                      return MessengerBubble(
                        message: msg,
                        isMe: msg.sender == Sender.nadia,
                      );
                    },
                  );
                });
              },
            ),
          ),
          _buildChatInput(threadId),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.9),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            size: 18, color: Colors.white70),
        onPressed: () => Get.back(),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            partnerName.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 4,
              fontWeight: FontWeight.w200,
              fontFamily: 'Didot',
            ),
          ),
          const SizedBox(height: 4),
          _buildOnlineStatus(),
        ],
      ),
    );
  }

  Widget _buildOnlineStatus() {
    return StreamBuilder(
      stream: _firestore.streamCharacter(threadId),
      builder: (context, snapshot) {
        bool isOnline = true;
        if (snapshot.hasData) {
          final doc = snapshot.data;
          // doc might be a DocumentSnapshot; keep your original logic if your service returns typed snapshots
          if (doc is dynamic && doc.exists == true) {
            final data = doc.data() as Map<String, dynamic>?;
            isOnline = data?['is_online'] ?? true;
          }
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: isOnline ? Colors.greenAccent : Colors.white24,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              isOnline ? "online" : "offline",
              style: TextStyle(
                fontSize: 8,
                color: isOnline
                    ? Colors.greenAccent.withOpacity(0.5)
                    : Colors.white24,
                letterSpacing: 1,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChatInput(String threadId) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showChoiceRope(threadId),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(Icons.history_edu_rounded,
                  color: Colors.white70, size: 24),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                "Awaiting signal...",
                style: TextStyle(
                    color: Colors.white24, fontSize: 12, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChoiceRope(String threadId) {
    _audio.playVibrate();
    Get.bottomSheet(
      _RopeChoiceOverlay(threadId: threadId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _RopeChoiceOverlay extends StatelessWidget {
  final String threadId;
  final StoryEngine _engine = Get.find<StoryEngine>();

  _RopeChoiceOverlay({required this.threadId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: _engine.getMessagesStream(threadId),
      builder: (context, snapshot) {
        final messages = snapshot.data ?? [];
        final lastMsg = messages.isNotEmpty ? messages.last : null;

        final bool hasChoices = lastMsg != null &&
            (lastMsg.choices?.isNotEmpty ?? false) &&
            lastMsg.sender != Sender.nadia;

        return Container(
          padding: const EdgeInsets.only(top: 20, bottom: 60),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 1, height: 50, color: Colors.white12),
              const SizedBox(height: 15),
              const Text(
                "FRACTURED PROMISES",
                style: TextStyle(
                    color: Colors.white24,
                    fontSize: 9,
                    letterSpacing: 6,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              if (!hasChoices)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text(
                      "The connection is silent...",
                      style: TextStyle(
                          color: Colors.white12,
                          fontSize: 13,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                )
              else
                ...lastMsg!.choices!.map(
                  (choice) => _SwayingChoice(
                    text: choice.text,
                    onTap: () {
                      _engine.makeChoice(choice);
                      Get.back();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SwayingChoice extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const _SwayingChoice({required this.text, required this.onTap});

  @override
  State<_SwayingChoice> createState() => _SwayingChoiceState();
}

class _SwayingChoiceState extends State<_SwayingChoice>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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
      builder: (context, child) {
        return Transform.rotate(
          angle: math.sin(_controller.value * 2 * math.pi) * 0.015,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Text(
            widget.text.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _CloudTypingIndicator extends StatelessWidget {
  const _CloudTypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(5),
          ),
        ),
        child: const TypingIndicator(color: Colors.white38),
      ),
    );
  }
}
