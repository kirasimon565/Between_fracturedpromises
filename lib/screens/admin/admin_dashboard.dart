import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: Colors.grey[900],
        foregroundColor: AppColors.adminText,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildAdminCard(
            title: "Episode Uploader",
            icon: Icons.cloud_upload,
            desc: "Upload JSON episodes to Firestore",
            onTap: () {},
          ),
          _buildAdminCard(
            title: "Live Ops",
            icon: Icons.flash_on,
            desc: "Hotfix dialogue, push notifications",
            onTap: () {},
          ),
          _buildAdminCard(
            title: "Analytics",
            icon: Icons.bar_chart,
            desc: "View player progress and choices",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard({required String title, required IconData icon, required String desc, required VoidCallback onTap}) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, color: AppColors.adminText, size: 40),
        title: Text(title, style: TextStyle(color: AppColors.adminText, fontWeight: FontWeight.bold)),
        subtitle: Text(desc, style: TextStyle(color: Colors.white70)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white30),
        onTap: onTap,
      ),
    );
  }
}
