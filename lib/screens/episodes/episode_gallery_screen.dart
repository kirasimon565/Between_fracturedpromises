import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'episode_controller.dart';

class EpisodeGalleryScreen extends GetView<EpisodeController> {
  const EpisodeGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Background (Optional: Add a blurred version of the cover art)
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset('assets/images/gallery_bg.png', fit: BoxFit.cover),
            ),
          ),

          // 2. The Hanging Sign (Animated)
          const Center(
            child: HangingEpisodeSign(),
          ),

          // 3. Back Button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }
}

class HangingEpisodeSign extends StatefulWidget {
  const HangingEpisodeSign({super.key});

  @override
  State<HangingEpisodeSign> createState() => _HangingEpisodeSignState();
}

class _HangingEpisodeSignState extends State<HangingEpisodeSign>
    with SingleTickerProviderStateMixin {
  late AnimationController _swingController;
  late Animation<double> _swingAnimation;

  @override
  void initState() {
    super.initState();
    _swingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Using a curved animation to simulate gravity (slower at the ends)
    _swingAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _swingController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _swingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _swingAnimation,
      builder: (context, child) {
        return Transform(
          // Set alignment to the top center so it swings from the "nail"
          alignment: Alignment.topCenter,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateZ(_swingAnimation.value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The Rope
              Container(
                width: 2,
                height: 150,
                color: Colors.white54,
              ),
              // The Sign
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  border: Border.all(color: Colors.white24, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "EPISODE 01",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "THE POLISHED MIRROR",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontFamily: 'Didot',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // The Download Button (Middle of the sign)
                    ElevatedButton(
                      onPressed: () {
                        // Trigger download logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: const Text("DOWNLOAD", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
