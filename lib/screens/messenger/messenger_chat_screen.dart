import 'package:get/get.dart';
import 'package:flutter/material.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.messengerText,
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(child: Text(partnerName[0])),
            SizedBox(width: 10),
            Text(partnerName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.call, color: AppColors.messengerPrimary), onPressed: () {}),
          IconButton(icon: Icon(Icons.videocam, color: AppColors.messengerPrimary), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              // Filter messages for this conversation
              final messages = _engine.getMessagesForThread(partnerName.toLowerCase());
              final isTyping = _engine.isTyping[partnerName.toLowerCase()] ?? false;

              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length) {
                     return Align(
                       alignment: Alignment.centerLeft,
                       child: TypingIndicator(color: Colors.grey),
                     );
                  }

                  final msg = messages[index];
                  return MessengerBubble(
                    message: msg,
                    isMe: msg.sender == Sender.nadia
                  );
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
            return ChatInputBar();
          }),
        ],
      ),
    );
  }
}
