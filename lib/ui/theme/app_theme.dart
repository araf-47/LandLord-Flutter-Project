import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF4F46E5); // Electric Indigo
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color secondary = Color(0xFF6D28D9); // Violet
  static const Color obsidian = Color(0xFF0A0E17);
  static const Color darkCard = Color(0xFF111827);
  static const Color darkBorder = Color(0xFF2E3748);
  static const Color darkSurface = Color(0xFF1E293B);

  // Semantics
  static const Color emerald = Color(0xFF10B981); // Income, Paid
  static const Color emeraldSoft = Color(0xFFECFDF5);
  static const Color coral = Color(0xFFF43F5E); // Overdue, Expenses
  static const Color coralSoft = Color(0xFFFFF1F2);
  static const Color amber = Color(0xFFF59E0B); // Pending, Attention
  static const Color amberSoft = Color(0xFFFFFBEB);
  static const Color cyan = Color(0xFF0EA5E9); // Units, Occupancy
  static const Color cyanSoft = Color(0xFFF0F9FF);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0F172A),
        centerTitle: false,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.obsidian,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        surface: AppColors.darkCard,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        color: AppColors.darkCard,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.obsidian,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
    );
  }
}
