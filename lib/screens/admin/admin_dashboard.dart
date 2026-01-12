import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      appBar: AppBar(
        title: const Text("ROOT@SYSTEM: ~ / DASHBOARD", style: TextStyle(fontSize: 14, letterSpacing: 1)),
        backgroundColor: Colors.black,
        foregroundColor: AppColors.adminText,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(25),
        children: [
          _buildAdminCard(
            title: "EPISODE UPLOADER",
            icon: Icons.terminal,
            desc: "Inject JSON script to Firestore cloud",
            onTap: () => Get.toNamed('/admin/uploader'),
          ),
          _buildAdminCard(
            title: "LIVE OPS HOTFIX",
            icon: Icons.bolt,
            desc: "Modify variables and active threads",
            onTap: () {},
          ),
          _buildAdminCard(
            title: "STORY ANALYTICS",
            icon: Icons.analytics_outlined,
            desc: "Monitor global player choices",
            onTap: () {},
          ),
          const SizedBox(height: 40),
          Center(
            child: TextButton(
              onPressed: () => Get.offAllNamed('/home'),
              child: Text("EXIT TO SYSTEM", style: TextStyle(color: AppColors.adminText.withOpacity(0.5))),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAdminCard({required String title, required IconData icon, required String desc, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.adminText.withOpacity(0.2)),
        color: Colors.white.withOpacity(0.02),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Icon(icon, color: AppColors.adminText, size: 30),
        title: Text(title, style: TextStyle(color: AppColors.adminText, fontWeight: FontWeight.bold, letterSpacing: 1)),
        subtitle: Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        onTap: onTap,
      ),
    );
  }
}
