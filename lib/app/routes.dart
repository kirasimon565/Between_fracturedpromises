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
import '../screens/admin/episode_uploader.dart';
import '../screens/messenger/messenger_chat_screen.dart';
import '../screens/makelove/makelove_chat_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const home = '/home';
  static const messenger = '/messenger';
  static const makelove = '/makelove';
  static const settings = '/settings';
  static const adminDialpad = '/admin/dialpad';
  static const adminDashboard = '/admin/dashboard';
  static const messengerChat = '/messenger/chat';
  static const makeloveChat = '/makelove/chat';
  static const adminUploader = '/admin/uploader';

  static final routes = [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: welcome, page: () => WelcomeScreen()),
    GetPage(name: home, page: () => HomeScreen()),
    GetPage(name: messenger, page: () => MessengerListScreen()),
    GetPage(name: messengerChat, page: () => MessengerChatScreen()),
    GetPage(name: makelove, page: () => MakeloveListScreen()),
    GetPage(name: makeloveChat, page: () => MakeloveChatScreen()),
    GetPage(name: settings, page: () => SettingsScreen()),
    GetPage(name: adminDialpad, page: () => DialpadScreen()),
    GetPage(name: adminDashboard, page: () => AdminDashboard()),
    GetPage(name: adminUploader, page: () => EpisodeUploader()),
  ];
}
