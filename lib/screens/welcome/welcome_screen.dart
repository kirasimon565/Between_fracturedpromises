import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../app/routes.dart';
import '../../app/constants.dart';
import '../../services/audio_service.dart';
import '../../services/state_service.dart';
import 'welcome_widgets.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  final AudioService _audioService = Get.find<AudioService>();
  final StateService _stateService = Get.find<StateService>();

  // Narrative Hook sentences
  final List<String> _sentences = [
    "Between desire and duty, she chose silence.",
    "Between loyalty and betrayal, she found herself lost.",
    "And in the wreckage of love, everyone pays the price."
  ];

  @override
  void initState() {
    super.initState();
    
    // 🔊 Start the Intro Theme music from assets/music/
    _audioService.playIntroTheme();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40), 
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if progress exists to show/hide the Continue button
    bool hasSavedProgress = _stateService.currentEpisodeId.value != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 0 - Background (Ken Burns effect)
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              double scale = 1.0 + (_bgController.value * 0.1);
              double offsetX = (_bgController.value - 0.5) * 20;
              return Transform.translate(
                offset: Offset(offsetX, 0),
                child: Transform.scale(
                  scale: scale,
                  child: Image.asset(
                    AppConstants.bgWelcome, 
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          
          // Layer 1 - Memory Overlay (Vignette + Blur)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),
          ),

          // Layer 2 - Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // 🛠️ Logo Integration (Fade in)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 2000),
                    builder: (context, value, child) {
                       return Opacity(
                         opacity: value,
                         child: child,
                       );
                    },
                    child: Image.asset(
                      'assets/logo/logo.png', // Corrected path
                      width: 240,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // 🛠️ REMOVED: "Fractured Promises" subtitle to clean up UI

                  const Spacer(flex: 1),

                  // 🛠️ NEW: Narrative Hook Box (Glassmorphism Container)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10, width: 0.5),
                    ),
                    child: Column(
                      children: List.generate(_sentences.length, (index) {
                        return FutureBuilder(
                          future: Future.delayed(Duration(milliseconds: 1500 + (index * 2000))), 
                          builder: (context, snapshot) {
                            return AnimatedOpacity(
                              duration: const Duration(milliseconds: 1500),
                              opacity: snapshot.connectionState == ConnectionState.done ? 0.7 : 0.0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Text(
                                  _sentences[index],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 1.5,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // 🛠️ Primary Action (Start Game)
                  WelcomeButton(
                    label: "START GAME",
                    icon: Icons.play_arrow,
                    onPressed: () {
                      _stateService.clearProgress(); // Resets progress for fresh start
                      Get.offAllNamed(AppRoutes.home);
                    },
                  ),

                  const SizedBox(height: 16),

                  // 🛠️ Conditional Continue Button
                  if (hasSavedProgress)
                    WelcomeButton(
                      label: "CONTINUE",
                      onPressed: () => Get.offAllNamed(AppRoutes.home),
                    ),

                  const SizedBox(height: 24),

                  // Settings Link
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.settings),
                    child: Text(
                      "SETTINGS",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 11,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  
                  const Spacer(flex: 1),

                  _BottomPulse(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomPulse extends StatefulWidget {
  @override
  _BottomPulseState createState() => _BottomPulseState();
}

// 🛠️ FIXED: Renamed to match the class name to prevent "Type not found" error
class _BottomPulseState extends State<_BottomPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 4, height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2 + (_controller.value * 0.3)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
