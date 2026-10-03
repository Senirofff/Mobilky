import 'package:flutter/material.dart';

/// Цвета приложения: тёмный фон, серая карточка и янтарный акцент.
class AppColors {
  const AppColors._();

  static const background = Color(0xFF1E1E1E);
  static const surface = Color(0xFF2C2C2E);
  static const accent = Color(0xFFF5A623);
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);
  static const textMuted = Color(0xFF9CA3AF);
  static const iconMuted = Color(0xFF6B7280);
}

/// Общая тёмная тема.
ThemeData buildAppTheme() {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: Colors.black,
      surface: AppColors.surface,
      onSurface: Colors.white,
      error: AppColors.danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
        disabledBackgroundColor: AppColors.surface,
        disabledForegroundColor: AppColors.textMuted,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.accent),
    ),
  );
}
