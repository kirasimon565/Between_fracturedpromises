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
import 'makelove_bubble.dart';
import 'dart:math' as math;

class MakeloveChatScreen extends StatefulWidget {
  @override
  _MakeloveChatScreenState createState() => _MakeloveChatScreenState();
}

class _MakeloveChatScreenState extends State<MakeloveChatScreen> {
  final String partnerName;
  final StoryEngine _engine = Get.find<StoryEngine>();
  final AudioService _audio = Get.find<AudioService>();
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final AuthService _auth = Get.find<AuthService>();
  final ScrollController _scrollController = ScrollController();

  _MakeloveChatScreenState() : partnerName = Get.arguments ?? 'Unknown';

  @override
  Widget build(BuildContext context) {
    final String threadId = partnerName.toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFF050000),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.redAccent),
          onPressed: () => Get.back(),
        ),
        title: Column(
          children: [
            Text(
              partnerName.toUpperCase(),
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 16, 
                letterSpacing: 5, 
                fontFamily: 'Didot',
                fontWeight: FontWeight.w200
              )
            ),
            const SizedBox(height: 4),
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore.streamCharacter(threadId),
              builder: (context, snapshot) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LivePulseDot(),
                    const SizedBox(width: 6),
                    const Text(
                      "LIVE", 
                      style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2)
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
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
                child: StreamBuilder<List<Message>>(
                  stream: _engine.getMessagesStream(threadId),
                  builder: (context, snapshot) {
                    final messages = snapshot.data ?? [];
                    
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                      }
                    });

                    return Obx(() {
                      final isTyping = _engine.isTyping[threadId] ?? false;

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        itemCount: messages.length + (isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length) {
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
                            isMe: msg.sender == Sender.nadia
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

  Widget _buildMakeloveInput(String threadId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.red.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showRopeChoices(threadId),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 22),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                "Whisper a response...",
                style: TextStyle(color: Colors.white12, fontSize: 13, letterSpacing: 1),
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
    );
  }
}

// 🛠️ ADDED: Missing Rope Overlay class for Makelove
class _MakeloveRopeOverlay extends StatelessWidget {
  final String threadId;
  final StoryEngine _engine = Get.find<StoryEngine>();

  _MakeloveRopeOverlay({required this.threadId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: _engine.getMessagesStream(threadId),
      builder: (context, snapshot) {
        final messages = snapshot.data ?? [];
        if (messages.isEmpty) return const SizedBox.shrink();

        final lastMsg = messages.last;
        final choices = lastMsg.choices ?? [];

        if (choices.isEmpty) {
          return Container(
            height: 100,
            color: Colors.black,
            child: const Center(child: Text("WAITING FOR SIGNAL...", style: TextStyle(color: Colors.red, letterSpacing: 2))),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: choices.map((choice) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
              child: GestureDetector(
                onTap: () {
                  _engine.makeChoice(choice);
                  Get.back();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    choice.text.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, letterSpacing: 2, fontSize: 12),
                  ),
                ),
              ),
            )).toList(),
          ),
        );
      }
    );
  }
}

class _LivePulseDot extends StatefulWidget {
  @override
  __LivePulseDotState createState() => __LivePulseDotState();
}

class __LivePulseDotState extends State<_LivePulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        width: 6, height: 6,
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(_controller.value), blurRadius: 4)],
        ),
      ),
    );
  }
}
