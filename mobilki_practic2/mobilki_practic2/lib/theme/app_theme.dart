import 'package:flutter/material.dart';

/// Цвета приложения: у каждой темы свой набор.
///
/// Виджеты эти константы напрямую не используют — они берут цвета из
/// `Theme.of(context).colorScheme`, поэтому смена темы меняет весь
/// интерфейс без правок в самих виджетах.
class AppColors {
  const AppColors._();

  // --- Тёмная тема ---------------------------------------------------------
  static const darkBackground = Color(0xFF1E1E1E);
  static const darkSurface = Color(0xFF2C2C2E);
  static const darkOnSurface = Color(0xFFFFFFFF);
  static const darkTextMuted = Color(0xFF9CA3AF);
  static const darkIconMuted = Color(0xFF6B7280);
  static const darkAccent = Color(0xFFF5A623);
  static const darkOnAccent = Color(0xFF000000);

  // --- Светлая тема --------------------------------------------------------
  static const lightBackground = Color(0xFFF3F4F6);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightOnSurface = Color(0xFF111827);
  static const lightTextMuted = Color(0xFF6B7280);
  static const lightIconMuted = Color(0xFF9CA3AF);

  /// На светлом фоне янтарный нечитаем, поэтому акцент темнее,
  /// а кнопка «Сохранить» — с белым текстом.
  static const lightAccent = Color(0xFFB45309);
  static const lightOnAccent = Color(0xFFFFFFFF);
  static const lightDisabledButton = Color(0xFFE5E7EB);

  // --- Общее ---------------------------------------------------------------
  static const danger = Color(0xFFEF4444);
}

/// Тема приложения для указанной яркости.
///
/// [Brightness.dark] — тёмная тема, [Brightness.light] — светлая.
/// `MaterialApp` выбирает между ними сам, ориентируясь на
/// `ThemeCubit.state.themeMode`.
ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: isDark ? AppColors.darkAccent : AppColors.lightAccent,
    onPrimary: isDark ? AppColors.darkOnAccent : AppColors.lightOnAccent,
    // Второй акцент приложение не использует, но схема требует его задать:
    // берём тот же цвет, что и основной.
    secondary: isDark ? AppColors.darkAccent : AppColors.lightAccent,
    onSecondary: isDark ? AppColors.darkOnAccent : AppColors.lightOnAccent,
    surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    onSurface: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
    onSurfaceVariant: isDark
        ? AppColors.darkTextMuted
        : AppColors.lightTextMuted,
    outline: isDark ? AppColors.darkIconMuted : AppColors.lightIconMuted,
    error: AppColors.danger,
    onError: AppColors.darkOnAccent,
  );

  final background = isDark
      ? AppColors.darkBackground
      : AppColors.lightBackground;

  return (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        disabledBackgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightDisabledButton,
        disabledForegroundColor: scheme.onSurfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: scheme.primary),
    ),
  );
}
