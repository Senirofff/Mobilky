import '../models/weather_model.dart';

class Difficulty {
  const Difficulty(this.score);
  final int? score;
  String get label => score == null
      ? 'Недостаточно данных'
      : score == 0
      ? 'Низкая'
      : score! < 3
      ? 'Средняя'
      : 'Высокая';
  String get recommendation => score == null
      ? 'Нужны температура, ветер и погодное состояние.'
      : score == 0
      ? 'Благоприятные погодные условия'
      : score! < 3
      ? 'Возможны осложнения из-за погодных условий'
      : 'Неблагоприятные погодные условия';
}

class WeatherAnalysisService {
  Difficulty evaluate(WeatherModel w) {
    if (w.temp == null ||
        w.windSpeed == null ||
        w.condition == 'Нет данных об условиях') {
      return const Difficulty(null);
    }
    final text = w.conditionText;
    return Difficulty(
      (text.contains('snow') || text.contains('sleet')
              ? 3
              : text.contains('rain') || text.contains('drizzle')
              ? 2
              : 0) +
          (w.windSpeed! >= 10
              ? 2
              : w.windSpeed! >= 6
              ? 1
              : 0) +
          (w.temp! <= 0 ? 1 : 0),
    );
  }

  WeatherModel? bestInterval(
    List<WeatherModel> forecast,
    String day, {
    DateTime? now,
  }) {
    final future = now ?? DateTime.now().toUtc();
    final available = forecast
        .where(
          (w) =>
              w.timestamp != null &&
              w.timestamp!.isAfter(future) &&
              dayKey(w.timestamp!) == day &&
              evaluate(w).score != null,
        )
        .toList();
    available.sort((a, b) {
      final score = evaluate(a).score!.compareTo(evaluate(b).score!);
      if (score != 0) return score;
      final wind = a.windSpeed!.compareTo(b.windSpeed!);
      return wind != 0 ? wind : a.timestamp!.compareTo(b.timestamp!);
    });
    return available.isEmpty ? null : available.first;
  }
}
