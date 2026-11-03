class WeatherModel {
  const WeatherModel({
    this.temp,
    this.feelsLike,
    this.humidity,
    this.cloudPct,
    this.windSpeed,
    this.windDegrees,
    this.weather,
    this.description,
    this.timestamp,
  });
  final double? temp, feelsLike, humidity, cloudPct, windSpeed, windDegrees;
  final String? weather, description;
  final DateTime? timestamp;
  factory WeatherModel.fromJson(Map<String, dynamic> j) {
    double? number(String k, {double? min, double? max}) {
      final raw = j[k];
      final n = raw is num ? raw.toDouble() : double.tryParse('$raw');
      return n != null &&
              n.isFinite &&
              (min == null || n >= min) &&
              (max == null || n <= max)
          ? n
          : null;
    }

    String? string(String k) =>
        j[k] is String && (j[k] as String).trim().isNotEmpty
        ? j[k] as String
        : null;
    final seconds = number('timestamp', min: 0, max: 8640000000000);
    return WeatherModel(
      temp: number('temp'),
      feelsLike: number('feels_like'),
      humidity: number('humidity', min: 0, max: 100),
      cloudPct: number('cloud_pct', min: 0, max: 100),
      windSpeed: number('wind_speed', min: 0),
      windDegrees: number('wind_degrees', min: 0, max: 360),
      weather: string('weather'),
      description: string('weather_description'),
      timestamp: seconds == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              (seconds * 1000).round(),
              isUtc: true,
            ),
    );
  }
  String get conditionText =>
      '${weather ?? ''} ${description ?? ''}'.toLowerCase();
  String get condition {
    final s = conditionText;
    if (s.contains('snow') || s.contains('sleet')) return 'Снег';
    if (s.contains('thunder')) return 'Гроза';
    if (s.contains('rain') || s.contains('drizzle')) return 'Дождь';
    if (s.contains('clear')) return 'Ясно';
    if (s.contains('cloud')) return 'Облачно';
    if (s.contains('mist') || s.contains('fog')) return 'Туман';
    if (s.contains('haze')) return 'Дымка';
    if (s.contains('smoke')) return 'Дым';
    if (s.contains('dust') || s.contains('sand')) return 'Пыль / песок';
    if (s.contains('squall')) return 'Шквал';
    if (s.contains('tornado')) return 'Смерч';
    if (s.contains('ash')) return 'Пепел';
    return 'Нет данных об условиях';
  }
}

String metric(double? n, String unit) => n == null
    ? 'Нет данных'
    : '${n.toStringAsFixed(n == n.roundToDouble() ? 0 : 1)}$unit';
String dayKey(DateTime t) => t.toUtc().toIso8601String().substring(0, 10);
String dayLabel(String key) {
  final d = DateTime.parse(key);
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
}

String timeLabel(DateTime t) =>
    '${t.toUtc().hour.toString().padLeft(2, '0')}:${t.toUtc().minute.toString().padLeft(2, '0')} UTC';
