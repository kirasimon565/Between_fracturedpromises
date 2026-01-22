import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../app/constants.dart';
import '../../theme/colors.dart';
import '../../services/audio_service.dart';
import '../../services/auth_service.dart';
import '../../data/playback_store.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioService _audioService = Get.find<AudioService>();
  final AuthService _authService = Get.find<AuthService>();
  final PlaybackStore _store = Get.find<PlaybackStore>();

  int _tapCount = 0;
  
  bool _isSoundFxEnabled = true;
  bool _isMusicEnabled = true;
  bool _isNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _store.getRuntimeState().then((state) {
       if (mounted) {
         setState(() {
           _isSoundFxEnabled = state.isSfxEnabled;
           _isMusicEnabled = state.isMusicEnabled;
           _isNotificationsEnabled = state.isNotificationsEnabled;
         });
       }
    });
  }

  Future<void> _toggleSetting(String key, bool value) async {
    setState(() {
      if (key == 'settings_sfx') _isSoundFxEnabled = value;
      if (key == 'settings_music') {
        _isMusicEnabled = value;
        if (!value) {
          _audioService.stopAll(); 
        } else {
          _audioService.playIntroTheme(); 
        }
      }
      if (key == 'settings_notif') _isNotificationsEnabled = value;
    });

    if (key == 'settings_sfx') await _store.updateSettings(sfx: value);
    if (key == 'settings_music') await _store.updateSettings(music: value);
    if (key == 'settings_notif') await _store.updateSettings(notif: value);
  }

  void _handleVersionTap() {
    _tapCount++;
    if (_tapCount >= 5) {
      _tapCount = 0;
      _audioService.playVibrate(); 
      
      Get.snackbar(
        "SYSTEM", "SECURE GATEWAY DETECTED",
        colorText: Colors.red, 
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.BOTTOM, 
        duration: const Duration(seconds: 1)
      );

      Future.delayed(const Duration(seconds: 1), () {
        Get.toNamed(AppRoutes.adminDialpad);
      });
    }
  }

  void _copyUid() {
    Clipboard.setData(ClipboardData(text: _authService.uid));
    Get.snackbar(
      "ENCRYPTION", "USER ID COPIED TO KEYBOARD",
      colorText: Colors.white70,
      backgroundColor: Colors.black54,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text("SETTINGS", style: TextStyle(letterSpacing: 2, fontSize: 14)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildSectionHeader("ACCOUNT"),
          _buildSettingsItem(Icons.person_outline, "Account Profile", () => Get.toNamed(AppRoutes.profile)),
          
          _buildSectionHeader("SECURITY CLEARANCE"),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 25),
            leading: const Icon(Icons.fingerprint, color: Colors.white70, size: 20),
            title: const Text("Device Identifier", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w300)),
            subtitle: Text(
              _authService.uid.isEmpty ? "Generating key..." : _authService.uid,
              style: const TextStyle(color: Colors.white24, fontSize: 11, fontFamily: 'monospace'),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.copy, size: 16, color: Colors.white12),
              onPressed: _copyUid,
            ),
          ),

          _buildSectionHeader("SYSTEM"),
          _buildSettingsItem(
            Icons.notifications_none, 
            "Notifications", 
            () {}, 
            trailing: _buildSwitch(_isNotificationsEnabled, (v) => _toggleSetting('settings_notif', v))
          ),
          _buildSettingsItem(
            Icons.volume_up_outlined, 
            "Sound Effects", 
            () {}, 
            trailing: _buildSwitch(_isSoundFxEnabled, (v) => _toggleSetting('settings_sfx', v))
          ),
          _buildSettingsItem(
            Icons.music_note_outlined, 
            "Ambient Music", 
            () {}, 
            trailing: _buildSwitch(_isMusicEnabled, (v) => _toggleSetting('settings_music', v))
          ),

          const SizedBox(height: 30),
          const Divider(color: Colors.white10),

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

  Widget _buildSwitch(bool value, ValueChanged<bool> onChanged) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: Colors.white24,
      inactiveThumbColor: Colors.grey,
      inactiveTrackColor: Colors.white10,
    );
  }
}
