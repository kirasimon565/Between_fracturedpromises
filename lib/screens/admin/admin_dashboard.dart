import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../theme/colors.dart';
import '../../services/audio_service.dart';

class AdminDashboard extends StatelessWidget {
  final AudioService _audio = Get.find<AudioService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Stack allows us to add a subtle ambient red glow behind the content
      body: Stack(
        children: [
          _buildBackgroundGlow(),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    children: [
                      _buildAdvancedAdminCard(
                        title: "EPISODE UPLOADER",
                        icon: Icons.cloud_upload_outlined,
                        desc: "Inject secure JSON scripts to Firestore cloud nodes.",
                        onTap: () {
                          _audio.playPing();
                          Get.toNamed('/admin/uploader');
                        },
                      ),
                      _buildAdvancedAdminCard(
                        title: "LIVE OPS HOTFIX",
                        icon: Icons.settings_input_component_rounded,
                        desc: "Modify story variables and force-active threads.",
                        onTap: () => _audio.playVibrate(),
                      ),
                      _buildAdvancedAdminCard(
                        title: "STORY ANALYTICS",
                        icon: Icons.query_stats_rounded,
                        desc: "Monitor global player choices and paradox forks.",
                        onTap: () => _audio.playVibrate(),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      Center(
                        child: TextButton(
                          onPressed: () {
                            _audio.playPing();
                            Get.offAllNamed('/home');
                          },
                          child: Text(
                            "TERMINATE SECURE SESSION", 
                            style: TextStyle(
                              color: Colors.red.withOpacity(0.4), 
                              letterSpacing: 4, 
                              fontSize: 10,
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.withOpacity(0.05),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 40, 25, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CORE OPERATIONS",
            style: TextStyle(
              color: Colors.red, 
              fontSize: 10, 
              letterSpacing: 4, 
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "DASHBOARD",
            style: TextStyle(
              color: Colors.white, 
              fontSize: 32, 
              fontWeight: FontWeight.w100, 
              letterSpacing: 2
            ),
          ),
          const SizedBox(height: 15),
          Container(width: 30, height: 1, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildAdvancedAdminCard({
    required String title, 
    required IconData icon, 
    required String desc, 
    required VoidCallback onTap
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.red.withOpacity(0.7), size: 24),
              ),
              title: Text(
                title, 
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 14, 
                  fontWeight: FontWeight.w400, 
                  letterSpacing: 1.5
                )
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  desc, 
                  style: const TextStyle(color: Colors.white24, fontSize: 11, height: 1.4)
                ),
              ),
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}
