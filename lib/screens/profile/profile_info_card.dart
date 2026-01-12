import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const ProfileInfoCard({Key? key, required this.title, required this.content, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)), // Sleek thin separator
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white24, size: 18),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w300)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
