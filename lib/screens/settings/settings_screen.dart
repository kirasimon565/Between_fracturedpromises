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
      // We trigger a haptic feedback or snackbar here usually
      Get.snackbar("SYSTEM", "SECURE GATEWAY DETECTED",
        colorText: Colors.red, backgroundColor: Colors.black,
        snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));

      Future.delayed(const Duration(seconds: 1), () {
        Get.toNamed(AppRoutes.adminDialpad);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Very dark grey
      appBar: AppBar(
        title: const Text("SETTINGS", style: TextStyle(letterSpacing: 2, fontSize: 14)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildSectionHeader("ACCOUNT"),
          _buildSettingsItem(Icons.person_outline, "Account Profile", () => Get.toNamed(AppRoutes.profile)),
          _buildSettingsItem(Icons.lock_outline, "Privacy & Security", () {}),

          _buildSectionHeader("SYSTEM"),
          _buildSettingsItem(Icons.notifications_none, "Notifications", () {}, trailing: _buildSwitch(true)),
          _buildSettingsItem(Icons.volume_up_outlined, "Sound Effects", () {}, trailing: _buildSwitch(true)),
          _buildSettingsItem(Icons.music_note_outlined, "Ambient Music", () {}, trailing: _buildSwitch(false)),

          const SizedBox(height: 30),
          const Divider(color: Colors.white10),

          // THE SECRET GATEWAY
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            title: const Text("System Version", style: TextStyle(color: Colors.white54, fontSize: 14)),
            subtitle: Text(
              "${AppConstants.version} (Build ${AppConstants.buildNumber})", 
              style: const TextStyle(color: Colors.white24, fontSize: 12, fontFamily: 'monospace')
            ),
            onTap: _handleVersionTap,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold)
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap, {Widget? trailing}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
      leading: Icon(icon, color: Colors.white70, size: 20),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w300)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.white12, size: 18),
      onTap: onTap,
    );
  }

  Widget _buildSwitch(bool value) {
    return Switch(
      value: value,
      onChanged: (v) {},
      activeColor: Colors.white,
      activeTrackColor: Colors.white24,
      inactiveThumbColor: Colors.grey,
      inactiveTrackColor: Colors.white10,
    );
  }
}
