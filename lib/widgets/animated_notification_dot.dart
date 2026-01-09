import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedNotificationDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
     .scale(duration: 1000.ms, begin: Offset(1,1), end: Offset(1.2, 1.2))
     .then(delay: 200.ms)
     .scale(duration: 1000.ms, begin: Offset(1.2,1.2), end: Offset(1, 1));
  }
}
