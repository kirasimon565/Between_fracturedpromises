import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final String label;
  final String assetPath; // Changed from IconData
  final VoidCallback onTap;

  const AppIcon({
    Key? key,
    required this.label,
    required this.assetPath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Using Image.asset to show your custom designed app icons
          SizedBox(
            width: 62,
            height: 62,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(assetPath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
              shadows: [Shadow(color: Colors.black54, blurRadius: 4)]
            )
          ),
        ],
      ),
    );
  }
}
