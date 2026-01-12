import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'colors.dart';

class ThemeService extends GetxService {
  final _isSecretMode = false.obs;
  bool get isSecretMode => _isSecretMode.value;

  ThemeData get safeTheme => ThemeData(
    brightness: Brightness.dark, // Changed from Light to Dark
    primaryColor: AppColors.messengerPrimary,
    scaffoldBackgroundColor: AppColors.messengerBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.messengerPrimary,
      surface: AppColors.messengerBackground,
    ),
  );

  ThemeData get secretTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.makelovePrimary,
    scaffoldBackgroundColor: AppColors.makeloveBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.makelovePrimary,
      surface: AppColors.makeloveBackground,
    ),
  );

  // Logic remains same, but the colors above are now Noir
  void toggleTheme() {
    _isSecretMode.value = !_isSecretMode.value;
    Get.changeTheme(_isSecretMode.value ? secretTheme : safeTheme);
  }
}
