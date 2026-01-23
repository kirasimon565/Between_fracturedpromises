import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';

class CreatorIntroScreen extends StatefulWidget {
  const CreatorIntroScreen({super.key});

  @override
  State<CreatorIntroScreen> createState() => _CreatorIntroScreenState();
}

class _CreatorIntroScreenState extends State<CreatorIntroScreen>
    with TickerProviderStateMixin {
  late AnimationController _dropController;
  late AnimationController _swayController;
  late AnimationController _fadeController;

  late Animation<double> _drop;
  late Animation<double> _sway;
  late Animation<double> _fadeDisclaimer;

  bool showDots = false;

  @override
  void initState() {
    super.initState();

    /// SIGN DROP — heavy gravity (cinematic)
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _drop = Tween<double>(begin: -650, end: 0).animate(
      CurvedAnimation(
        parent: _dropController,
        curve: Curves.easeOutCubic,
      ),
    );

    /// SWAY — slow & restrained
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _sway = Tween<double>(begin: -0.015, end: 0.015).animate(
      CurvedAnimation(
        parent: _swayController,
        curve: Curves.easeInOutSine,
      ),
    );

    /// DISCLAIMER FADE
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeDisclaimer =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    /// SEQUENCE
    _dropController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.mediumImpact();
        _swayController.repeat(reverse: true);

        Future.delayed(const Duration(milliseconds: 400), () {
          _fadeController.forward();
          setState(() => showDots = true);
        });
      }
    });

    _dropController.forward();

    /// TRANSITION TO SPLASH
    Timer(const Duration(seconds: 7), () {
      Get.offNamed(AppRoutes.splash);
    });
  }

  @override
  void dispose() {
    _dropController.dispose();
    _swayController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// VIGNETTE
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.2,
                  colors: [
                    Colors.black,
                    Colors.black.withOpacity(0.92),
                  ],
                ),
              ),
            ),
          ),

          /// HANGING SIGN
          AnimatedBuilder(
            animation: Listenable.merge([_drop, _sway]),
            builder: (_, __) {
              return Positioned(
                top: height * 0.28 + _drop.value,
                left: 0,
                right: 0,
                child: Transform(
                  alignment: Alignment.topCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateZ(_sway.value),
                  child: Column(
                    children: [
                      /// ROPES
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          _Rope(),
                          SizedBox(width: 140),
                          _Rope(),
                        ],
                      ),

                      /// SIGN BOARD
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 28,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B0B0B),
                          border: Border.all(
                            color: Colors.white12,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.9),
                              blurRadius: 40,
                              offset: const Offset(0, 32),
                            ),
                          ],
                        ),
                        child: const Text(
                          "BETWEEN\nPRODUCTIONS",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            height: 1.4,
                            letterSpacing: 8,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          /// DISCLAIMER
          Align(
            alignment: Alignment.bottomCenter,
            child: FadeTransition(
              opacity: _fadeDisclaimer,
              child: const Padding(
                padding: EdgeInsets.only(bottom: 120, left: 40, right: 40),
                child: Text(
                  "All characters, places, and names are purely fictional.\nAny resemblance to reality is coincidental.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    height: 1.6,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ),

          /// LOADING DOTS (TEMPORARY)
          if (showDots)
            const Positioned(
              bottom: 40,
              left: 40,
              child: _CinematicDots(),
            ),

          /// VERSION
          const Positioned(
            bottom: 40,
            right: 40,
            child: Text(
              "v1.0.4-alpha",
              style: TextStyle(
                color: Colors.white12,
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

/// ROPE
class _Rope extends StatelessWidget {
  const _Rope();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.2,
      height: 260,
      color: Colors.white10,
    );
  }
}

/// DOTS
class _CinematicDots extends StatelessWidget {
  const _CinematicDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Colors.white70,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
