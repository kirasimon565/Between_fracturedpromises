import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class MakeloveBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MakeloveBubble({Key? key, required this.message, required this.isMe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message.sender == Sender.system) return const SizedBox.shrink();

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.makeloveBubbleSelf : AppColors.makeloveBubbleOther,
          // Sharp edges to match the "Fractured" aesthetic
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(4),
            topRight: const Radius.circular(4),
            bottomLeft: Radius.circular(isMe ? 4 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 4),
          ),
          border: Border.all(
            color: isMe ? AppColors.makelovePrimary.withOpacity(0.5) : Colors.white10,
            width: 0.5,
          ),
          boxShadow: [
            if (isMe) 
              BoxShadow(
                color: AppColors.makelovePrimary.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              )
          ]
        ),
        child: Text(
          message.content,
          style: AppTextStyles.makeloveBody.copyWith(
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
