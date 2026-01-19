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
    
    // 🔊 Start the Intro Theme music
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
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // 🛠️ Logo Integration
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
                      width: 220,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Subtitle
                  FutureBuilder(
                    future: Future.delayed(const Duration(milliseconds: 800)),
                    builder: (context, snapshot) {
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 1200),
                        opacity: snapshot.connectionState == ConnectionState.done ? 1.0 : 0.0,
                        child: Text(
                          "Fractured Promises",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                            letterSpacing: 2.5,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 60),

                  // Narrative Hooks
                  ...List.generate(_sentences.length, (index) {
                     return FutureBuilder(
                       future: Future.delayed(Duration(milliseconds: 2500 + (index * 3000))), 
                       builder: (context, snapshot) {
                         return AnimatedOpacity(
                           duration: const Duration(milliseconds: 2000),
                           opacity: snapshot.connectionState == ConnectionState.done ? 0.7 : 0.0,
                           child: Padding(
                             padding: const EdgeInsets.only(bottom: 16),
                             child: Text(
                               _sentences[index],
                               textAlign: TextAlign.center,
                               style: const TextStyle(
                                 color: Colors.white,
                                 fontSize: 14,
                                 height: 1.6,
                                 fontWeight: FontWeight.w300,
                                 letterSpacing: 0.5,
                               ),
                             ),
                           ),
                         );
                       },
                     );
                  }),

                  const Spacer(),

                  // 🛠️ NEW: Primary Action (Start Game)
                  WelcomeButton(
                    label: "START GAME",
                    icon: Icons.play_arrow,
                    onPressed: () {
                      _stateService.clearProgress(); // Logic to start fresh
                      Get.offAllNamed(AppRoutes.home);
                    },
                  ),

                  const SizedBox(height: 20),

                  // 🛠️ NEW: Conditional Continue Button
                  if (hasSavedProgress)
                    WelcomeButton(
                      label: "CONTINUE",
                      onPressed: () => Get.offAllNamed(AppRoutes.home),
                    ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.settings),
                    child: Text(
                      "SETTINGS",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

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
  __BottomPulseState createState() => __PulseDotsState();
}

class __PulseDotsState extends State<_BottomPulse> with SingleTickerProviderStateMixin {
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
