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
    if (message.sender == Sender.system) return SizedBox.shrink();

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.makeloveBubbleSelf : AppColors.makeloveBubbleOther,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: isMe ? Radius.circular(20) : Radius.circular(0),
            bottomRight: isMe ? Radius.circular(0) : Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: isMe ? AppColors.makelovePrimary.withOpacity(0.4) : Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ]
        ),
        child: Text(
          message.content,
          style: AppTextStyles.makeloveBody.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
