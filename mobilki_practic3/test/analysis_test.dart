import 'package:flutter_test/flutter_test.dart';
import 'package:rally_stage_analyzer/models/rally_stage.dart';
import 'package:rally_stage_analyzer/models/weather_model.dart';
import 'package:rally_stage_analyzer/services/weather_analysis_service.dart';

void main() {
  final analysis = WeatherAnalysisService();
  WeatherModel weather({
    double? temp = 12,
    double? wind = 2,
    String? condition = 'Clear',
    String? description,
    DateTime? at,
  }) => WeatherModel(
    temp: temp,
    windSpeed: wind,
    weather: condition,
    description: description,
    timestamp: at,
  );
  test('Пороговые баллы и уровни сложности', () {
    expect(analysis.evaluate(weather()).score, 0);
    expect(analysis.evaluate(weather(wind: 5.99)).score, 0);
    expect(analysis.evaluate(weather(wind: 6)).score, 1);
    expect(analysis.evaluate(weather(wind: 10)).score, 2);
    expect(analysis.evaluate(weather(temp: 0)).score, 1);
    expect(analysis.evaluate(weather(condition: 'Rain')).score, 2);
    expect(analysis.evaluate(weather(condition: 'Snow')).score, 3);
    expect(
      analysis.evaluate(weather(condition: 'Snow', temp: -1, wind: 10)).score,
      6,
    );
    expect(
      analysis.evaluate(weather(condition: 'Rain', wind: 6)).label,
      'Высокая',
    );
    expect(analysis.evaluate(weather(wind: 6)).label, 'Средняя');
    expect(analysis.evaluate(weather()).label, 'Низкая');
  });
  test('Описание учитывается, неизвестные поля не выдумываются', () {
    expect(
      analysis
          .evaluate(weather(condition: null, description: 'light rain'))
          .score,
      2,
    );
    expect(analysis.evaluate(weather(temp: null)).score, isNull);
    expect(analysis.evaluate(weather(wind: null)).score, isNull);
    expect(analysis.evaluate(weather(condition: null)).score, isNull);
    expect(analysis.evaluate(weather(condition: 'unknown')).score, isNull);
    final parsed = WeatherModel.fromJson({
      'temp': 'bad',
      'wind_speed': -2,
      'humidity': 110,
    });
    expect(parsed.temp, isNull);
    expect(parsed.windSpeed, isNull);
    expect(parsed.humidity, isNull);
  });
  test('Проверка координат и названия', () {
    for (final value in ['-90', '90', '0', '55,75']) {
      expect(RallyStage.coordinate(value, latitude: true), isNotNull);
    }
    for (final value in ['-180', '180']) {
      expect(RallyStage.coordinate(value, latitude: false), isNotNull);
    }
    for (final value in ['', 'abc', 'NaN', 'Infinity', '90.01', '-90.01']) {
      expect(RallyStage.coordinate(value, latitude: true), isNull);
    }
    expect(RallyStage.coordinate('180.1', latitude: false), isNull);
    expect(RallyStage.validName('  '), isFalse);
    expect(RallyStage.validName('Лесной'), isTrue);
  });
  test('Планировщик: только будущее, баллы, ветер, затем время', () {
    final now = DateTime.utc(2026, 10, 23, 8), day = '2026-10-23';
    final early = weather(at: DateTime.utc(2026, 10, 23, 12));
    final late = weather(at: DateTime.utc(2026, 10, 23, 15));
    final windy = weather(wind: 4, at: DateTime.utc(2026, 10, 23, 9));
    final past = weather(wind: 0, at: now);
    final rain = weather(
      condition: 'Rain',
      wind: 0,
      at: DateTime.utc(2026, 10, 23, 10),
    );
    expect(
      analysis.bestInterval([late, windy, past, rain, early], day, now: now),
      same(early),
    );
    expect(analysis.bestInterval([past], day, now: now), isNull);
    expect(
      analysis.bestInterval(
        [weather(temp: null, at: late.timestamp)],
        day,
        now: now,
      ),
      isNull,
    );
    expect(analysis.bestInterval([early], '2026-10-24', now: now), isNull);
  });
}
