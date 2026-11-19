import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OccupancyArc extends StatelessWidget {
  final int occupied;
  final int total;
  final double size;

  const OccupancyArc({
    super.key,
    required this.occupied,
    required this.total,
    this.size = 130,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = total > 0 ? (occupied / total).clamp(0.0, 1.0) : 0.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ArcPainter(percentage: percentage),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                '$occupied / $total Units',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double percentage;

  _ArcPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;
    const strokeWidth = 9.0;
    const startAngle = 0.75 * math.pi; // 135 degrees
    const sweepTotal = 1.5 * math.pi; // 270 degrees total sweep

    // Background Arc
    final bgPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      bgPaint,
    );

    // Active Progress Arc
    if (percentage > 0) {
      final activePaint = Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.cyan, AppColors.emerald],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepTotal * percentage,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) => oldDelegate.percentage != percentage;
}
