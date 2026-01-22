// lib/screens/chat/messenger_chat_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/message.dart';
import '../../services/story_engine.dart';
import '../../services/audio_service.dart';
import '../../widgets/typing_indicator.dart';
import '../../app/constants.dart';
import '../../theme/colors.dart';
import 'messenger_bubble.dart';
import 'choice_overlay.dart';
import '../profile/character_profile_screen.dart';

class MessengerChatScreen extends StatefulWidget {
  @override
  _MessengerChatScreenState createState() => _MessengerChatScreenState();
}

class _MessengerChatScreenState extends State<MessengerChatScreen> {
  final StoryEngine _engine = Get.find<StoryEngine>();
  final ScrollController _scrollController = ScrollController();
  final AudioService _audio = Get.find<AudioService>();

  late final String threadId;
  late final String partnerName;

  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;
    final raw = (arg is String && arg.isNotEmpty) ? arg : 'Unknown';
    threadId = raw.toLowerCase().trim();
    partnerName = _toDisplayName(raw);
  }

  String _toDisplayName(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return "Unknown";
    return s[0].toUpperCase() + s.substring(1);
  }

  void _navigateToProfile() {
    // 🛠️ Navigate to Character Profile
    String bio = "No data.";
    String avatar = AppConstants.avatarEthan;

    if (threadId == 'ethan') {
      bio = "A project manager in a construction and infrastructure firm.\nReliable, disciplined, and deeply invested in providing stability for his family.\nBelieves love is built through responsibility, not constant emotional expression.";
      avatar = AppConstants.avatarEthan;
    } else if (threadId == 'claire') {
      bio = "Nadia's best friend and a junior therapist.\nEmotionally intelligent, observant, and deeply protective of her inner circle.\nStruggles between supporting Nadia and confronting the truth she senses.";
      avatar = AppConstants.avatarClaire;
    } else if (threadId == 'olivia') {
      bio = "An administrative assistant in a legal office.\nHighly structured, judgmental, and attentive to details others overlook.\nSees it as her responsibility to protect her brother—even if it means crossing lines.";
      avatar = AppConstants.avatarOlivia;
    }

    Get.to(() => CharacterProfileScreen(
      characterId: threadId,
      name: partnerName,
      bio: bio,
      avatarPath: avatar,
      themeColor: AppColors.messengerPrimary,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.messengerPrimary),
          onPressed: () => Get.back(),
        ),
        title: GestureDetector(
          onTap: _navigateToProfile,
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage(AppConstants.getAvatarPath(threadId)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partnerName,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  StreamBuilder<bool>(
                    stream: _engine.isTyping.stream.map((map) => map[threadId] ?? false),
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return const Text(
                          "typing...",
                          style: TextStyle(
                            color: AppColors.messengerPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }
                      return const Text(
                        "Active Now",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: AppColors.messengerPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call, color: AppColors.messengerPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _engine.getMessagesStream(threadId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];

                // Auto-scroll
                if (messages.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                }

                return Obx(() {
                  final typing = _engine.isTyping[threadId] ?? false;

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: messages.length + (typing ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (typing && index == messages.length) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TypingIndicator(color: Colors.grey),
                          ),
                        );
                      }

                      final msg = messages[index];
                      // Check choice overlay trigger
                      if (index == messages.length - 1 &&
                          (msg.choices?.isNotEmpty ?? false) &&
                          msg.sender != Sender.nadia) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (Get.isBottomSheetOpen == false) {
                             _showChoices(msg);
                          }
                        });
                      }

                      return MessengerBubble(
                        message: msg,
                        isMe: msg.sender == Sender.nadia,
                      );
                    },
                  );
                });
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  void _showChoices(Message msg) {
    Get.bottomSheet(
      ChoiceOverlay(
        choices: msg.choices!,
        onChoiceSelected: (choice) {
          Get.back(); // Close sheet
          _engine.makeChoice(threadId, choice);
        },
      ),
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            const Icon(Icons.add_circle, color: AppColors.messengerPrimary),
            const SizedBox(width: 10),
            const Icon(Icons.image, color: Colors.grey),
            const SizedBox(width: 10),
            const Icon(Icons.mic, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Message...",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.thumb_up, color: AppColors.messengerPrimary),
          ],
        ),
      ),
    );
  }
}
