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
      backgroundImage: url != null && url!.isNotEmpty ? AssetImage(url!) : null,
      child: url == null || url!.isEmpty
          ? Text(label[0].toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          : null,
    );
  }
}
