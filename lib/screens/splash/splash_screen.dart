import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes.dart';
import '../../app/constants.dart'; // Added to access your image paths
import '../../services/auth_service.dart';
import '../../services/state_service.dart';
import '../../services/firestore_service.dart';
import '../../services/story_engine.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Initialize services
    await Get.putAsync(() => StateService().init());
    Get.put(AuthService());
    Get.put(FirestoreService());
    Get.put(StoryEngine());

    // Dramatic pause to let the player see your art
    await Future.delayed(const Duration(seconds: 3));
    
    // FIX: Redirect to Welcome Screen instead of skipping to Home
    Get.offAllNamed(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND: Your cinematic 'Broken Glass' art
          Image.asset(
            AppConstants.bgSplash,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          
          // OVERLAY: Dark vignette to make text readable
          Container(color: Colors.black.withOpacity(0.4)),

          // CONTENT
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Replace the generic icon with your App Logo if available
                // For now, we use a clean text-based branding
                const Text(
                  "BETWEEN",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "FRACTURED PROMISES",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 60),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white24),
                  strokeWidth: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
