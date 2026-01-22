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
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.routes,
        debugShowCheckedModeBanner: false,
        
        // 🛠️ THE SAFETY SHIELD: 
        // If the app hits another error, this will show the error text 
        // instead of a grey screen, making it easier to debug on your device.
        builder: (context, widget) {
          ErrorWidget.builder = (FlutterErrorDetails details) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SelectableText(
                    "UI CRASH: ${details.exception}",
                    style: const TextStyle(color: Colors.redAccent, fontSize: 14),
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
