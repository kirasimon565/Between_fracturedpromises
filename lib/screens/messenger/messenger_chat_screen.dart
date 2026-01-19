import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/constants.dart';
import '../../models/message.dart';
import '../../services/story_engine.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../services/audio_service.dart';
import '../../widgets/typing_indicator.dart';
import '../../theme/colors.dart';
import 'messenger_bubble.dart';
import 'dart:math' as math;

class MessengerChatScreen extends StatefulWidget {
  @override
  _MessengerChatScreenState createState() => _MessengerChatScreenState();
}

class _MessengerChatScreenState extends State<MessengerChatScreen> {
  final String partnerName;
  final StoryEngine _engine = Get.find<StoryEngine>();
  final AudioService _audio = Get.find<AudioService>();
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final AuthService _auth = Get.find<AuthService>();
  final ScrollController _scrollController = ScrollController();

  _MessengerChatScreenState() : partnerName = Get.arguments ?? 'Unknown';

  @override
  Widget build(BuildContext context) {
    final String threadId = partnerName.toLowerCase();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white70),
          onPressed: () => Get.back(),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              partnerName.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 4,
                fontWeight: FontWeight.w200,
                fontFamily: 'Didot',
              ),
            ),
            const SizedBox(height: 4),
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore.streamCharacter(threadId),
              builder: (context, snapshot) {
                bool isOnline = true;
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  isOnline = data?['is_online'] ?? true;
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.greenAccent : Colors.white24,
                        shape: BoxShape.circle,
                        boxShadow: isOnline ? [const BoxShadow(color: Colors.greenAccent, blurRadius: 4)] : [],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? "online" : "offline",
                      style: TextStyle(
                        fontSize: 9,
                        color: isOnline ? Colors.greenAccent.withOpacity(0.7) : Colors.white24,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _engine.getMessagesStream(threadId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                // Auto-scroll to bottom on new messages
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return Obx(() {
                  final isTyping = _engine.isTyping[threadId] ?? false;
                  
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    itemCount: messages.length + (isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        return const _CloudTypingIndicator();
                      }
                      final msg = messages[index];
                      return MessengerBubble(
                        message: msg, 
                        isMe: msg.sender == Sender.nadia
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

  Widget _buildChatInput(String threadId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showChoiceRope(threadId),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
              child: const Icon(Icons.history_edu_rounded, color: Colors.white70, size: 22),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Text(
                "Tap feather to respond...",
                style: TextStyle(color: Colors.white24, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChoiceRope(String threadId) {
    _audio.playVibrate(); // Tactile feedback for choices
    Get.bottomSheet(
      _RopeChoiceOverlay(threadId: threadId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// --- SUPPORTING WIDGETS ---

class _CloudTypingIndicator extends StatelessWidget {
  const _CloudTypingIndicator();
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const TypingIndicator(color: Colors.white38),
      ),
    );
  }
}

class _RopeChoiceOverlay extends StatelessWidget {
  final String threadId;
  final StoryEngine _engine = Get.find<StoryEngine>();

  _RopeChoiceOverlay({required this.threadId});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final messages = _engine.getMessagesStream(threadId).val ?? [];
      if (messages.isEmpty) return const SizedBox.shrink();
      
      final lastMsg = messages.last;
      final hasChoices = (lastMsg.choices?.isNotEmpty ?? false) && lastMsg.sender != Sender.nadia;

      return Container(
        padding: const EdgeInsets.only(top: 20, bottom: 40),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 1, height: 30, color: Colors.white24), // The "Rope"
            const SizedBox(height: 10),
            const Text("CHOOSE YOUR PATH", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 4)),
            const SizedBox(height: 30),
            if (!hasChoices)
              const Center(child: Text("Waiting for response...", style: TextStyle(color: Colors.white24)))
            else
              ...lastMsg.choices!.map((choice) => _SwayingChoice(
                text: choice.text,
                onTap: () {
                  _engine.makeChoice(choice);
                  Get.back();
                },
              )).toList(),
          ],
        ),
      );
    });
  }
}

class _SwayingChoice extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const _SwayingChoice({required this.text, required this.onTap});

  @override
  State<_SwayingChoice> createState() => _SwayingChoiceState();
}

class _SwayingChoiceState extends State<_SwayingChoice> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
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
          angle: math.sin(_controller.value * math.pi) * 0.03, // Subtle swaying
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w300),
          ),
        ),
      ),
    );
  }
}
