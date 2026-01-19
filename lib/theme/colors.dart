import 'package:flutter/material.dart';

class AppColors {
  // 🌫️ Common / FX
  static const Color glassOverlay = Color(0x99000000); 
  static const Color shadowNoir = Color(0xFF000000);
  static const Color dividerDark = Color(0xFF1A1A1A);

  // 🛡️ Safe Theme (Messenger) - Slate Noir
  static const Color messengerPrimary = Color(0xFF2C2C2C); 
  static const Color messengerBackground = Color(0xFF0F0F0F); 
  static const Color messengerText = Color(0xFFE0E0E0);
  static const Color messengerBubbleSelf = Color(0xFF3A3A3C);
  static const Color messengerBubbleOther = Color(0xFF262626);
  static const Color messengerAccent = Color(0xFF004D40); // Subtle teal for "Safe" vibes

  // 🌹 Secret Theme (Makelove) - "Obsession Crimson"
  static const Color makelovePrimary = Color(0xFF8B0000); 
  static const Color makeloveBackground = Color(0xFF050505); 
  static const Color makeloveText = Color(0xFFFFFFFF);
  static const Color makeloveBubbleSelf = Color(0xFF450000); // Darker for readability
  static const Color makeloveBubbleOther = Color(0xFF121212);
  static const Color makeloveAccent = Color(0xFFFF0000); // Pure Red for "LIVE" pulses

  // 💻 Admin (Secure System)
  static const Color adminBackground = Color(0xFF000000);
  static const Color adminText = Color(0xFF00FF00); // Matrix Green
  static const Color adminAlert = Color(0xFFFF0000); // For Override status
  static const Color adminSurface = Color(0xFF0D0D0D); // For cards
}
