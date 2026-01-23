import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../app/routes.dart';

/// 🎞 24FPS MOTION QUANTIZATION
double q24(double value) {
  const fps = 24.0;
  return (value * fps).roundToDouble() / fps;
}

class CreatorIntroScreen extends StatefulWidget {
  const CreatorIntroScreen({super.key});

  @override
  State<CreatorIntroScreen> createState() => _CreatorIntroScreenState();
}

class _CreatorIntroScreenState extends State<CreatorIntroScreen>
    with TickerProviderStateMixin {
  // 🎬 Animation Controllers
  late AnimationController _dropController;
  late AnimationController _swayController;
  late AnimationController _fadeController;
  late AnimationController _zoomController;
  late AnimationController _blackoutController;
  late AnimationController _letterboxController;

  // 🎞 Animations
  late Animation<double> _drop;
  late Animation<double> _sway;
  late Animation<double> _fadeDisclaimer;
  late Animation<double> _zoom;
  late Animation<double> _blackout;
  late Animation<double> _letterboxHeight;

  // 🔊 Audio
  final AudioPlayer _audio = AudioPlayer();

  bool showDots = false;

  // 🧠 Dynamic studio name
  final String studioName = "BETWEEN\nPRODUCTIONS";

  @override
  void initState() {
    super.initState();

    /// DROP
    _dropController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _drop = Tween<double>(begin: -700, end: 0).animate(
      CurvedAnimation(parent: _dropController, curve: Curves.easeOutCubic),
    );

    /// SWAY
    _swayController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6));
    _sway = Tween<double>(begin: -0.015, end: 0.015).animate(
      CurvedAnimation(parent: _swayController, curve: Curves.easeInOutSine),
    );

    /// DISCLAIMER FADE
    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeDisclaimer =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    /// CAMERA MICRO-ZOOM
    _zoomController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6));
    _zoom = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeOut),
    );

    /// FADE TO BLACK
    _blackoutController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _blackout =
        CurvedAnimation(parent: _blackoutController, curve: Curves.easeInOut);

    /// LETTERBOX BARS
    _letterboxController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _letterboxHeight = Tween<double>(begin: 0, end: 48).animate(
      CurvedAnimation(parent: _letterboxController, curve: Curves.easeOutCubic),
    );

    /// SEQUENCE
    _dropController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        HapticFeedback.mediumImpact();
        await _audio.play(AssetSource('sounds/impact_low.wav'), volume: 0.6);

        _swayController.repeat(reverse: true);
        _zoomController.forward();
        _letterboxController.forward();

        Future.delayed(const Duration(milliseconds: 400), () {
          _fadeController.forward();
          setState(() => showDots = true);
        });
      }
    });

    _dropController.forward();

    /// FINAL TRANSITION
    Timer(const Duration(seconds: 6), () async {
      await _blackoutController.forward();
      Get.offNamed(AppRoutes.splash);
    });
  }

  @override
  void dispose() {
    _audio.dispose();
    _dropController.dispose();
    _swayController.dispose();
    _fadeController.dispose();
    _zoomController.dispose();
    _blackoutController.dispose();
    _letterboxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// CAMERA MICRO-ZOOM (24fps)
          AnimatedBuilder(
            animation: _zoom,
            builder: (_, child) {
              return Transform.scale(
                scale: q24(_zoom.value),
                child: child,
              );
            },
            child: Stack(
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

                /// FILM GRAIN
                const Positioned.fill(child: _FilmGrain()),

                /// SIGN
                AnimatedBuilder(
                  animation: Listenable.merge([_drop, _sway]),
                  builder: (_, __) {
                    return Positioned(
                      top: height * 0.28 + q24(_drop.value),
                      left: 0,
                      right: 0,
                      child: Transform(
                        alignment: Alignment.topCenter,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateZ(q24(_sway.value)),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _Rope(),
                                SizedBox(width: 140),
                                _Rope(),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 48, vertical: 28),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B0B0B),
                                border: Border.all(color: Colors.white12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.9),
                                    blurRadius: 40,
                                    offset: const Offset(0, 32),
                                  ),
                                ],
                              ),
                              child: Text(
                                studioName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
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
                      padding:
                          EdgeInsets.only(bottom: 120, left: 40, right: 40),
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

                /// DOTS
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
          ),

          /// LETTERBOX — TOP
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _letterboxHeight,
              builder: (_, __) {
                return Container(
                  height: _letterboxHeight.value,
                  color: Colors.black,
                );
              },
            ),
          ),

          /// LETTERBOX — BOTTOM
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _letterboxHeight,
              builder: (_, __) {
                return Container(
                  height: _letterboxHeight.value,
                  color: Colors.black,
                );
              },
            ),
          ),

          /// FADE TO BLACK
          Positioned.fill(
            child: FadeTransition(
              opacity: _blackout,
              child: Container(color: Colors.black),
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
        (_) => Container(
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

/// FILM GRAIN
class _FilmGrain extends StatelessWidget {
  const _FilmGrain();

  @override
  Widget build(BuildContext context) {
    final rnd = Random();
    return IgnorePointer(
      child: Opacity(
        opacity: 0.04,
        child: CustomPaint(
          painter: _GrainPainter(rnd),
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  final Random rnd;
  _GrainPainter(this.rnd);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (int i = 0; i < 1200; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          rnd.nextDouble() * size.width,
          rnd.nextDouble() * size.height,
          1,
          1,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
