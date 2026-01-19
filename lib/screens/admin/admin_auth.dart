import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../services/audio_service.dart';
import '../../theme/colors.dart';

class AdminAuth extends StatefulWidget {
  @override
  _AdminAuthState createState() => _AdminAuthState();
}

class _AdminAuthState extends State<AdminAuth> with SingleTickerProviderStateMixin {
  final AudioService _audio = Get.find<AudioService>();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Play a subtle "System Entry" sound
    WidgetsBinding.instance.addPostFrameCallback((_) => _audio.playPing());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background: Subtle Red Glow (Admin Identity)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.red.withOpacity(0.05), Colors.black],
                  radius: 1.0,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  
                  // Status Header
                  Row(
                    children: [
                      ScaleTransition(
                        scale: Tween(begin: 1.0, end: 1.2).animate(_pulseController),
                        child: Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "ADMINISTRATIVE OVERRIDE ACTIVE",
                        style: TextStyle(color: Colors.red, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  const Text(
                    "SYSTEM\nACCESS",
                    style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w100, letterSpacing: 4),
                  ),
                  
                  const SizedBox(height: 10),
                  Container(width: 40, height: 1, color: Colors.white24),
                  const SizedBox(height: 50),

                  // Admin Action Cards
                  _buildAdminCard(
                    "DATABASE BYPASS", 
                    "Unlock all hidden gallery fragments instantly.", 
                    Icons.folder_open_rounded,
                    () {
                      _audio.playVibrate();
                      Get.snackbar("ADMIN", "ALL MEDIA FRAGMENTS UNLOCKED", colorText: Colors.red, backgroundColor: Colors.black);
                    }
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildAdminCard(
                    "NARRATIVE RESET", 
                    "Wipe all choice history and return to inception.", 
                    Icons.restart_alt_rounded,
                    () {
                      _audio.playVibrate();
                      _showResetWarning();
                    }
                  ),

                  const Spacer(),

                  // Exit Administrative Mode
                  Center(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "EXIT SECURE GATEWAY",
                        style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10, letterSpacing: 4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(String title, String desc, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.red.withOpacity(0.7), size: 28),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResetWarning() {
    Get.defaultDialog(
      title: "WARNING",
      middleText: "This will permanently wipe all story progress.",
      backgroundColor: Colors.black,
      titleStyle: const TextStyle(color: Colors.red),
      middleTextStyle: const TextStyle(color: Colors.white70),
      textConfirm: "PROCEED",
      textCancel: "ABORT",
      confirmTextColor: Colors.red,
      cancelTextColor: Colors.white,
      buttonColor: Colors.transparent,
      onConfirm: () {
        // Add your logic to clear SharedPreferences here
        Get.back();
      },
    );
  }
}
