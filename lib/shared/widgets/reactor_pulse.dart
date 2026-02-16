import 'package:flutter/material.dart';

/// Widget de pulso animado tipo reactor
class ReactorPulse extends StatefulWidget {
  final double size;
  final Color color;

  const ReactorPulse({
    super.key,
    this.size = 20,
    this.color = Colors.cyan,
  });

  @override
  State<ReactorPulse> createState() => _ReactorPulseState();
}

class _ReactorPulseState extends State<ReactorPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _PulsePainter(
                animation: _controller,
                color: widget.color,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _PulsePainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Dibujar 3 círculos con diferentes fases
    for (int i = 0; i < 3; i++) {
      final phase = (animation.value + (i * 0.33)) % 1.0;
      final radius = maxRadius * phase;
      final opacity = (1.0 - phase).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = color.withValues(alpha: opacity * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, paint);
    }

    // Círculo central sólido
    final corePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final coreRadius = maxRadius * 0.2;
    canvas.drawCircle(center, coreRadius, corePaint);
  }

  @override
  bool shouldRepaint(_PulsePainter oldDelegate) {
    return animation != oldDelegate.animation || color != oldDelegate.color;
  }
}
