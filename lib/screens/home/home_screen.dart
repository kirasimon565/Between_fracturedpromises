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
  // Use Get.find since services are initialized globally in main.dart
  final AudioService _audioService = Get.find<AudioService>();

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
          Container(color: Colors.black.withOpacity(0.2)),

          SafeArea(
            child: Column(
              children: [
                StatusBar(),
                const SizedBox(height: 20),
                
                // Clock Widget (Atmospheric "Phone" Feel)
                const _ClockWidget(),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                    mainAxisSpacing: 25,
                    children: [
                      AppIcon(
                        label: "Messenger",
                        assetPath: AppConstants.iconMessenger,
                        onTap: () {
                          _audioService.playPing(); // 🔊 Sound feedback
                          Get.toNamed(AppRoutes.messenger);
                        }
                      ),
                      AppIcon(
                        label: "Makelove",
                        assetPath: AppConstants.iconMakelove,
                        onTap: () {
                          _audioService.playPing();
                          Get.toNamed(AppRoutes.makelove);
                        }
                      ),
                      AppIcon(
                        label: "Gallery",
                        assetPath: AppConstants.iconGallery,
                        onTap: () {
                          _audioService.playPing();
                          Get.toNamed(AppRoutes.gallery);
                        }
                      ),
                      AppIcon(
                        label: "Settings",
                        assetPath: AppConstants.iconSettings,
                        onTap: () {
                          _audioService.playPing();
                          Get.toNamed(AppRoutes.settings);
                        }
                      ),
                    ],
                  ),
                ),

                // Lower Dock
                _buildDock(),

                const SizedBox(height: 10),

                // Ambient Design Dots (Strictly for UI aesthetic)
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

  Widget _buildDock() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15), // Glassmorphism dock
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
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
        _audioService.playPing(); // 🔊 Interaction sound
        if (route != null) Get.toNamed(route);
      },
      child: Container(
         width: 55, height: 55,
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(12),
           boxShadow: const [
             BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
           ]
         ),
         child: ClipRRect(
           borderRadius: BorderRadius.circular(12),
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
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Text(
            DateFormat('HH:mm').format(DateTime.now()),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.w200,
              fontFamily: 'Inter',
            ),
          ),
          Text(
            DateFormat('EEEE, MMMM d').format(DateTime.now()).toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 2,
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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
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
      children: List.generate(3, (index) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: Interval(index * 0.2, 0.6 + (index * 0.2), curve: Curves.easeInOut),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 4, height: 4,
            decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle),
          ),
        );
      }),
    );
  }
}
