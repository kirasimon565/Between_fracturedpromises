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
    // Use Fade for the initial entry into the game
    GetPage(
      name: splash, 
      page: () => SplashScreen(), 
      transition: Transition.fade,
    ),
    GetPage(
      name: welcome, 
      page: () => WelcomeScreen(), 
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: home, 
      page: () => HomeScreen(), 
      transition: Transition.cupertino,
    ),
    
    // Standard "Safe" App Transitions
    GetPage(
      name: messenger, 
      page: () => MessengerListScreen(), 
      transition: Transition.cupertino,
    ),
    GetPage(
      name: messengerChat, 
      page: () => MessengerChatScreen(), 
      transition: Transition.rightToLeftWithFade,
    ),

    // INTENSE: The "Secret" App Transition (Zoom)
    GetPage(
      name: makelove, 
      page: () => MakeloveListScreen(), 
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: makeloveChat, 
      page: () => MakeloveChatScreen(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 600),
      curve: Curves.fastOutSlowIn,
    ),

    // MYSTERIOUS: Fade transition for Secret Chat
    GetPage(
      name: secret, 
      page: () => SecretChatScreen(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 800),
    ),

    // Utilities and Admin
    GetPage(name: settings, page: () => SettingsScreen(), transition: Transition.downToUp),
    GetPage(name: adminDialpad, page: () => DialpadScreen(), transition: Transition.noTransition),
    GetPage(name: adminDashboard, page: () => AdminDashboard(), transition: Transition.fade),
    GetPage(name: adminUploader, page: () => EpisodeUploader(), transition: Transition.rightToLeft),
    
    GetPage(name: profile, page: () => ProfileScreen(), transition: Transition.cupertino),
    GetPage(name: profileEdit, page: () => ProfileEditScreen(), transition: Transition.cupertino),
    GetPage(name: gallery, page: () => GalleryScreen(), transition: Transition.zoom),
    GetPage(name: endgame, page: () => EndgameScreen(), transition: Transition.fadeIn),
  ];
}
