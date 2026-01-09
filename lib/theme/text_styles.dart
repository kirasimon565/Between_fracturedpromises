import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Messenger (Safe) Styles
  static final TextStyle messengerTitle = GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static final TextStyle messengerBody = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  );

  static final TextStyle messengerCaption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.grey[600],
  );

  // Makelove (Secret) Styles
  static final TextStyle makeloveTitle = GoogleFonts.lato(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static final TextStyle makeloveBody = GoogleFonts.lato(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static final TextStyle makeloveCaption = GoogleFonts.lato(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: Colors.white70,
  );
}
