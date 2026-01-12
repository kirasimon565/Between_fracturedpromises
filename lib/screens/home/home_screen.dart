import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/constants.dart';
import '../../app/routes.dart';
import 'app_icon.dart';
import 'status_bar.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // WALLPAPER: Your specific art
          Positioned.fill(
            child: Image.asset(
              AppConstants.bgHome,
              fit: BoxFit.cover,
            ),
          ),
          // Darken wallpaper slightly to make icons readable
          Container(color: Colors.black.withOpacity(0.2)),
          
          SafeArea(
            child: Column(
              children: [
                StatusBar(),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                    mainAxisSpacing: 25,
                    children: [
                      AppIcon(
                        label: "Messenger",
                        assetPath: AppConstants.iconMessenger, // Use your PNG
                        onTap: () => Get.toNamed(AppRoutes.messenger)
                      ),
                      AppIcon(
                        label: "Makelove",
                        assetPath: AppConstants.iconMakelove, // Use your PNG
                        onTap: () => Get.toNamed(AppRoutes.makelove)
                      ),
                      AppIcon(
                        label: "Settings",
                        assetPath: AppConstants.iconSettings,
                        onTap: () => Get.toNamed(AppRoutes.settings)
                      ),
                      AppIcon(
                        label: "Gallery",
                        assetPath: AppConstants.iconGallery,
                        onTap: () => Get.toNamed(AppRoutes.gallery)
                      ),
                      AppIcon(
                        label: "Camera", 
                        assetPath: AppConstants.iconCamera, 
                        onTap: () {}
                      ),
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
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 20),
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15), // Glassmorphism dock
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
           _dockItem(AppConstants.iconPhone),
           _dockItem(AppConstants.iconBrowser),
           _dockItem(AppConstants.iconMessenger),
           _dockItem(AppConstants.iconApp), // Your music/theme icon
        ],
      ),
    );
  }

  Widget _dockItem(String asset) {
    return Image.asset(asset, width: 55, height: 55);
  }
}
