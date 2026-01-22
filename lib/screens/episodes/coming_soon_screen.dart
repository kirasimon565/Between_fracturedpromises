import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class ComingSoonScreen extends StatefulWidget {
  const ComingSoonScreen({super.key});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> with SingleTickerProviderStateMixin {
  late AnimationController _swingController;

  @override
  void initState() {
    super.initState();
    _swingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _swingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. The Empty Beach Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/empty_beach.jpg', // You'll need this asset
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.4),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // 2. The Hanging Wooden Sign
          Center(
            child: AnimatedBuilder(
              animation: _swingController,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.topCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateZ(math.sin(_swingController.value * math.pi * 2) * 0.04),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // The Rope
                      Container(width: 3, height: 120, color: Colors.brown[300]),
                      
                      // The Wooden Sign
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3E2723), // Dark wood color
                          border: Border.all(color: const Color(0xFF5D4037), width: 4),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 15, offset: const Offset(0, 8))
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "EPISODE 02",
                              style: TextStyle(color: Colors.white70, letterSpacing: 5, fontSize: 12),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              "A LOT OF PAIN IS COMING,\nSTAY TUNED.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontFamily: 'Serif',
                                fontStyle: FontStyle.italic,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 40),
                            
                            // ☁️ The Cloud Progress Bar
                            const CloudProgressBar(progress: 0.65), // 65% complete
                            const SizedBox(height: 10),
                            const Text(
                              "DEVELOPMENT IN PROGRESS",
                              style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }
}

// ☁️ Custom Painter for the Cloud Progress Bar
class CloudProgressBar extends StatelessWidget {
  final double progress;
  const CloudProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(120, 60),
            painter: CloudShapePainter(color: Colors.white10), // Background cloud
          ),
          ClipPath(
            clipper: CloudClipper(progress: progress),
            child: CustomPaint(
              size: const Size(120, 60),
              painter: CloudShapePainter(color: Colors.white70), // Filling cloud
            ),
          ),
        ],
      ),
    );
  }
}

class CloudShapePainter extends CustomPainter {
  final Color color;
  CloudShapePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    path.addOval(Rect.fromLTWH(size.width * 0.2, size.height * 0.1, size.width * 0.4, size.height * 0.6));
    path.addOval(Rect.fromLTWH(size.width * 0.45, size.height * 0.2, size.width * 0.4, size.height * 0.7));
    path.addOval(Rect.fromLTWH(size.width * 0.1, size.height * 0.4, size.width * 0.5, size.height * 0.5));
    path.addOval(Rect.fromLTWH(size.width * 0.4, size.height * 0.45, size.width * 0.5, size.height * 0.5));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CloudClipper extends CustomClipper<Path> {
  final double progress;
  CloudClipper({required this.progress});

  @override
  Path getClip(Size size) {
    return Path()..addRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) => true;
}
