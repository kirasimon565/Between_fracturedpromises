import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/routes.dart';
import '../theme/theme.dart';
import 'constants.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🚀 FIX: We move the ThemeService logic inside the Obx to ensure 
    // it only attempts to access the service when GetX is ready.
    return Obx(() {
      // Finding the service inside the builder prevents the "Race Condition" crash.
      final ThemeService themeService = Get.find<ThemeService>();

      return GetMaterialApp(
        title: AppConstants.appName,
        theme: themeService.safeTheme,
        darkTheme: themeService.secretTheme,
        themeMode: themeService.isSecretMode ? ThemeMode.dark : ThemeMode.light,
        initialRoute: AppRoutes.creatorIntro,
        getPages: AppRoutes.routes,
        debugShowCheckedModeBanner: false,
        
        // 🛠️ THE SAFETY SHIELD: 
        // If the app hits another error, this will show the error text 
        // instead of a grey screen, making it easier to debug on your device.
        builder: (context, widget) {
          ErrorWidget.builder = (FlutterErrorDetails details) {
            return Scaffold(
              backgroundColor: Colors.black, // Explicitly black
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      SelectableText(
                        "UI ERROR:\n${details.exception}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                          fontFamily: 'Courier', // Monospace for better readability
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.2),
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                        ),
                        onPressed: () {
                          // Simple way to restart: Re-launch the main app or go to Splash
                          // But since this is a global crash, Get.offAllNamed is safest.
                          Get.offAllNamed(AppRoutes.splash);
                        },
                        child: const Text("RESTART APP"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          };
          return widget!;
        },
      );
    });
  }
}
