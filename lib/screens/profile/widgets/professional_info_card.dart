import 'package:flutter/material.dart';
import 'dart:ui';

class ProfessionalInfoCard extends StatelessWidget {
  final String bio;
  final VoidCallback? onExpand;

  const ProfessionalInfoCard({
    Key? key,
    required this.bio,
    this.onExpand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Text(
                bio,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w300,
                ),
              ),
              if (onExpand != null) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onExpand,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white24,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
