import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/constants.dart';
import '../../models/message.dart';
import '../../services/story_engine.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/typing_indicator.dart';
import '../../theme/colors.dart';
import 'makelove_bubble.dart';
import '../../widgets/chat_input_bar.dart';
import '../../widgets/choice_overlay.dart';
import '../../widgets/particles/digital_dust.dart';

class MakeloveChatScreen extends StatelessWidget {
  final String partnerName;
  final StoryEngine _engine = Get.find<StoryEngine>();
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final AuthService _auth = Get.find<AuthService>();

  MakeloveChatScreen({Key? key})
      : partnerName = Get.arguments ?? 'Unknown',
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final String threadId = partnerName.toLowerCase();
    final String partnerId = threadId;

    return Scaffold(
      backgroundColor: AppColors.makeloveBackground,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
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
                return Text(
                  displayName.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 3)
                );
              },
            ),
            const SizedBox(height: 4),
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore.streamCharacter(partnerId),
              builder: (context, snapshot) {
                bool isOnline = false;
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  isOnline = data?['is_online'] ?? false;
                }

                if (!isOnline) {
                   return const SizedBox(height: 0);
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text("LIVE", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                );
              },
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
          Container(height: 1, color: AppColors.makelovePrimary.withOpacity(0.2)),
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _engine.getMessagesStream(threadId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];

                return Obx(() {
                  final isTyping = _engine.isTyping[threadId] ?? false;

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
                      return DigitalDust(
                        key: ValueKey(msg.id),
                        particleColor: Colors.red.withOpacity(0.5),
                        child: MakeloveBubble(message: msg, isMe: msg.sender == Sender.nadia)
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
