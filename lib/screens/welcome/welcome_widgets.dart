import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const WelcomeButton({Key? key, required this.label, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton( // Outlined looks more like a "Hacker/System" interface
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white54, width: 1),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), // Sharp edges for "Fractured" feel
          backgroundColor: Colors.white.withOpacity(0.05),
        ),
        onPressed: onPressed,
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            letterSpacing: 4,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
