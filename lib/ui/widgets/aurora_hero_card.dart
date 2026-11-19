import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AuroraHeroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const AuroraHeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: const RadialGradient(
          center: Alignment(-0.6, -0.6),
          radius: 1.4,
          colors: [
            Color(0xFF2E1065), // Deep purple sweep
            Color(0xFF1E1B4B), // Midnight indigo
            Color(0xFF0F172A), // Slate base
            Color(0xFF0A0E17), // Obsidian
          ],
          stops: [0.0, 0.4, 0.75, 1.0],
        ),
        border: Border.all(color: const Color(0xFF374151), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
