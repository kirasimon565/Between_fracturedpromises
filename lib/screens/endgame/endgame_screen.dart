import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ending_controller.dart';
import 'ending_summary.dart';

class EndgameScreen extends StatelessWidget {
  final EndingController controller = Get.put(EndingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Obx(() => EndingSummary(ending: controller.ending.value)),
            Spacer(),
            ElevatedButton(
              onPressed: () => Get.offAllNamed('/home'),
              child: Text("Return to Home")
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
