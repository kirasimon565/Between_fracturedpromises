import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../services/audio_service.dart';
import 'package:get/get.dart';

class MessengerBubble extends StatefulWidget {
  final Message message;
  final bool isMe;

  const MessengerBubble({Key? key, required this.message, required this.isMe}) : super(key: key);

  @override
  State<MessengerBubble> createState() => _MessengerBubbleState();
}

class _MessengerBubbleState extends State<MessengerBubble> with SingleTickerProviderStateMixin {
  late AnimationController _explosionController;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _explosionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _scale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _explosionController, curve: Curves.elasticOut)
    );
    
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _explosionController, curve: Curves.easeIn)
    );

    _explosionController.forward();
  }

  @override
  void dispose() {
    _explosionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message.sender == Sender.system) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            widget.message.content.toUpperCase(),
            style: const TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 3),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Align(
          alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: widget.isMe ? Colors.white.withOpacity(0.1) : Colors.blueGrey.withOpacity(0.1),
              // Cloud Shape
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(25),
                topRight: const Radius.circular(25),
                bottomLeft: Radius.circular(widget.isMe ? 25 : 5),
                bottomRight: Radius.circular(widget.isMe ? 5 : 25),
              ),
              border: Border.all(
                color: widget.isMe ? Colors.white10 : Colors.white.withOpacity(0.05),
              ),
            ),
            child: Text(
              widget.message.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
