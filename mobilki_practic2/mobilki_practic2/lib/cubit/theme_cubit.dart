import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Состояние темы приложения.
///
/// Неизменяемый класс: Cubit всегда отдаёт новое состояние через `emit`,
/// а виджеты перестраиваются по нему через `BlocBuilder`.
class ThemeState {
  const ThemeState({required this.isDarkTheme});

  /// `true` — тёмная тема, `false` — светлая.
  final bool isDarkTheme;

  /// Готовое значение для `MaterialApp.themeMode`.
  ThemeMode get themeMode => isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  /// Копия состояния с новым значением флага.
  ThemeState copyWith({bool? isDarkTheme}) {
    return ThemeState(isDarkTheme: isDarkTheme ?? this.isDarkTheme);
  }

  // Сравнение нужно, чтобы `BlocBuilder` не перестраивал интерфейс заново,
  // если состояние по смыслу не изменилось.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ThemeState && other.isDarkTheme == isDarkTheme;
  }

  @override
  int get hashCode => isDarkTheme.hashCode;
}

/// Cubit темы: хранит выбранный вариант оформления и переключает его.
///
/// Сам Cubit ничего не знает про виджеты — только хранит состояние и
/// сообщает о его изменении, а цвета берутся из темы (`theme/app_theme.dart`).
class ThemeCubit extends Cubit<ThemeState> {
  /// Приложение открывается в тёмной теме.
  ThemeCubit() : super(const ThemeState(isDarkTheme: true));

  /// Переключает тёмную тему на светлую и обратно.
  void toggleTheme() {
    emit(state.copyWith(isDarkTheme: !state.isDarkTheme));
  }
}
