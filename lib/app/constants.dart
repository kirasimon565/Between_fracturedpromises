class AppConstants {
  static const String appName = "Between";
  static const String version = "1.0.0";
  static const int buildNumber = 100;
  static const String contactEmail = "support@between.com";

  // Assets - Avatars
  static const String avatarClaire = 'assets/avatars/claire.png';
  static const String avatarDaniel = 'assets/avatars/daniel.png';
  static const String avatarEthan = 'assets/avatars/ethan.png';
  static const String avatarLiam = 'assets/avatars/liam.png';
  static const String avatarNadia = 'assets/avatars/nadia.png';
  static const String avatarOlivia = 'assets/avatars/olivia.png';
  static const String avatarPlaceholder = 'assets/avatars/placeholder.png';

  // Assets - Backgrounds
  static const String bgDefault = 'assets/backgrounds/default.png';

  // Assets - Badges
  static const String badgeVerified = 'assets/badges/verified.png';

  // Assets - FX
  static const String fxClick = 'assets/fx/click.mp3';

  // Assets - Gallery
  static const String galleryEndingFractured = 'assets/gallery/ending_fractured.png';
  static const String gallerySecret1 = 'assets/gallery/secret_1.png';
  static const String gallerySecret2 = 'assets/gallery/secret_2.png';

  // Assets - Icons
  static const String iconApp = 'assets/icons/app_icon.png';

  // Assets - Logo
  static const String logoApp = 'assets/logo/app_logo.png';

  // Assets - Music
  static const String musicTheme = 'assets/music/theme.mp3';

  /// Helper to get avatar path dynamically
  static String getAvatarPath(String name) {
    switch (name.toLowerCase()) {
      case 'claire':
        return avatarClaire;
      case 'daniel':
        return avatarDaniel;
      case 'ethan':
        return avatarEthan;
      case 'liam':
        return avatarLiam;
      case 'nadia':
        return avatarNadia;
      case 'olivia':
        return avatarOlivia;
      default:
        return avatarPlaceholder;
    }
  }
}
