import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum StatusType { success, warning, danger, info }

class StatusPill extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusPill({
    super.key,
    required this.label,
    required this.type,
  });

  factory StatusPill.fromStatus(String status) {
    final s = status.toLowerCase();
    if (s == 'paid' || s == 'occupied' || s == 'resolved' || s == 'active' || s == 'approved') {
      return StatusPill(label: status.toUpperCase(), type: StatusType.success);
    } else if (s == 'partial' || s == 'pending' || s == 'in_progress') {
      return StatusPill(label: status.replaceAll('_', ' ').toUpperCase(), type: StatusType.warning);
    } else if (s == 'unpaid' || s == 'vacant' || s == 'rejected' || s == 'high') {
      return StatusPill(label: status.toUpperCase(), type: StatusType.danger);
    } else {
      return StatusPill(label: status.toUpperCase(), type: StatusType.info);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color dot;
    Color text;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (type) {
      case StatusType.success:
        bg = isDark ? const Color(0xFF064E3B).withOpacity(0.4) : AppColors.emeraldSoft;
        border = AppColors.emerald;
        dot = AppColors.emerald;
        text = isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46);
        break;
      case StatusType.warning:
        bg = isDark ? const Color(0xFF78350F).withOpacity(0.4) : AppColors.amberSoft;
        border = AppColors.amber;
        dot = AppColors.amber;
        text = isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E);
        break;
      case StatusType.danger:
        bg = isDark ? const Color(0xFF881337).withOpacity(0.4) : AppColors.coralSoft;
        border = AppColors.coral;
        dot = AppColors.coral;
        text = isDark ? const Color(0xFFFECDD3) : const Color(0xFF9F1239);
        break;
      case StatusType.info:
        bg = isDark ? const Color(0xFF0C4A6E).withOpacity(0.4) : AppColors.cyanSoft;
        border = AppColors.cyan;
        dot = AppColors.cyan;
        text = isDark ? const Color(0xFFBAE6FD) : const Color(0xFF075985);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border.withOpacity(0.7), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: dot.withOpacity(0.6), blurRadius: 4, spreadRadius: 1),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
