import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/constants.dart';
import '../../models/message.dart';
import '../../services/story_engine.dart';
import '../../services/firestore_service.dart'; // Import FirestoreService
import '../../services/auth_service.dart';
import '../../widgets/typing_indicator.dart';
import '../../theme/colors.dart';
import 'messenger_bubble.dart';
import '../../widgets/chat_input_bar.dart';
import '../../widgets/choice_overlay.dart';
import '../../widgets/particles/digital_dust.dart';

class MessengerChatScreen extends StatelessWidget {
  final String partnerName;
  final StoryEngine _engine = Get.find<StoryEngine>();
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final AuthService _auth = Get.find<AuthService>();

  MessengerChatScreen({Key? key})
      : partnerName = Get.arguments ?? 'Unknown',
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final String threadId = partnerName.toLowerCase();
    final String partnerId = threadId; // Assuming partnerId matches threadId for now

    return Scaffold(
      backgroundColor: AppColors.messengerBackground,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white10,
              backgroundImage: AssetImage(AppConstants.getAvatarPath(partnerName)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nickname Stream
                StreamBuilder<DocumentSnapshot>(
                  stream: _firestore.streamUser(_auth.uid),
                  builder: (context, snapshot) {
                    String displayName = partnerName;
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data = snapshot.data!.data() as Map<String, dynamic>?;
                      if (data != null && data['contacts'] != null && data['contacts'][partnerId] != null) {
                        displayName = data['contacts'][partnerId]['nickname'] ?? partnerName;
                      }
                    }
                    return Text(displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400));
                  },
                ),
                // Online Status Stream
                StreamBuilder<DocumentSnapshot>(
                  stream: _firestore.streamCharacter(partnerId),
                  builder: (context, snapshot) {
                    bool isOnline = false;
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data = snapshot.data!.data() as Map<String, dynamic>?;
                      isOnline = data?['is_online'] ?? false;
                    }
                    if (!isOnline) return const SizedBox.shrink();
                    return const Text("online", style: TextStyle(fontSize: 10, color: Colors.greenAccent));
                  },
                ),
              ],
            ),
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
            child: StreamBuilder<List<Message>>(
              stream: _engine.getMessagesStream(threadId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];

                return Obx(() {
                  final isTyping = _engine.isTyping[threadId] ?? false;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    reverse: false,
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
                      // Use ValueKey to preserve state and avoid re-explosion
                      return DigitalDust(
                        key: ValueKey(msg.id),
                        autoPlay: true,
                        child: MessengerBubble(message: msg, isMe: msg.sender == Sender.nadia)
                      );
                    },
                  );
                });
              },
            ),
          ),
          StreamBuilder<List<Message>>(
            stream: _engine.getMessagesStream(threadId),
            builder: (context, snapshot) {
              final messages = snapshot.data ?? [];
              if (messages.isEmpty) return ChatInputBar();

              final lastMsg = messages.last;
              if ((lastMsg.choices?.isNotEmpty ?? false) && lastMsg.sender != Sender.nadia) {
                 return ChoiceOverlay(
                   choices: lastMsg.choices!.map((c) => c.text).toList(),
                   onSelected: (index) => _engine.makeChoice(lastMsg.choices![index])
                 );
              }
              return ChatInputBar();
            }
          ),
        ],
      ),
    );
  }
}
