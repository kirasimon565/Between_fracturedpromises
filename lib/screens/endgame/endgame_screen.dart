import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ending_controller.dart';
import 'ending_summary.dart';
import '../../theme/colors.dart';
import '../../services/audio_service.dart';

class EndgameScreen extends StatefulWidget {
  @override
  State<EndgameScreen> createState() => _EndgameScreenState();
}

class _EndgameScreenState extends State<EndgameScreen> with SingleTickerProviderStateMixin {
  final EndingController controller = Get.put(EndingController());
  final AudioService _audio = Get.find<AudioService>();
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    // 🔊 Stop all ambient game music and play a low, final drone or silence
    _audio.stopAll(); 
    
    _fadeController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 4)
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeController,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            // Subtle red pulse gradient for the "Noir" conclusion
            gradient: RadialGradient(
              center: const Alignment(0, -0.2),
              colors: [
                Colors.red.withOpacity(0.03), 
                Colors.black,
              ],
              radius: 1.2,
            ),
          ),
          child: Column(
            children: [
              const Spacer(flex: 4),
              
              // 🧪 The Final Summary (Fractured Truth)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Obx(() => EndingSummary(
                  ending: controller.ending.value,
                  // We add a 'glitch' effect trigger inside EndingSummary
                )),
              ),

              const Spacer(flex: 3),

              // 🛠️ The "Post-Mortem" Stats (Optional, adds professional feel)
              _buildFinalStats(),

              const Spacer(flex: 2),

              // 🏁 System Reset (The only way out)
              GestureDetector(
                onTap: () {
                  _audio.playVibrate(); // 🔊 Tactile feedback for reset
                  Get.offAllNamed('/home');
                },
                child: Column(
                  children: [
                    Text(
                      "TERMINATE SESSION",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        letterSpacing: 8,
                        fontSize: 10,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 40,
                      height: 1,
                      color: Colors.red.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalStats() {
    return Column(
      children: [
        Text(
          "TRUTH REVEALED: ${controller.truthPercentage}%",
          style: TextStyle(
            color: Colors.white.withOpacity(0.15),
            fontSize: 9,
            letterSpacing: 2,
            fontFamily: 'monospace'
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "PARADOX RESOLVED: ${controller.paradoxResolved ? 'YES' : 'NO'}",
          style: TextStyle(
            color: Colors.white.withOpacity(0.15),
            fontSize: 9,
            letterSpacing: 2,
            fontFamily: 'monospace'
          ),
        ),
      ],
    );
  }
}
