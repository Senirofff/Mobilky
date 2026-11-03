import 'package:dio/dio.dart';

import '../models/rally_stage.dart';
import '../models/weather_model.dart';

class WeatherService {
  WeatherService(this.dio);
  final Dio dio;
  final Map<String, ({DateTime at, Object data})> _cache = {};
  final Map<String, Future<Object>> _pending = {};
  Future<Object> _get(RallyStage stage, String endpoint, bool refresh) async {
    final key = '$endpoint:${stage.cacheKey}';
    final cached = _cache[key];
    if (!refresh &&
        cached != null &&
        DateTime.now().difference(cached.at) < const Duration(minutes: 10)) {
      return cached.data;
    }
    if (_pending[key] case final Future<Object> pending) return pending;
    final request = () async {
      final response = await dio.get<Object>(
        endpoint,
        queryParameters: {'lat': stage.latitude, 'lon': stage.longitude},
      );
      final data = response.data;
      if (data == null ||
          (endpoint == '/v1/weather'
              ? data is! Map || data.containsKey('error')
              : data is! List)) {
        throw const FormatException('Некорректный ответ');
      }
      _cache[key] = (at: DateTime.now(), data: data);
      return data;
    }();
    _pending[key] = request;
    try {
      return await request;
    } finally {
      _pending.remove(key);
    }
  }

  Future<WeatherModel> current(
    RallyStage stage, {
    bool refresh = false,
  }) async => WeatherModel.fromJson(
    Map<String, dynamic>.from(await _get(stage, '/v1/weather', refresh) as Map),
  );
  Future<List<WeatherModel>> forecast(
    RallyStage stage, {
    bool refresh = false,
  }) async {
    final data = await _get(stage, '/v1/weatherforecast', refresh) as List;
    final result = data
        .whereType<Map>()
        .map((e) => WeatherModel.fromJson(Map<String, dynamic>.from(e)))
        .where((w) => w.timestamp != null)
        .toList();
    result.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));
    return result;
  }
}

String weatherError(Object error) {
  if (error is DioException) {
    if (error.error is String) return error.error as String;
    return switch (error.response?.statusCode ?? 0) {
      401 || 403 => 'API-ключ неверен или не имеет доступа к этому методу.',
      429 => 'Превышен лимит запросов API. Попробуйте позже.',
      400 => 'Сервис отклонил координаты участка.',
      >= 500 => 'Сервер погоды временно недоступен.',
      _ => 'Не удалось получить погоду. Проверьте интернет и повторите запрос.',
    };
  }
  return 'Не удалось обработать данные сервера. Попробуйте обновить.';
}
