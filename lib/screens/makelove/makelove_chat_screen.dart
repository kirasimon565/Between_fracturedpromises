import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/constants.dart';
import '../../models/message.dart';
import '../../models/choice.dart'; 
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
  final ScrollController _scrollController = ScrollController();

  // 🛠️ Sanitized threadId for reliable Firestore pathing
  late final String threadId;

  _MakeloveChatScreenState() : partnerName = Get.arguments ?? 'Unknown' {
    // 🛠️ Force lowercase and trim to ensure "Daniel" matches "daniel" in DB exactly
    threadId = partnerName.toLowerCase().trim();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050000), // Crimson-black noir base
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
                child: StreamBuilder<List<Message>>(
                  stream: _engine.getMessagesStream(threadId),
                  builder: (context, snapshot) {
                    final messages = snapshot.data ?? [];
                    
                    // Auto-scroll logic for mobile devices
                    if (messages.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                        }
                      });
                    }

                    if (messages.isEmpty && snapshot.connectionState == ConnectionState.active) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_border, color: Colors.redAccent, size: 30, opacity: 0.1),
                            SizedBox(height: 10),
                            Text("NO SIGNAL FOUND", 
                              style: TextStyle(color: Colors.white10, letterSpacing: 2, fontSize: 10)
                            ),
                          ],
                        ),
                      );
                    }

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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LivePulseDot(),
              const SizedBox(width: 6),
              const Text(
                "LIVE", 
                style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2)
              ),
            ],
          ),
        ],
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
              child: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 22),
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
      backgroundColor: Colors.transparent,
    );
  }
}

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
        final lastMsg = messages.isNotEmpty ? messages.last : null;
        
        // 🛠️ Logic: Show choices only if they exist and the last sender wasn't Nadia
        final hasChoices = lastMsg != null && 
                           (lastMsg.choices?.isNotEmpty ?? false) && 
                           lastMsg.sender != Sender.nadia;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: const Color(0xFF080000), // Deepest crimson black
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
                style: TextStyle(color: Colors.redAccent, fontSize: 10, letterSpacing: 5, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 30),
              if (!hasChoices)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text("Waiting for a heartbeat...", 
                      style: TextStyle(color: Colors.white12, fontSize: 12, fontStyle: FontStyle.italic)
                    )
                  ),
                )
              else
                ...lastMsg.choices!.map((choice) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 40),
                  child: GestureDetector(
                    onTap: () {
                      _engine.makeChoice(choice);
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
                          fontWeight: FontWeight.w300
                        ),
                      ),
                    ),
                  ),
                )).toList(),
            ],
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
