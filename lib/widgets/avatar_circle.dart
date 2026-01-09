import 'package:flutter/material.dart';

class AvatarCircle extends StatelessWidget {
  final String? url;
  final String label;
  final double radius;
  final Color backgroundColor;

  const AvatarCircle({
    Key? key,
    this.url,
    required this.label,
    this.radius = 20,
    this.backgroundColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: url != null && url!.isNotEmpty
          ? AssetImage(url!)
          : null,
      onBackgroundImageError: (_, __) {
        // Fallback gracefully if asset is empty/missing
      },
      child: (url == null || url!.isEmpty) // Also show text if image fails/empty (logic simplified as onBackgroundImageError doesn't easily switch child)
          ? Text(label[0].toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          : null, // Note: standard CircleAvatar keeps showing background image even if error, often just blank.
                  // For robust fallback we'd need a custom widget, but this helps prevent crash loop if handled internally by flutter.
    );
  }
}
