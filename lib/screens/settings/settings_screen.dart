import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../app/constants.dart';
import '../../theme/colors.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _tapCount = 0;

  void _handleVersionTap() {
    _tapCount++;
    if (_tapCount >= 5) {
      _tapCount = 0;
      // Secretly navigates to the Dialpad
      Get.toNamed(AppRoutes.adminDialpad);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.messengerBackground,
      appBar: AppBar(
        title: const Text("SETTINGS", style: TextStyle(letterSpacing: 2, fontSize: 14)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildSettingsItem(Icons.person_outline, "Account Profile", () => Get.toNamed(AppRoutes.profile)),
          _buildSettingsItem(Icons.notifications_none, "System Notifications", () {}),
          _buildSettingsItem(Icons.lock_outline, "Privacy & Security", () {}),
          _buildSettingsItem(Icons.palette_outlined, "Interface Theme", () {}),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Divider(color: Colors.white10),
          ),
          // THE SECRET GATEWAY
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 25),
            title: const Text("System Version", style: TextStyle(color: Colors.white, fontSize: 15)),
            subtitle: Text(
              "${AppConstants.version} (Build ${AppConstants.buildNumber})", 
              style: const TextStyle(color: Colors.white38, fontSize: 12)
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white24),
            onTap: _handleVersionTap,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white12, size: 18),
      onTap: onTap,
    );
  }
}
