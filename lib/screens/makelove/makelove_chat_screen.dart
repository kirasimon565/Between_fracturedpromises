import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/message.dart';
import '../../services/story_engine.dart';
import '../../widgets/typing_indicator.dart';
import '../../theme/colors.dart';
import 'makelove_bubble.dart';
import '../../widgets/chat_input_bar.dart';
import '../../widgets/choice_overlay.dart';

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
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              partnerName.toUpperCase(), 
              style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 3)
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text("LIVE", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white54),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Visual separator line
          Container(height: 1, color: AppColors.makelovePrimary.withOpacity(0.2)),
          Expanded(
            child: Obx(() {
              final messages = _engine.getMessagesForThread(partnerName.toLowerCase());
              final isTyping = _engine.isTyping[partnerName.toLowerCase()] ?? false;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 20),
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length) {
                     return const Align(
                       alignment: Alignment.centerLeft,
                       child: Padding(
                         padding: EdgeInsets.only(left: 20),
                         child: TypingIndicator(color: Colors.redAccent),
                       ),
                     );
                  }
                  final msg = messages[index];
                  return MakeloveBubble(message: msg, isMe: msg.sender == Sender.nadia);
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
