import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Get.offAllNamed(AppRoutes.home),
          child: Text("Start Story"),
        ),
      ),
    );
  }
}
