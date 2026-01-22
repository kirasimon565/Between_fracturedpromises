// lib/screens/messenger/messenger_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/constants.dart';
import '../../services/state_service.dart';
import '../../services/audio_service.dart';
import '../../data/playback_store.dart';
import '../../logic/chat_scheduler.dart';
import 'dart:math';

class MessengerListScreen extends StatefulWidget {
  @override
  _MessengerListScreenState createState() => _MessengerListScreenState();
}

class _MessengerListScreenState extends State<MessengerListScreen>
    with SingleTickerProviderStateMixin {
  final StateService _state = Get.find<StateService>();
  final PlaybackStore _store = Get.find<PlaybackStore>();
  final ChatScheduler _scheduler = Get.find<ChatScheduler>();
  final AudioService _audio = Get.find<AudioService>();
  late AnimationController _swayController;

  @override
  void initState() {
    super.initState();
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _swayController.dispose();
    super.dispose();
  }

  String _toDisplayName(String threadId) {
    final s = threadId.trim();
    if (s.isEmpty) return "Unknown";
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Cinematic background gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.5,
                colors: [
                  const Color(0xFF001F3F).withOpacity(0.3),
                  Colors.black,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHangingHeader(),
                const SizedBox(height: 20),

                // ✅ Use StateService's unlocked thread list
                Expanded(
                  child: Obx(() {
                    final threads = _state.unlockedThreadMetas
                        .where((meta) => meta.app == 'messenger')
                        .map((meta) => meta.threadId)
                        .toList();

                    if (threads.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_off,
                              color: Colors.white.withOpacity(0.05),
                              size: 40,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "NO SECURE CONNECTIONS",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.2),
                                letterSpacing: 3,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: threads.length,
                      itemBuilder: (context, index) {
                        final threadId = threads[index];
                        return _buildConversationTile(threadId, index);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHangingHeader() {
    return AnimatedBuilder(
      animation: _swayController,
      builder: (context, child) {
        final double angle = 0.015 * sin(_swayController.value * 2 * pi);
        return Transform.rotate(
          angle: angle,
          alignment: Alignment.topCenter,
          child: child,
        );
      },
      child: Column(
        children: [
          Container(width: 1, height: 40, color: Colors.white12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
              ],
            ),
            child: const Text(
              "MESSAGES",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                letterSpacing: 6,
                fontWeight: FontWeight.w200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(String threadId, int index) {
    final String name = _toDisplayName(threadId);

    // Using Isar helper for last message
    return StreamBuilder<VisibleMessage?>(
      stream: _store.watchLastMessage(threadId),
      builder: (context, snapshot) {
        final lastMsg = snapshot.data;

        return Obx(() {
          final bool typing = _scheduler.typingStates[threadId] ?? false;
          final String content =
              typing ? "Typing..." : (lastMsg?.content ?? "Encryption active...");

          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: GestureDetector(
              onTap: () {
                _audio.playPing();
                // Pass display name (chat screen logic should be updated to expect threadId or resolve it)
                // Assuming chat screen expects name for now, but safer to pass ID if refactoring deeper.
                // Keeping argument as 'name' for compatibility with existing route logic unless changed.
                Get.toNamed('/messenger/chat', arguments: name);
              },
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(35),
                    bottomRight: const Radius.circular(35),
                    topRight: Radius.circular(index.isEven ? 10 : 35),
                    bottomLeft: Radius.circular(index.isEven ? 35 : 10),
                  ),
                  border: Border.all(
                    color: typing
                        ? Colors.greenAccent.withOpacity(0.3)
                        : Colors.white.withOpacity(0.08),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 15),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: typing ? Colors.greenAccent : Colors.white10,
                          width: typing ? 1.5 : 1,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        backgroundImage:
                            AssetImage(AppConstants.getAvatarPath(name)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            content,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: typing
                                  ? Colors.greenAccent
                                  : Colors.white.withOpacity(0.4),
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              fontStyle:
                                  typing ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withOpacity(0.1),
                      size: 18,
                    ),
                    const SizedBox(width: 15),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
