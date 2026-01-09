import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../services/story_engine.dart';
import '../../widgets/typing_indicator.dart';
import '../../theme/colors.dart';
import 'makelove_bubble.dart';
import '../../widgets/chat_input_bar.dart';

class MakeloveChatScreen extends StatelessWidget {
  final String partnerName;
  final StoryEngine _engine = Get.find<StoryEngine>();

  MakeloveChatScreen({Key? key})
      : partnerName = Get.arguments ?? 'Unknown',
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.makeloveBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
             Container(
               padding: EdgeInsets.all(2),
               decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.makelovePrimary),
               child: CircleAvatar(
                 backgroundImage: AssetImage('assets/avatars/${partnerName.toLowerCase()}.png'), // Assuming logic
                 backgroundColor: Colors.black,
                 child: Text(partnerName[0]),
               ),
             ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(partnerName, style: TextStyle(color: Colors.white, fontSize: 16)),
                Text("Online", style: TextStyle(color: AppColors.makelovePrimary, fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.more_horiz, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final messages = _engine.getMessagesForThread(partnerName.toLowerCase());
              final isTyping = _engine.isTyping[partnerName.toLowerCase()] ?? false;

              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length) {
                     return Align(
                       alignment: Alignment.centerLeft,
                       child: TypingIndicator(color: AppColors.makelovePrimary),
                     );
                  }

                  final msg = messages[index];
                  return MakeloveBubble(
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
