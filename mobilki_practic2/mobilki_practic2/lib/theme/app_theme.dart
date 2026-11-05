import 'package:flutter/material.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: const Color(0xFFB77918),
        brightness: brightness,
      ).copyWith(
        primary: dark ? const Color(0xFFF2C078) : const Color(0xFF855216),
        onPrimary: dark ? const Color(0xFF352109) : Colors.white,
        surface: dark ? const Color(0xFF242321) : const Color(0xFFFFFDFA),
        onSurface: dark ? const Color(0xFFF2EEE7) : const Color(0xFF292722),
        onSurfaceVariant: dark
            ? const Color(0xFFBDB7AD)
            : const Color(0xFF70695F),
        outlineVariant: dark
            ? const Color(0xFF413D36)
            : const Color(0xFFE6DFD4),
      );
  final background = dark ? const Color(0xFF191918) : const Color(0xFFF7F4EE);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: scheme.onSurface,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.6, color: scheme.onSurface),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: scheme.onSurface),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
