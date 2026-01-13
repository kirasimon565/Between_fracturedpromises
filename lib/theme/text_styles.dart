import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
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

  // FIX: Added missing messengerCaption
  static final TextStyle messengerCaption = GoogleFonts.inter(
    fontSize: 12,
    color: Colors.white38,
    letterSpacing: 0.5,
  );

  static final TextStyle makeloveTitle = GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontStyle: FontStyle.italic,
  );

  // FIX: Added missing makeloveBody
  static final TextStyle makeloveBody = GoogleFonts.playfairDisplay(
    fontSize: 16,
    color: Colors.white,
    height: 1.3,
  );
}
