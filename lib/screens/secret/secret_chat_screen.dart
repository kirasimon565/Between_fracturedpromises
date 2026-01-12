import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/colors.dart';
import '../../services/story_engine.dart';
import '../../models/message.dart';
import '../messenger/messenger_bubble.dart'; // Reuse logic but with secret theme

class SecretChatScreen extends StatelessWidget {
  final StoryEngine _engine = Get.find<StoryEngine>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Pure void for the secret channel
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              "ENCRYPTED_CHANNEL_X", 
              style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontFamily: 'monospace', letterSpacing: 2)
            ),
            const SizedBox(height: 4),
            Text(
              "IDENTITY_PROTECTED", 
              style: TextStyle(color: Colors.greenAccent.withOpacity(0.3), fontSize: 8)
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.greenAccent, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Cyber-glitch separator
          Container(
            height: 1, 
            width: double.infinity, 
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.greenAccent.withOpacity(0.2), blurRadius: 10, spreadRadius: 1)
              ],
              color: Colors.greenAccent.withOpacity(0.5),
            ),
          ),
          Expanded(
            child: Obx(() {
              // Fetching specifically 'secret' category messages
              final messages = _engine.getMessagesForThread('secret');
              
              if (messages.isEmpty) {
                return Center(
                  child: Text(
                    "WAITING FOR DATA PACKETS...", 
                    style: TextStyle(color: Colors.greenAccent.withOpacity(0.2), fontFamily: 'monospace')
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  // Secret messages use a specific terminal-style bubble
                  return _buildSecretBubble(msg);
                },
              );
            }),
          ),
          // System warning at the bottom
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: Colors.black,
            child: Center(
              child: Text(
                "TRACE_DETECTION_DISABLED", 
                style: TextStyle(color: Colors.redAccent.withOpacity(0.4), fontSize: 9, letterSpacing: 3)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecretBubble(Message message) {
    bool isMe = message.sender == Sender.nadia;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.greenAccent.withOpacity(0.05) : Colors.white.withOpacity(0.02),
          border: Border.all(color: isMe ? Colors.greenAccent.withOpacity(0.2) : Colors.white10),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isMe ? Colors.greenAccent : Colors.white70,
            fontFamily: 'monospace',
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
