import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../app/constants.dart';
import '../../services/auth_service.dart';
import '../../services/state_service.dart';
import '../../logic/story_runtime.dart'; 
import '../../services/audio_service.dart'; 
import '../../widgets/effects/shatter_effect.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  
  // 🛠️ FIX: Use Getters instead of 'final' variables. 
  // This prevents the "Not Found" error by fetching them only when used.
  AudioService get _audioService => Get.find<AudioService>();
  StateService get _stateService => Get.find<StateService>();
  StoryRuntime get _storyRuntime => Get.find<StoryRuntime>();

  @override
  void initState() {
    super.initState();
    
    _ensureServicesRegistered();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);

    // 🛠️ SAFETY: Use a small delay to ensure main() has finished all 'await' calls
    // before the StoryRuntime tries to load data from Isar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareStory();
    });
  }

  void _prepareStory() {
    try {
      final currentId = _stateService.currentEpisodeId.value;
      _storyRuntime.loadEpisode(currentId);
    } catch (e) {
      debugPrint("⚠️ Story Load Warning: $e");
      // If load fails, we don't crash, we let the user proceed to Welcome
    }
  }

  void _ensureServicesRegistered() {
    if (!Get.isRegistered<AuthService>()) Get.put(AuthService());
  }

  void _onShatterStart() {
    _audioService.playShatter();
  }

  void _onShatterComplete() {
    // 🚀 Decision Logic for the "Hard Path"
    final isAtStart = _stateService.currentSceneId.value == 'scene_1';
    final hasNoData = _stateService.variables.isEmpty;

    if (isAtStart && hasNoData) {
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
          // 1. Living Environment (Background breathing effect)
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

          // 2. Logo Sequence (The Fracture Event)
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

          // 3. Secondary Elements (Loading Pulse)
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
