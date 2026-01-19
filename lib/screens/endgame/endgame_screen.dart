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
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Obx(() {
                  // 🛠️ FIX: Added null check for the summary
                  if (controller.ending.value == null) return const SizedBox.shrink();
                  return EndingSummary(
                    ending: controller.ending.value!,
                  );
                }),
              ),

              const Spacer(flex: 3),
              _buildFinalStats(),
              const Spacer(flex: 2),

              GestureDetector(
                onTap: () {
                  _audio.playVibrate();
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
    return Obx(() => Column(
      children: [
        Text(
          "TRUTH REVEALED: ${controller.truthPercentage.value}%",
          style: TextStyle(
            color: Colors.white.withOpacity(0.15),
            fontSize: 9,
            letterSpacing: 2,
            fontFamily: 'monospace'
          ),
        ),
        const SizedBox(height: 8),
        Text(
          // 🛠️ FIX: Added .value to RxBool
          "PARADOX RESOLVED: ${controller.paradoxResolved.value ? 'YES' : 'NO'}",
          style: TextStyle(
            color: Colors.white.withOpacity(0.15),
            fontSize: 9,
            letterSpacing: 2,
            fontFamily: 'monospace'
          ),
        ),
      ],
    ));
  }
}
