import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'colors.dart';

class ThemeService extends GetxService {
  final _isSecretMode = false.obs;
  bool get isSecretMode => _isSecretMode.value;

  // FIX: Added the specific method the screens are calling
  void setSecretMode(bool enabled) {
    _isSecretMode.value = enabled;
    Get.changeTheme(enabled ? secretTheme : safeTheme);
  }

  ThemeData get safeTheme => ThemeData(
    brightness: Brightness.dark,
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

  void toggleTheme() {
    setSecretMode(!_isSecretMode.value);
  }
}
