import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../app/constants.dart';
import '../../services/auth_service.dart';
import '../../services/state_service.dart';
import '../../services/firestore_service.dart';
import '../../services/story_engine.dart';
import '../../services/audio_service.dart'; 
import '../../widgets/effects/shatter_effect.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  // Get reference to the AudioService
  late AudioService _audioService;

  @override
  void initState() {
    super.initState();
    _initServices();

    // Breathing World Animation (30s loop)
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);
  }

  Future<void> _initServices() async {
    // Initialize core services
    await Get.putAsync(() => StateService().init());
    Get.put(AuthService());
    Get.put(FirestoreService());
    Get.put(StoryEngine());
    
    // Initialize and find the AudioService
    _audioService = Get.put(AudioService()); 
  }

  void _onShatterStart() {
    // 🔊 TRIGGER: Play the glass shatter FX from assets/fx/
    _audioService.playShatter();
  }

  void _onShatterComplete() {
    // Transition to welcome screen after the physics event
    Get.offAllNamed(AppRoutes.welcome);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Noir base
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Living Environment (Background breathing effect)
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              double scale = 1.0 + (_bgController.value * 0.08); // Subtle scale zoom
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Image.asset(
              AppConstants.bgSplash, 
              fit: BoxFit.cover,
            ),
          ),

          // 2. Logo Sequence (The Fracture Event)
          Center(
            child: ShatterEffect(
              // 🛠️ Audio Integration: play sound when shattering starts
              onShatterStart: _onShatterStart, 
              onShatterComplete: _onShatterComplete,
              child: Image.asset(
                'assets/logo/logo.png', // Path from your pubspec
                width: 280,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    "BETWEEN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      letterSpacing: 8.0,
                      fontFamily: 'Didot',
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. Secondary Elements (Loading Sync)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: _PulseDots(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDots extends StatefulWidget {
  @override
  __PulseDotsState createState() => __PulseDotsState();
}

class __PulseDotsState extends State<_PulseDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
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
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
             // Staggered Opacity math
             double offset = index * 0.3;
             double value = math.sin((_controller.value * 2 * math.pi) - offset);
             double opacity = (value * 0.5 + 0.5).clamp(0.2, 1.0);

             return Container(
               margin: const EdgeInsets.symmetric(horizontal: 4),
               width: 6,
               height: 6,
               decoration: BoxDecoration(
                 color: Colors.white.withOpacity(opacity),
                 shape: BoxShape.circle,
               ),
             );
          },
        );
      }),
    );
  }
}
