import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../theme/colors.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Phone wallpaper
      body: SafeArea(
        child: Column(
          children: [
            _buildStatusBar(),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                padding: EdgeInsets.all(20),
                children: [
                  _buildAppIcon(
                    "Messenger",
                    Icons.chat_bubble,
                    AppColors.messengerPrimary,
                    () => Get.toNamed(AppRoutes.messenger)
                  ),
                  _buildAppIcon(
                    "Makelove",
                    Icons.favorite,
                    AppColors.makelovePrimary,
                    () => Get.toNamed(AppRoutes.makelove)
                  ),
                  _buildAppIcon(
                    "Settings",
                    Icons.settings,
                    Colors.grey,
                    () => Get.toNamed(AppRoutes.settings)
                  ),
                  // Placeholder apps
                  _buildAppIcon("Photos", Icons.photo, Colors.purple, () {}),
                  _buildAppIcon("Camera", Icons.camera_alt, Colors.grey[800]!, () {}),
                ],
              ),
            ),
            _buildDock(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("9:41", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 16),
              SizedBox(width: 5),
              Icon(Icons.wifi, color: Colors.white, size: 16),
              SizedBox(width: 5),
              Icon(Icons.battery_full, color: Colors.white, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppIcon(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          SizedBox(height: 5),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDock() {
    return Container(
      height: 90,
      color: Colors.white.withOpacity(0.1),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
           Icon(Icons.phone, color: Colors.green, size: 40),
           Icon(Icons.public, color: Colors.blue, size: 40),
           Icon(Icons.message, color: Colors.greenAccent, size: 40),
           Icon(Icons.music_note, color: Colors.redAccent, size: 40),
        ],
      ),
    );
  }
}
