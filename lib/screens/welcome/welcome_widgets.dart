import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter

class WelcomeButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  // 🛠️ ADDED: Optional icon parameter to fix build error
  final IconData? icon; 

  const WelcomeButton({
    Key? key, 
    required this.label, 
    required this.onPressed,
    this.icon, // Initialize optional icon
  }) : super(key: key);

  @override
  _WelcomeButtonState createState() => _WelcomeButtonState();
}

class _WelcomeButtonState extends State<WelcomeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.98).animate(_controller),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
           _controller.reverse();
           widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30), // Rounded pill
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Glassmorphism
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1), // Semi-transparent white
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5), // Thin border
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🛠️ Icon Integration: Show only if icon is provided
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 10), // Spacing between icon and text
                  ],
                  Text(
                    widget.label.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
