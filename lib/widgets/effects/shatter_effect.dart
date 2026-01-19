import 'dart:math';
import 'package:flutter/material.dart';

class ShatterEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback onShatterComplete;
  // 🛠️ ADDED: Callback for the moment the audio should play
  final VoidCallback? onShatterStart; 

  const ShatterEffect({
    Key? key,
    required this.child,
    required this.onShatterComplete,
    this.onShatterStart, // Initialize optional parameter
  }) : super(key: key);

  @override
  _ShatterEffectState createState() => _ShatterEffectState();
}

class _ShatterEffectState extends State<ShatterEffect> with TickerProviderStateMixin {
  late AnimationController _bloomController;
  late AnimationController _shatterController;
  List<_Shard> _shards = [];
  bool _isShattered = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Phase A: Bloom (1.5s)
    _bloomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Phase B: Shatter (2.0s)
    _shatterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onShatterComplete();
      }
    });

    _startSequence();
  }

  void _startSequence() async {
    // 1. Bloom
    await _bloomController.forward();

    // 🔊 TRIGGER: Signal the SplashScreen to play 'glass_shatter.mp3'
    widget.onShatterStart?.call();

    // 2. Prepare Shards
    _createShards();
    if (mounted) {
      setState(() => _isShattered = true);
    }

    // 3. Explode
    _shatterController.forward();
  }

  void _createShards() {
    // Generate ~60 shards for the physics event
    for (int i = 0; i < 60; i++) {
      double angle = _random.nextDouble() * 2 * pi;
      double force = _random.nextDouble() * 10 + 2;

      _shards.add(_Shard(
        position: const Offset(0, 0),
        velocity: Offset(cos(angle) * force, sin(angle) * force - 5), // Slight upward burst
        rotation: _random.nextDouble() * pi,
        angularVelocity: (_random.nextDouble() - 0.5) * 0.5,
        scale: _random.nextDouble() * 0.5 + 0.5,
        path: _createJaggedPath(),
        color: Colors.white,
      ));
    }
  }

  Path _createJaggedPath() {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(_random.nextDouble() * 40 - 20, _random.nextDouble() * 40 - 20);
    path.lineTo(_random.nextDouble() * 40 - 20, _random.nextDouble() * 40 - 20);
    path.close();
    return path;
  }

  @override
  void dispose() {
    _bloomController.dispose();
    _shatterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isShattered) {
      return AnimatedBuilder(
        animation: _shatterController,
        builder: (context, child) {
          return CustomPaint(
            painter: _ShatterPainter(
              shards: _shards,
              progress: _shatterController.value,
            ),
            child: Container(),
          );
        },
      );
    }

    return AnimatedBuilder(
      animation: _bloomController,
      builder: (context, child) {
        // Luminance Bloom: simulate "Too Bright" by additive white blending
        double value = _bloomController.value;
        return ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(value.clamp(0.0, 1.0)),
            BlendMode.plus, 
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _Shard {
  Offset position;
  Offset velocity;
  double rotation;
  double angularVelocity;
  double scale;
  Path path;
  Color color;

  _Shard({
    required this.position,
    required this.velocity,
    required this.rotation,
    required this.angularVelocity,
    required this.scale,
    required this.path,
    required this.color,
  });
}

class _ShatterPainter extends CustomPainter {
  final List<_Shard> shards;
  final double progress;

  _ShatterPainter({required this.shards, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white; 

    final center = Offset(size.width / 2, size.height / 2);

    for (var shard in shards) {
      double t = progress * 15; // Time multiplier for physics calc

      // Physics: x = x0 + vt, y = y0 + vt + 0.5gt^2
      Offset currentPos = center + (shard.velocity * t);
      currentPos += Offset(0, 0.5 * 20.0 * t * t); // Gravity constant 20

      double currentRotation = shard.rotation + (shard.angularVelocity * t);

      canvas.save();
      canvas.translate(currentPos.dx, currentPos.dy);
      canvas.rotate(currentRotation);
      canvas.scale(shard.scale);
      canvas.drawPath(shard.path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ShatterPainter oldDelegate) => true;
}
