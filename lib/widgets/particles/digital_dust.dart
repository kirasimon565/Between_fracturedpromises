import 'dart:math';
import 'package:flutter/material.dart';

class DigitalDust extends StatefulWidget {
  final Widget child;
  final bool autoPlay;
  final Duration duration;
  final Color particleColor;

  const DigitalDust({
    Key? key,
    required this.child,
    this.autoPlay = true,
    this.duration = const Duration(milliseconds: 1500),
    this.particleColor = const Color(0xFFEEEEEE),
  }) : super(key: key);

  @override
  _DigitalDustState createState() => _DigitalDustState();
}

class _DigitalDustState extends State<DigitalDust> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;
  final List<_Shard> _shards = [];
  final Random _random = Random();
  bool _hasExploded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    if (widget.autoPlay && !_hasExploded) {
      _explode();
    }
  }

  void _explode() {
    if (_hasExploded) return;
    _hasExploded = true;
    _shards.clear();
    for (int i = 0; i < 20; i++) {
      _shards.add(_generateShard());
    }
    _controller.forward(from: 0);
  }

  _Shard _generateShard() {
    double angle = _random.nextDouble() * 2 * pi;
    double speed = _random.nextDouble() * 4 + 2;

    return _Shard(
      position: const Offset(0, 0),
      velocity: Offset(cos(angle) * speed, sin(angle) * speed),
      rotation: _random.nextDouble() * pi,
      angularVelocity: (_random.nextDouble() - 0.5) * 0.2,
      scale: _random.nextDouble() * 0.5 + 0.5,
      path: _createJaggedPath(),
    );
  }

  Path _createJaggedPath() {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(_random.nextDouble() * 10 - 5, _random.nextDouble() * 10 - 5);
    path.lineTo(_random.nextDouble() * 10 - 5, _random.nextDouble() * 10 - 5);
    path.close();
    return path;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true; // Keep state to prevent re-explosion

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        FadeTransition(
          opacity: CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.2, curve: Curves.easeOut)),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack)),
            child: widget.child,
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _DustPainter(
                  shards: _shards,
                  progress: _controller.value,
                  color: widget.particleColor,
                ),
              );
            },
          ),
        ),
      ],
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

  _Shard({
    required this.position,
    required this.velocity,
    required this.rotation,
    required this.angularVelocity,
    required this.scale,
    required this.path,
  });
}

class _DustPainter extends CustomPainter {
  final List<_Shard> shards;
  final double progress;
  final Color color;

  _DustPainter({required this.shards, required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1) return;

    final Paint paint = Paint()
      ..color = color.withOpacity((1.0 - progress).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    for (var shard in shards) {
      double t = progress * 20;
      Offset currentPos = center + (shard.velocity * t * 5);
      currentPos += Offset(0, 0.5 * 9.8 * t * t);
      double currentRotation = shard.rotation + (shard.angularVelocity * t * 10);

      canvas.save();
      canvas.translate(currentPos.dx, currentPos.dy);
      canvas.rotate(currentRotation);
      canvas.scale(shard.scale);
      canvas.drawPath(shard.path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_DustPainter oldDelegate) => true;
}
