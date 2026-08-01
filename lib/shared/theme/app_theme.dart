import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colour language of the game.
///
/// The palette is deliberately cold and low-contrast: the whole game is a phone
/// screen at 2am, so pure white is never used for large surfaces.
abstract final class AppColors {
  static const Color voidBlack = Color(0xFF05060A);
  static const Color night = Color(0xFF0B0D14);
  static const Color surface = Color(0xFF12151F);
  static const Color surfaceHigh = Color(0xFF1A1E2B);
  static const Color outline = Color(0xFF262C3D);

  static const Color text = Color(0xFFE8EAF2);
  static const Color textDim = Color(0xFF9AA1B8);
  static const Color textFaint = Color(0xFF5D6478);

  /// Nadia / player accent.
  static const Color ember = Color(0xFFE0685C);

  /// Messenger (the marriage) — cool and correct.
  static const Color messenger = Color(0xFF4C7DF0);

  /// Makelove (the affair) — hot magenta.
  static const Color makelove = Color(0xFFE0407F);

  /// Browser chrome.
  static const Color browser = Color(0xFF3BA88C);

  static const Color crystal = Color(0xFF7FD8FF);
  static const Color warning = Color(0xFFE8B84B);
  static const Color danger = Color(0xFFD2454A);
  static const Color success = Color(0xFF4CAF7D);

  static const List<Color> nightGradient = <Color>[
    Color(0xFF0B0D14),
    Color(0xFF141826),
    Color(0xFF0B0D14),
  ];

  static const List<Color> emberGradient = <Color>[
    Color(0xFFE0685C),
    Color(0xFFE0407F),
  ];

  static const List<Color> crystalGradient = <Color>[
    Color(0xFF7FD8FF),
    Color(0xFF9B7BFF),
  ];

  /// Accent colour for an app id, used by icons, headers and chat bubbles.
  static Color forApp(String? appId) {
    switch (appId) {
      case 'makelove':
        return makelove;
      case 'browser':
        return browser;
      case 'gallery':
        return const Color(0xFF9B7BFF);
      case 'contacts':
        return const Color(0xFF5FB0C9);
      case 'calls':
        return success;
      case 'settings':
        return textDim;
      case 'store':
        return crystal;
      case 'files':
        return const Color(0xFFB98A5B);
      case 'camera':
        return const Color(0xFF8892A6);
      default:
        return messenger;
    }
  }

  /// Stable per-character colour so avatars stay recognisable.
  static Color forCharacter(String id) {
    switch (id.toLowerCase()) {
      case 'ethan':
        return const Color(0xFF6C8FD6);
      case 'claire':
        return const Color(0xFF7FBF9A);
      case 'olivia':
        return const Color(0xFFD8A24A);
      case 'daniel':
        return makelove;
      case 'nadia':
        return ember;
      case 'system':
      case 'narrator':
        return textFaint;
      default:
        final int hash = id.codeUnits.fold<int>(
          7,
          (int a, int b) => a * 31 + b,
        );
        return HSLColor.fromAHSL(
          1,
          (hash % 360).toDouble(),
          0.35,
          0.62,
        ).toColor();
    }
  }
}

abstract final class AppRadii {
  static const BorderRadius bubble = BorderRadius.all(Radius.circular(18));
  static const BorderRadius card = BorderRadius.all(Radius.circular(20));
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(26),
  );
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
  static const BorderRadius icon = BorderRadius.all(Radius.circular(16));
}

abstract final class AppTheme {
  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.voidBlack,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static ThemeData build() {
    final TextTheme base = GoogleFonts.interTextTheme(
      ThemeData.dark(useMaterial3: true).textTheme,
    );

    final ColorScheme scheme = const ColorScheme.dark(
      primary: AppColors.ember,
      onPrimary: Colors.white,
      secondary: AppColors.messenger,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      error: AppColors.danger,
    ).copyWith(surfaceContainerHighest: AppColors.surfaceHigh);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.night,
      colorScheme: scheme,
      canvasColor: AppColors.night,
      splashFactory: InkSparkle.splashFactory,
      textTheme: base.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.night.withValues(alpha: 0.92),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: overlayStyle,
        titleTextStyle: base.titleMedium?.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textDim,
        textColor: AppColors.text,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ember,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.pill),
          textStyle: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.outline),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.pill),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.textDim),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: base.bodyMedium?.copyWith(color: AppColors.textFaint),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.card,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.card,
          borderSide: BorderSide(color: AppColors.outline),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.card,
          borderSide: BorderSide(color: AppColors.ember, width: 1.4),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: base.bodyMedium?.copyWith(color: AppColors.text),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.card),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.sheet),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.ember,
        linearTrackColor: AppColors.outline,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? AppColors.ember
              : AppColors.textFaint,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? AppColors.ember.withValues(alpha: 0.35)
              : AppColors.surfaceHigh,
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.ember,
        inactiveTrackColor: AppColors.outline,
        thumbColor: AppColors.ember,
      ),
    );
  }
}
