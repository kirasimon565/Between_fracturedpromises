import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/constants.dart';
import '../../services/story_engine.dart';
import '../../theme/colors.dart';
import '../../models/message.dart';
import 'dart:math';

class MessengerListScreen extends StatefulWidget {
  @override
  _MessengerListScreenState createState() => _MessengerListScreenState();
}

class _MessengerListScreenState extends State<MessengerListScreen> with SingleTickerProviderStateMixin {
  final StoryEngine _engine = Get.find<StoryEngine>();
  late AnimationController _swayController;

  @override
  void initState() {
    super.initState();
    // Sway animation for "Hanging by rope" feel
    _swayController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Base
      body: Stack(
        children: [
          // 1. Background (Blue Glow Fade)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF001F3F), // Deep Blue
                  Colors.black,
                  Colors.black,
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Title "Hanging by rope"
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 30),
                    child: AnimatedBuilder(
                      animation: _swayController,
                      builder: (context, child) {
                         double angle = 0.02 * sin(_swayController.value * 3.14);
                         return Transform.rotate(
                           angle: angle,
                           alignment: Alignment.topCenter,
                           child: child,
                         );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 2, height: 40, color: Colors.white24), // Rope
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(color: Colors.white24),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "MESSENGER",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                letterSpacing: 4,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. List Container (Branch-like)
                Expanded(
                  child: Obx(() {
                    final allThreads = _engine.activeThreadIds.toList();
                    final threads = allThreads.where((id) => id.toLowerCase() != 'daniel').toList();

                    if (threads.isEmpty) {
                      return Center(
                         child: Text(
                           "NO ACTIVE CHANNELS",
                           style: TextStyle(color: Colors.white.withOpacity(0.3), letterSpacing: 2)
                         ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: threads.length,
                      itemBuilder: (context, index) {
                        final threadId = threads[index];
                        final name = threadId[0].toUpperCase() + threadId.substring(1);

                        // We need to subscribe to get the preview message
                        return StreamBuilder<Message?>(
                          stream: _engine.getLastMessageStream(threadId),
                          builder: (context, snapshot) {
                            final lastMsg = snapshot.data;
                            final content = lastMsg?.content ?? "Start conversation...";

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: GestureDetector(
                                onTap: () => Get.toNamed('/messenger/chat', arguments: name),
                                child: Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(30),
                                      bottomRight: const Radius.circular(30),
                                      topRight: Radius.circular(index.isEven ? 10 : 30),
                                      bottomLeft: Radius.circular(index.isOdd ? 10 : 30),
                                    ),
                                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: CircleAvatar(
                                          radius: 28,
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: AssetImage(AppConstants.getAvatarPath(name)),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                                            const SizedBox(height: 4),
                                            Text(
                                              content,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 15),
                                        child: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white.withOpacity(0.3)),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
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
}
