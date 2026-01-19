import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/ending.dart';

class EndingSummary extends StatefulWidget {
  final Ending ending;

  const EndingSummary({Key? key, required this.ending}) : super(key: key);

  @override
  State<EndingSummary> createState() => _EndingSummaryState();
}

class _EndingSummaryState extends State<EndingSummary> with TickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _textController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. The Verdict Title
        FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                Text(
                  "THE VERDICT",
                  style: TextStyle(
                    color: Colors.red.withOpacity(0.5),
                    fontSize: 10,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.ending.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w100,
                    letterSpacing: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 50),
        
        // 2. The Subtle Divider
        AnimatedContainer(
          duration: const Duration(seconds: 2),
          width: _textController.isAnimating ? 60 : 20,
          height: 1,
          color: Colors.white10,
        ),
        
        const SizedBox(height: 50),

        // 3. The Final Fallout Description
        FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              widget.ending.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
                height: 1.8,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
