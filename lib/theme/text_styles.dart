import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  // Use "Questrial" or "Montserrat" for a more modern, cinematic feel
  static final TextStyle messengerTitle = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.messengerText,
    letterSpacing: 1.2,
  );

  static final TextStyle messengerBody = GoogleFonts.inter(
    fontSize: 15,
    color: AppColors.messengerText,
    height: 1.4,
  );

  // Makelove Styles (More intimate/dangerous)
  static final TextStyle makeloveTitle = GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontStyle: FontStyle.italic,
  );
}
