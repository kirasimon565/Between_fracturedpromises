import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/message.dart';
import '../../services/story_engine.dart';
import '../../widgets/typing_indicator.dart';
import '../../theme/colors.dart';
import 'messenger_bubble.dart';
import '../../widgets/chat_input_bar.dart';
import '../../widgets/choice_overlay.dart';

class MessengerChatScreen extends StatelessWidget {
  final String partnerName;
  final StoryEngine _engine = Get.find<StoryEngine>();

  MessengerChatScreen({Key? key})
      : partnerName = Get.arguments ?? 'Unknown',
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.messengerBackground, // NO MORE WHITE
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            // Using ACTUAL character art
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white10,
              backgroundImage: AssetImage(AppConstants.getAvatarPath(partnerName)),
            ),
            const SizedBox(width: 12),
            Text(partnerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam_outlined, size: 20), onPressed: () {}),
          IconButton(icon: const Icon(Icons.info_outline, size: 20), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final messages = _engine.getMessagesForThread(partnerName.toLowerCase());
              final isTyping = _engine.isTyping[partnerName.toLowerCase()] ?? false;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 20),
                reverse: false, // Set to true if messages should stick to bottom
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length) {
                     return const Align(
                       alignment: Alignment.centerLeft,
                       child: Padding(
                         padding: EdgeInsets.only(left: 15, top: 10),
                         child: TypingIndicator(color: Colors.white24),
                       ),
                     );
                  }
                  final msg = messages[index];
                  return MessengerBubble(message: msg, isMe: msg.sender == Sender.nadia);
                },
              );
            }),
          ),
          Obx(() {
            if (_engine.currentChoices.isNotEmpty) {
               return ChoiceOverlay(
                 choices: _engine.currentChoices.map((c) => c.text).toList(),
                 onSelected: (index) => _engine.makeChoice(_engine.currentChoices[index])
               );
            }
            return const ChatInputBar();
          }),
        ],
      ),
    );
  }
}
