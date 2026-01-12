import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/ending.dart';

class EndingSummary extends StatelessWidget {
  final Ending ending;

  const EndingSummary({Key? key, required this.ending}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // The title of the consequence
          Text(
            ending.title.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w200,
              letterSpacing: 10,
            ),
          ),
          const SizedBox(height: 40),
          // Subtle separator
          Container(width: 40, height: 1, color: Colors.white24),
          const SizedBox(height: 40),
          // The final description of the fallout
          Text(
            ending.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
