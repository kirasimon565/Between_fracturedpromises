import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../app/constants.dart';
import '../../services/auth_service.dart';
import 'between_fractured_promises/lib/services/state_service.dart';
// 🛠️ StoryRuntime is the new brain in the logic folder
import '../../logic/story_runtime.dart'; 
import '../../services/audio_service.dart'; 
import '../../widgets/effects/shatter_effect.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  
  // ✅ These are now retrieved from the sequential boot in main.dart
  final AudioService _audioService = Get.find<AudioService>();
  final StateService _stateService = Get.find<StateService>();
  final StoryRuntime _storyRuntime = Get.find<StoryRuntime>();

  @override
  void initState() {
    super.initState();
    
    // We only register the AuthService if main.dart didn't
    _ensureServicesRegistered();

    // Breathing World Animation (30s loop)
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);
  }

  void _ensureServicesRegistered() {
    if (!Get.isRegistered<AuthService>()) Get.put(AuthService());
    // 🛠️ CRITICAL: Removed StoryEngine and FirestoreService registration.
    // Calling these here was likely triggering the crash.
  }

  void _onShatterStart() {
    _audioService.playShatter();
  }

  void _onShatterComplete() {
    // 🚀 Use the new StateService to decide where to go next
    if (_stateService.isNewUser) {
      Get.offAllNamed(AppRoutes.welcome);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Living Environment
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              double scale = 1.0 + (_bgController.value * 0.08); 
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Image.asset(
              AppConstants.bgSplash, 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
            ),
          ),

          // 2. Logo Sequence
          Center(
            child: ShatterEffect(
              onShatterStart: _onShatterStart, 
              onShatterComplete: _onShatterComplete,
              child: Image.asset(
                'assets/logo/logo.png', 
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

          // 3. Secondary Elements
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
