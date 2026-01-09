import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'colors.dart';

class ThemeService extends GetxService {
  final _isSecretMode = false.obs;
  bool get isSecretMode => _isSecretMode.value;

  void toggleTheme() {
    _isSecretMode.value = !_isSecretMode.value;
    Get.changeTheme(_isSecretMode.value ? secretTheme : safeTheme);
  }

  void setSecretMode(bool isSecret) {
    _isSecretMode.value = isSecret;
    Get.changeTheme(isSecret ? secretTheme : safeTheme);
  }

  ThemeData get safeTheme => ThemeData(
    primaryColor: AppColors.messengerPrimary,
    scaffoldBackgroundColor: AppColors.messengerBackground,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.messengerPrimary,
      surface: AppColors.messengerBackground,
    ),
  );

  ThemeData get secretTheme => ThemeData(
    primaryColor: AppColors.makelovePrimary,
    scaffoldBackgroundColor: AppColors.makeloveBackground,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.makelovePrimary,
      surface: AppColors.makeloveBackground,
    ),
  );
}
