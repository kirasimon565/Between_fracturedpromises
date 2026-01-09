import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import 'welcome_widgets.dart';

import '../../app/constants.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppConstants.logoApp, width: 150),
            SizedBox(height: 50),
            WelcomeButton(
              label: "Start Story",
              onPressed: () => Get.offAllNamed(AppRoutes.home),
            ),
          ],
        ),
      ),
    );
  }
}
