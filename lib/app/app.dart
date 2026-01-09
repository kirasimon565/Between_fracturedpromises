import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/routes.dart';
import '../theme/theme.dart';
import 'constants.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService = Get.find<ThemeService>();

    return Obx(() => GetMaterialApp(
      title: AppConstants.appName,
      theme: themeService.safeTheme,
      darkTheme: themeService.secretTheme,
      themeMode: themeService.isSecretMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    ));
  }
}
