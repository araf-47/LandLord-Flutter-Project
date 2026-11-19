import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class CashFlowPoint {
  final String month;
  final double amount;
  CashFlowPoint(this.month, this.amount);
}

class GlowingBezierChart extends StatefulWidget {
  final List<CashFlowPoint> points;
  final double height;

  const GlowingBezierChart({
    super.key,
    required this.points,
    this.height = 180,
  });

  @override
  State<GlowingBezierChart> createState() => _GlowingBezierChartState();
}

class _GlowingBezierChartState extends State<GlowingBezierChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          onHorizontalDragUpdate: (details) => _handleTouch(details.localPosition.dx, width),
          onTapDown: (details) => _handleTouch(details.localPosition.dx, width),
          onHorizontalDragEnd: (_) => setState(() => _hoveredIndex = null),
          onTapUp: (_) => setState(() => _hoveredIndex = null),
          child: SizedBox(
            height: widget.height,
            width: width,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(width, widget.height),
                  painter: _BezierPainter(
                    points: widget.points,
                    hoveredIndex: _hoveredIndex,
                  ),
                ),
                if (_hoveredIndex != null && _hoveredIndex! < widget.points.length)
                  _buildTooltip(width),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleTouch(double touchX, double totalWidth) {
    final segment = totalWidth / (widget.points.length - 1);
    int index = (touchX / segment).round().clamp(0, widget.points.length - 1);
    if (_hoveredIndex != index) {
      HapticFeedback.selectionClick();
      setState(() => _hoveredIndex = index);
    }
  }

  Widget _buildTooltip(double totalWidth) {
    final pt = widget.points[_hoveredIndex!];
    final segment = totalWidth / (widget.points.length - 1);
    final posX = (_hoveredIndex! * segment).clamp(40.0, totalWidth - 40.0);

    return Positioned(
      left: posX - 45,
      top: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.emerald, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pt.month,
              style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: pwBold),
            ),
            Text(
              '৳${pt.amount.toStringAsFixed(0)}',
              style: const TextStyle(color: AppColors.emerald, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

const FontWeight pwBold = FontWeight.w600;

class _BezierPainter extends CustomPainter {
  final List<CashFlowPoint> points;
  final int? hoveredIndex;

  _BezierPainter({required this.points, this.hoveredIndex});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final maxVal = points.map((p) => p.amount).reduce((a, b) => a > b ? a : b) * 1.25;
    final minVal = 0.0;
    final valRange = (maxVal - minVal) <= 0 ? 1.0 : (maxVal - minVal);

    final List<Offset> offsets = [];
    final dx = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final yNorm = (points[i].amount - minVal) / valRange;
      final y = size.height - (yNorm * (size.height - 40)) - 20;
      offsets.add(Offset(i * dx, y));
    }

    final path = Path()..moveTo(offsets[0].dx, offsets[0].dy);
    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    // Gradient fill under curve
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        [
          AppColors.emerald.withOpacity(0.35),
          AppColors.primary.withOpacity(0.08),
          Colors.transparent,
        ],
        [0.0, 0.6, 1.0],
      );
    canvas.drawPath(fillPath, fillPaint);

    // Glowing stroke
    final glowPaint = Paint()
      ..color = AppColors.emerald.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawPath(path, glowPaint);

    // Sharp stroke
    final strokePaint = Paint()
      ..color = AppColors.emerald
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, strokePaint);

    // Points
    for (int i = 0; i < offsets.length; i++) {
      final isHovered = hoveredIndex == i;
      final ptPaint = Paint()
        ..color = isHovered ? Colors.white : AppColors.emerald
        ..style = PaintingStyle.fill;
      canvas.drawCircle(offsets[i], isHovered ? 5.5 : 3.5, ptPaint);

      if (isHovered) {
        // Draw vertical rule line
        final linePaint = Paint()
          ..color = AppColors.emerald.withOpacity(0.5)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(offsets[i].dx, 0),
          Offset(offsets[i].dx, size.height),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BezierPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.hoveredIndex != hoveredIndex;
  }
}
