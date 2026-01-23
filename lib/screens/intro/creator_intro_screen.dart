import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🛠️ Required for Haptics
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../app/routes.dart';

class CreatorIntroScreen extends StatefulWidget {
  const CreatorIntroScreen({super.key});

  @override
  State<CreatorIntroScreen> createState() => _CreatorIntroScreenState();
}

class _CreatorIntroScreenState extends State<CreatorIntroScreen> with TickerProviderStateMixin {
  late AnimationController _fallController;
  late AnimationController _swayController;
  late Animation<double> _fallAnimation;
  late Animation<double> _swayAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Fall Animation (Drop from top)
    _fallController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fallAnimation = Tween<double>(begin: -500, end: 0).animate(
      CurvedAnimation(parent: _fallController, curve: Curves.bounceOut),
    );

    // 2. Sway Animation (Continuous)
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _swayAnimation = Tween<double>(begin: -0.04, end: 0.04).animate(
      CurvedAnimation(parent: _swayController, curve: Curves.easeInOutSine),
    );

    // 🛠️ HAPTIC TENSION TRIGGER
    // We listen to the fall. When it hits the bottom (Bounce), we trigger haptics.
    _fallController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // First Impact: The heavy drop hits the end of the rope
        HapticFeedback.heavyImpact(); 
        
        // Second subtle vibration to mimic rope tension/stretching
        Future.delayed(const Duration(milliseconds: 150), () {
          HapticFeedback.selectionClick();
        });

        // Start the swaying now that the sign has "landed"
        _swayController.repeat(reverse: true);
      }
    });

    // Start the fall immediately
    _fallController.forward();

    // 3. Transition to Splash after 5 seconds total
    Timer(const Duration(seconds: 5), () {
      Get.offNamed(AppRoutes.splash); 
    });
  }

  @override
  void dispose() {
    _fallController.dispose();
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // THE HANGING SIGN
          AnimatedBuilder(
            animation: Listenable.merge([_fallAnimation, _swayAnimation]),
            builder: (context, child) {
              return Positioned(
                // Positioned relative to the center of the screen
                top: (MediaQuery.of(context).size.height / 2 - 150) + _fallAnimation.value,
                left: 0,
                right: 0,
                child: Transform(
                  alignment: Alignment.topCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Perspective
                    ..rotateZ(_swayAnimation.value),
                  child: Column(
                    children: [
                      // The Ropes (Two ropes hanging from the top)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 1.5, height: 250, color: Colors.white12),
                          const SizedBox(width: 120),
                          Container(width: 1.5, height: 250, color: Colors.white12),
                        ],
                      ),
                      // The Logo Sign
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0A0A),
                          border: Border.all(color: Colors.white10, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 30,
                              offset: const Offset(0, 20),
                            )
                          ]
                        ),
                        child: const Text(
                          "BETWEEN\nPRODUCTIONS", // Or your specific Name
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            letterSpacing: 10,
                            fontWeight: FontWeight.w100,
                            fontFamily: 'Serif',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // FICTIONAL DISCLAIMER (Bottom Center)
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 100, left: 50, right: 50),
              child: Text(
                "All characters, places, and names are purely fictional, and any resemblance to reality is purely coincidental.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white24, 
                  fontSize: 10, 
                  height: 1.6,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // LOADING DOTS (Bottom Left)
          Positioned(
            bottom: 40,
            left: 40,
            child: Row(
              children: List.generate(3, (index) => _AnimatedDot(index: index)),
            ),
          ),

          // VERSION NUMBER (Bottom Right)
          const Positioned(
            bottom: 40,
            right: 40,
            child: Text(
              "v1.0.0",
              style: TextStyle(
                color: Colors.white10, 
                fontSize: 10, 
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  final int index;
  const _AnimatedDot({required this.index});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _opacity = Tween<double>(begin: 0.05, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.index * 300), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 3,
        height: 3,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      ),
    );
  }
}
