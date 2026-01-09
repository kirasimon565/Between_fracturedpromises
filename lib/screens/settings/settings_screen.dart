import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';

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
      Get.toNamed(AppRoutes.adminDialpad);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Account"),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notifications"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text("Version"),
            subtitle: Text("1.0.0 (Build 100)"),
            onTap: _handleVersionTap, // Secret gesture
          ),
        ],
      ),
    );
  }
}
