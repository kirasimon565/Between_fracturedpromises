import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/messenger/messenger_list_screen.dart';
import '../screens/makelove/makelove_list_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/admin/dialpad_screen.dart';
import '../screens/admin/admin_dashboard.dart';

class AppRoutes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const home = '/home';
  static const messenger = '/messenger';
  static const makelove = '/makelove';
  static const settings = '/settings';
  static const adminDialpad = '/admin/dialpad';
  static const adminDashboard = '/admin/dashboard';

  static final routes = [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: welcome, page: () => WelcomeScreen()),
    GetPage(name: home, page: () => HomeScreen()),
    GetPage(name: messenger, page: () => MessengerListScreen()),
    GetPage(name: makelove, page: () => MakeloveListScreen()),
    GetPage(name: settings, page: () => SettingsScreen()),
    GetPage(name: adminDialpad, page: () => DialpadScreen()),
    GetPage(name: adminDashboard, page: () => AdminDashboard()),
  ];
}
