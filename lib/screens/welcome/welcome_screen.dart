import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import 'welcome_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: WelcomeButton(
          label: "Start Story",
          onPressed: () => Get.offAllNamed(AppRoutes.home),
        ),
      ),
    );
  }
}
