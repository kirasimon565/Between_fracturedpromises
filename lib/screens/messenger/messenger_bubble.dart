import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class MessengerBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessengerBubble({Key? key, required this.message, required this.isMe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message.sender == Sender.system) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            message.content.toUpperCase(), 
            style: AppTextStyles.messengerCaption.copyWith(letterSpacing: 2, color: Colors.white38)
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4, 
          bottom: 4, 
          left: isMe ? 60 : 12, 
          right: isMe ? 12 : 60
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // Use the Noir colors from our new theme
          color: isMe ? AppColors.messengerBubbleSelf : AppColors.messengerBubbleOther,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 12),
          ),
        ),
        child: Text(
          message.content,
          style: AppTextStyles.messengerBody.copyWith(
            color: Colors.white.withOpacity(0.9), // Cleaner white text for dark mode
          ),
        ),
      ),
    );
  }
}
