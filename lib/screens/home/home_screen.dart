import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/constants.dart';
import '../../app/routes.dart';
import 'app_icon.dart';
import 'status_bar.dart';
import '../../theme/colors.dart';
import '../../services/audio_service.dart';

class HomeScreen extends StatelessWidget {
  final AudioService _audioService = Get.find<AudioService>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 0: Wallpaper
          Image.asset(
            AppConstants.bgHome,
            fit: BoxFit.cover,
          ),
          
          // Layer 1: Noir Darken Overlay
          Container(color: Colors.black.withOpacity(0.3)),

          SafeArea(
            child: Column(
              children: [
                StatusBar(),
                const SizedBox(height: 20),
                
                // Clock Widget
                const _ClockWidget(),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 4, // 4 apps per row as seen in mobile home screens
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                    mainAxisSpacing: 35, // Space between rows
                    crossAxisSpacing: 20, // Space between icons
                    children: [
                      _buildMainApp(
                        label: "Messenger",
                        asset: AppConstants.iconMessenger,
                        route: AppRoutes.messenger,
                      ),
                      _buildMainApp(
                        label: "Makelove",
                        asset: AppConstants.iconMakelove,
                        route: AppRoutes.makelove,
                      ),
                      _buildMainApp(
                        label: "Gallery",
                        asset: AppConstants.iconGallery,
                        route: AppRoutes.gallery,
                      ),
                      _buildMainApp(
                        label: "Settings",
                        asset: AppConstants.iconSettings,
                        route: AppRoutes.settings,
                      ),
                    ],
                  ),
                ),

                // Lower Dock (Glassmorphism effect)
                _buildDock(),

                const SizedBox(height: 10),

                // Ambient Design Dots
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: _AmbientDots(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build main grid apps with labels
  Widget _buildMainApp({required String label, required String asset, required String route}) {
    return AppIcon(
      label: label,
      assetPath: asset,
      onTap: () {
        _audioService.playPing();
        Get.toNamed(route); // Named navigation using GetX
      },
    );
  }

  Widget _buildDock() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      height: 95,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12), // Translucent glass effect
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
           _dockItem(AppConstants.iconPhone),
           _dockItem(AppConstants.iconBrowser),
           _dockItem(AppConstants.iconMessenger, route: AppRoutes.messenger),
           _dockItem(AppConstants.iconApp), 
        ],
      ),
    );
  }

  Widget _dockItem(String asset, {String? route}) {
    return GestureDetector(
      onTap: () {
        _audioService.playPing();
        if (route != null) Get.toNamed(route);
      },
      child: Container(
         width: 60, height: 60,
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(16),
           boxShadow: const [
             BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 3))
           ]
         ),
         child: ClipRRect(
           borderRadius: BorderRadius.circular(16),
           child: Image.asset(asset, fit: BoxFit.cover),
         ),
      ),
    );
  }
}

class _ClockWidget extends StatelessWidget {
  const _ClockWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 20),
      child: Column(
        children: [
          Text(
            DateFormat('HH:mm').format(DateTime.now()),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 72, // Larger atmospheric font
              fontWeight: FontWeight.w100, // Ultra thin for Noir feel
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 5),
          Text(
            DateFormat('EEEE, MMMM d').format(DateTime.now()).toUpperCase(),
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientDots extends StatefulWidget {
  const _AmbientDots();

  @override
  __AmbientDotsState createState() => __AmbientDotsState();
}

class __AmbientDotsState extends State<_AmbientDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(2, (index) { // Reduced to 2 dots to match common UI indicators
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: Interval(index * 0.3, 0.7 + (index * 0.3), curve: Curves.easeInOut),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: index == 0 ? Colors.white : Colors.white24, // First dot active
              shape: BoxShape.circle
            ),
          ),
        );
      }),
    );
  }
}
