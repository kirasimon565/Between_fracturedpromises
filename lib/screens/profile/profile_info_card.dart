import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const ProfileInfoCard({
    Key? key, 
    required this.title, 
    required this.content, 
    required this.icon
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Glassmorphism effect: subtle white tint with a blur feel
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.08), 
            width: 0.5
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Professional Icon Styling
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white54, size: 18),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label style
                  Text(
                    title.toUpperCase(), 
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3), 
                      fontSize: 9, 
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  const SizedBox(height: 6),
                  // Content style
                  Text(
                    content, 
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 14, 
                      fontWeight: FontWeight.w300,
                      height: 1.4
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
