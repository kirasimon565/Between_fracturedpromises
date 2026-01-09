import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const ProfileInfoCard({Key? key, required this.title, required this.content, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white10,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: TextStyle(color: Colors.white54, fontSize: 12)),
        subtitle: Text(content, style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
