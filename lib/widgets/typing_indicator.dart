import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TypingIndicator extends StatelessWidget {
  final Color color;

  const TypingIndicator({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      width: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _dot(0),
          _dot(200),
          _dot(400),
        ],
      ),
    );
  }

  Widget _dot(int delay) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .scale(duration: 600.ms, delay: delay.ms, begin: Offset(0.5, 0.5), end: Offset(1.0, 1.0));
  }
}
