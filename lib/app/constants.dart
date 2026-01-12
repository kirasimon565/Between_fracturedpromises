class AppConstants {
  static const String appName = "Between";
  static const String version = "1.0.0";
  static const int buildNumber = 101; 
  static const String contactEmail = "support@between.com";

  // Assets - Avatars (Master Portraits for Face Swap)
  static const String avatarClaire = 'assets/avatars/claire.png';
  static const String avatarDaniel = 'assets/avatars/daniel.png';
  static const String avatarEthan = 'assets/avatars/ethan.png';
  static const String avatarLiam = 'assets/avatars/liam.png';
  static const String avatarNadia = 'assets/avatars/nadia.png';
  static const String avatarOlivia = 'assets/avatars/olivia.png';
  static const String avatarPlaceholder = 'assets/avatars/placeholder.png';

  // Assets - Backgrounds
  static const String bgSplash = 'assets/backgrounds/bg_splash.jpg';
  static const String bgWelcome = 'assets/backgrounds/bg_welcome.jpg';
  static const String bgHome = 'assets/backgrounds/bg_home.jpg';
  static const String bgSecret = 'assets/backgrounds/bg_secret.jpg';
  static const String bgEndgame = 'assets/backgrounds/bg_endgame.jpg';

  // Assets - Badges
  static const String badgeBlue = 'assets/badges/badge_blue.png';
  static const String badgeOrange = 'assets/badges/badge_orange.png';
  static const String badgeCustom = 'assets/badges/badge_custom.png';
  static const String badgeVerified = 'assets/badges/badge_custom.png'; // Added for profile verification

  // Assets - FX
  static const String fxShatter = 'assets/fx/glass_shatter.mp3';
  static const String fxPing = 'assets/fx/msg_ping.mp3';
  static const String fxSend = 'assets/fx/msg_send.mp3';
  static const String fxTyping = 'assets/fx/typing.mp3';
  static const String fxVibrate = 'assets/fx/vibrate.mp3';

  // Assets - Gallery (Standard & Secret/Endings)
  static const String galleryClaire = 'assets/gallery/claire/main.png';
  static const String galleryDaniel = 'assets/gallery/daniel/main.png';
  static const String galleryEthan = 'assets/gallery/ethan/main.png';
  static const String galleryLiam = 'assets/gallery/liam/main.png';
  static const String galleryNadia = 'assets/gallery/nadia/main.png';
  static const String galleryOlivia = 'assets/gallery/olivia/main.png';
  
  // Missing constants flagged by the compiler
  static const String gallerySecret1 = 'assets/gallery/claire/main.png'; 
  static const String gallerySecret2 = 'assets/gallery/olivia/main.png';
  static const String galleryEndingFractured = 'assets/backgrounds/bg_endgame.jpg';

  // Assets - Icons (Simulation Apps & UI)
  static const String iconMessenger = 'assets/icons/app_messenger.png';
  static const String iconMakelove = 'assets/icons/app_makelove.png';
  static const String iconSettings = 'assets/icons/settings_icon.png';
  static const String iconBack = 'assets/icons/back_arrow.png';
  static const String iconNotifBlue = 'assets/icons/notif_dot_blue.png';
  static const String iconNotifRed = 'assets/icons/notif_dot_red.png';
  
  // Dock Icons flagged by the compiler
  static const String iconGallery = 'assets/icons/app_messenger.png'; 
  static const String iconCamera = 'assets/icons/app_makelove.png';   
  static const String iconPhone = 'assets/icons/app_messenger.png';    
  static const String iconBrowser = 'assets/icons/app_messenger.png';  
  static const String iconApp = 'assets/icons/settings_icon.png';      

  // Assets - Logo
  static const String logoMain = 'assets/logo/logo.png';
  static const String logoAlt = 'assets/logo/logo_alt.png';
  static const String logoHeart = 'assets/logo/heart_icon.png';

  // Assets - Music
  static const String musicIntro = 'assets/music/theme_intro.mp3';
  static const String musicChat = 'assets/music/theme_chat.mp3';
  static const String musicTragedy = 'assets/music/theme_tragedy.mp3';

  /// Helper to get avatar path dynamically
  static String getAvatarPath(String name) {
    switch (name.toLowerCase()) {
      case 'claire': return avatarClaire;
      case 'daniel': return avatarDaniel;
      case 'ethan': return avatarEthan;
      case 'liam': return avatarLiam;
      case 'nadia': return avatarNadia;
      case 'olivia': return avatarOlivia;
      default: return avatarPlaceholder;
    }
  }

  /// Helper to get the single gallery snapshot for a character
  static String getGallerySnapshot(String name) {
    switch (name.toLowerCase()) {
      case 'claire': return galleryClaire;
      case 'daniel': return galleryDaniel;
      case 'ethan': return galleryEthan;
      case 'liam': return galleryLiam;
      case 'nadia': return galleryNadia;
      case 'olivia': return galleryOlivia;
      default: return avatarPlaceholder;
    }
  }
}
