import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../theme/colors.dart';
import 'app_icon.dart';
import 'status_bar.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Phone wallpaper
      body: Stack(
        children: [
          // Wallpaper
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/default.png',
              fit: BoxFit.cover,
              errorBuilder: (c,e,s) => Container(color: Colors.black),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                StatusBar(),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 4,
                    padding: EdgeInsets.all(20),
                    children: [
                      AppIcon(
                        label: "Messenger",
                        icon: Icons.chat_bubble,
                        color: AppColors.messengerPrimary,
                        onTap: () => Get.toNamed(AppRoutes.messenger)
                      ),
                      AppIcon(
                        label: "Makelove",
                        icon: Icons.favorite,
                        color: AppColors.makelovePrimary,
                        onTap: () => Get.toNamed(AppRoutes.makelove)
                      ),
                      AppIcon(
                        label: "Settings",
                        icon: Icons.settings,
                        color: Colors.grey,
                        onTap: () => Get.toNamed(AppRoutes.settings)
                      ),
                      AppIcon(
                        label: "Gallery",
                        icon: Icons.photo_library,
                        color: Colors.purple,
                        onTap: () => Get.toNamed(AppRoutes.gallery)
                      ),
                      // Placeholder apps
                      AppIcon(label: "Camera", icon: Icons.camera_alt, color: Colors.grey[800]!, onTap: () {}),
                    ],
                  ),
                ),
                _buildDock(),
              ],
            ),
          ),
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
