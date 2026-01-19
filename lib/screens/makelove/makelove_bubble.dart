import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../services/audio_service.dart';
import 'package:get/get.dart';

class MakeloveBubble extends StatefulWidget {
  final Message message;
  final bool isMe;

  const MakeloveBubble({Key? key, required this.message, required this.isMe}) : super(key: key);

  @override
  State<MakeloveBubble> createState() => _MakeloveBubbleState();
}

class _MakeloveBubbleState extends State<MakeloveBubble> with SingleTickerProviderStateMixin {
  late AnimationController _popController;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    
    // Intense "Explosion" scale with elastic overshoot
    _scale = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _popController, curve: Curves.elasticOut)
    );
    
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _popController, curve: Curves.easeIn)
    );

    _popController.forward();
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide system messages in this view to keep it focused on the "Live" interaction
    if (widget.message.sender == Sender.system) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Align(
          alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
            decoration: BoxDecoration(
              // Deeper, darker shades for the "Makelove" aesthetic
              color: widget.isMe 
                  ? const Color(0xFF1A0000).withOpacity(0.8) 
                  : const Color(0xFF0A0A0A).withOpacity(0.8),
              
              // Sharp "Fractured Cloud" Shape
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(widget.isMe ? 20 : 2),
                bottomRight: Radius.circular(widget.isMe ? 2 : 20),
              ),
              
              border: Border.all(
                color: widget.isMe 
                    ? Colors.red.withOpacity(0.3) 
                    : Colors.white.withOpacity(0.05),
                width: 0.8,
              ),
              
              // Crimson Glow for arrivals
              boxShadow: [
                BoxShadow(
                  color: widget.isMe 
                      ? Colors.red.withOpacity(0.15) 
                      : Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 1,
                )
              ],
            ),
            child: Text(
              widget.message.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.4,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
