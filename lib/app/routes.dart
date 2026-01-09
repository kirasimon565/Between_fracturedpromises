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
import '../screens/profile/profile_screen.dart';
import '../screens/profile/profile_edit_screen.dart';
import '../screens/gallery/gallery_screen.dart';
import '../screens/endgame/endgame_screen.dart';
import '../screens/secret/secret_chat_screen.dart';

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

  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  static const gallery = '/gallery';
  static const endgame = '/endgame';
  static const secret = '/secret';

  static final routes = [
    GetPage(
      name: splash,
      page: () => SplashScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: welcome,
      page: () => WelcomeScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: home,
      page: () => HomeScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: messenger,
      page: () => MessengerListScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: messengerChat,
      page: () => MessengerChatScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: makelove,
      page: () => MakeloveListScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: makeloveChat,
      page: () => MakeloveChatScreen(),
      transition: Transition.zoom,
      transitionDuration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: settings,
      page: () => SettingsScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: adminDialpad,
      page: () => DialpadScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: adminDashboard,
      page: () => AdminDashboard(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: adminUploader,
      page: () => EpisodeUploader(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: profile,
      page: () => ProfileScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: profileEdit,
      page: () => ProfileEditScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: gallery,
      page: () => GalleryScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: endgame,
      page: () => EndgameScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: secret,
      page: () => SecretChatScreen(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 800),
    ),
  ];
}
