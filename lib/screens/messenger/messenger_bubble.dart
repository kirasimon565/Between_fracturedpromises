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
  late Animation<double> _float; // ☁️ Added for subtle cloud movement

  @override
  void initState() {
    super.initState();
    _explosionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Explosion effect: elastic pop
    _scale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _explosionController, curve: Curves.elasticOut)
    );
    
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _explosionController, curve: Curves.easeIn)
    );

    // Subtle floating animation to mimic a cloud
    _float = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(parent: _explosionController, curve: Curves.easeInOut)
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
            style: const TextStyle(
              color: Colors.white24, 
              fontSize: 10, 
              letterSpacing: 3,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _opacity,
      child: AnimatedBuilder(
        animation: _float,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _float.value),
            child: child,
          );
        },
        child: ScaleTransition(
          scale: _scale,
          child: Align(
            alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: widget.isMe 
                    ? Colors.white.withOpacity(0.12) 
                    : Colors.blueGrey.withOpacity(0.12),
                // ☁️ Professional Cloud Shape
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(30),
                  topRight: const Radius.circular(30),
                  bottomLeft: Radius.circular(widget.isMe ? 30 : 8),
                  bottomRight: Radius.circular(widget.isMe ? 8 : 30),
                ),
                border: Border.all(
                  color: widget.isMe ? Colors.white12 : Colors.white.withOpacity(0.08),
                  width: 0.5,
                ),
                // Subtle glow for "exploding" arrivals
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Text(
                widget.message.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
