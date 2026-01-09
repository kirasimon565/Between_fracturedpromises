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
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(message.content, style: AppTextStyles.messengerCaption),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.messengerBubbleSelf : AppColors.messengerBubbleOther,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: isMe ? Radius.circular(18) : Radius.circular(4),
            bottomRight: isMe ? Radius.circular(4) : Radius.circular(18),
          ),
        ),
        child: Text(
          message.content,
          style: AppTextStyles.messengerBody.copyWith(
            color: isMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
