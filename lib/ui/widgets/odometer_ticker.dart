import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OdometerTicker extends StatelessWidget {
  final double value;
  final String prefix;
  final TextStyle? style;
  final Duration duration;

  const OdometerTicker({
    super.key,
    required this.value,
    this.prefix = '',
    this.style,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        final formatted = NumberFormat('#,##0', 'en_US').format(val.round());
        return Text(
          '$prefix$formatted',
          style: style,
        );
      },
    );
  }
}
