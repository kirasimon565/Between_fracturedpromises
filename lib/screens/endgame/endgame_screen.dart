import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ending_controller.dart';
import 'ending_summary.dart';
import '../../theme/colors.dart';

class EndgameScreen extends StatelessWidget {
  final EndingController controller = Get.put(EndingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Final descent into blackness
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Subtle red glow if the ending involves Daniel
          gradient: RadialGradient(
            colors: [AppColors.makelovePrimary.withOpacity(0.05), Colors.black],
            radius: 1.5,
          ),
        ),
        child: Column(
          children: [
            const Spacer(flex: 3),
            Obx(() => EndingSummary(ending: controller.ending.value)),
            const Spacer(flex: 2),
            // Minimalist return button
            TextButton(
              onPressed: () => Get.offAllNamed('/home'),
              child: Text(
                "SYSTEM RESET", 
                style: TextStyle(color: Colors.white.withOpacity(0.2), letterSpacing: 4, fontSize: 10)
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
