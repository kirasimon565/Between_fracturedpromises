// lib/screens/makelove/makelove_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/constants.dart';
import '../../services/story_engine.dart';
import '../../services/audio_service.dart';
import '../../theme/colors.dart';
import '../../theme/theme.dart';
import '../../models/message.dart';
import 'dart:math' as math;

class MakeloveListScreen extends StatefulWidget {
  @override
  _MakeloveListScreenState createState() => _MakeloveListScreenState();
}

class _MakeloveListScreenState extends State<MakeloveListScreen>
    with SingleTickerProviderStateMixin {
  final ThemeService _themeService = Get.find<ThemeService>();
  final StoryEngine _engine = Get.find<StoryEngine>();
  final AudioService _audio = Get.find<AudioService>();
  late AnimationController _swayController;

  @override
  void initState() {
    super.initState();
    _themeService.setSecretMode(true);
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050000),
      body: Stack(
        children: [
          _buildAmbientGlow(),
          SafeArea(
            child: Column(
              children: [
                _buildHangingHeader(),
                const SizedBox(height: 30),

                // ✅ Use the engine's Makelove-only list
                Expanded(
                  child: Obx(() {
                    final threads = _engine.makeloveThreads.toList();

                    if (threads.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite_border_rounded,
                                color: Colors.red, size: 30),
                            const SizedBox(height: 15),
                            Text(
                              "NO SIGNAL DETECTED",
                              style: TextStyle(
                                color: Colors.red.withOpacity(0.3),
                                letterSpacing: 5,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "SEARCHING FOR HEARTBEAT...",
                              style: TextStyle(
                                color: Colors.red.withOpacity(0.15),
                                letterSpacing: 2,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      itemCount: threads.length,
                      itemBuilder: (context, index) {
                        // ✅ Always sanitize thread ids to match StoryEngine keys
                        final threadId = threads[index].toLowerCase().trim();
                        final name = threadId.toUpperCase();

                        return StreamBuilder<Message?>(
                          stream: _engine.getLastMessageStream(threadId),
                          builder: (context, snapshot) {
                            final lastMsg = snapshot.data;

                            return Obx(() {
                              final bool typing =
                                  _engine.isTyping[threadId] ?? false;

                              final content = typing
                                  ? "Whispering..."
                                  : (lastMsg?.content ?? "Establishing link...");

                              return _buildAdvancedMatchTile(
                                  threadId, name, content, typing);
                            });
                          },
                        );
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

  Widget _buildAmbientGlow() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Colors.red.withOpacity(0.08), Colors.transparent],
          ),
        ),
      ),
    );
  }

  Widget _buildHangingHeader() {
    return AnimatedBuilder(
      animation: _swayController,
      builder: (context, child) {
        final double angle =
            0.02 * math.sin(_swayController.value * 2 * math.pi);
        return Transform.rotate(
          angle: angle,
          alignment: Alignment.topCenter,
          child: child,
        );
      },
      child: Column(
        children: [
          Container(width: 1, height: 50, color: Colors.red.withOpacity(0.3)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.red.withOpacity(0.5), width: 0.5),
              boxShadow: [
                BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 15),
              ],
            ),
            child: const Text(
              "MAKELOVE",
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                letterSpacing: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedMatchTile(
      String threadId, String name, String lastMessage, bool isTyping) {
    return GestureDetector(
      onTap: () {
        _audio.playVibrate();
        // ✅ Pass the actual threadId (engine uses lowercase keys)
        Get.toNamed('/makelove/chat', arguments: threadId);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: isTyping ? Colors.red : Colors.red.withOpacity(0.2),
              width: 0.5,
            ),
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  colors: [
                    Colors.black,
                    Colors.black.withOpacity(0.2),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Opacity(
                  opacity: isTyping ? 0.7 : 0.4,
                  child: Image.asset(
                    AppConstants.getAvatarPath(name),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isTyping ? Colors.white : Colors.red,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _LivePulseDot(isActive: isTyping),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    lastMessage,
                    maxLines: 2,
                    style: TextStyle(
                      color: isTyping
                          ? Colors.redAccent
                          : Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      fontFamily: 'Didot',
                      fontStyle: FontStyle.italic,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              right: 30,
              top: 0,
              bottom: 0,
              child: Center(
                child: Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.red, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LivePulseDot extends StatefulWidget {
  final bool isActive;
  const _LivePulseDot({required this.isActive});

  @override
  __LivePulseDotState createState() => __LivePulseDotState();
}

class __LivePulseDotState extends State<_LivePulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(
                      widget.isActive ? _controller.value : 0.2),
                  blurRadius: 4,
                )
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          widget.isActive ? "WHISPERING..." : "LIVE",
          style: const TextStyle(
            color: Colors.red,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
