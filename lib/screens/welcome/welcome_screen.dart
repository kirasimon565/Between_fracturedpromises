import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../app/constants.dart';
import 'welcome_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND: Your Desolate Landscape art
          Image.asset(
            AppConstants.bgWelcome,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          
          // OVERLAY: Dark gradient to make the UI pop
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end, // Push content to bottom
              children: [
                const Text(
                  "Between desire and duty, she chose silence.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'PlayfairDisplay', // Matches the new noir style
                  ),
                ),
                const SizedBox(height: 40),
                WelcomeButton(
                  label: "CONNECT TO SYSTEM", // More thematic than "Start Story"
                  onPressed: () => Get.offAllNamed(AppRoutes.home),
                ),
                const SizedBox(height: 80), // Space from bottom
              ],
            ),
          ),
        ],
      ),
    );
  }
}
