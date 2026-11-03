import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rally_stage_analyzer/cubits/weather_cubit.dart';
import 'package:rally_stage_analyzer/models/rally_stage.dart';
import 'package:rally_stage_analyzer/network/token_interceptor.dart';
import 'package:rally_stage_analyzer/services/weather_service.dart';

class TestAdapter implements HttpClientAdapter {
  int calls = 0;
  Object? current = {'temp': 12, 'wind_speed': 3, 'weather': 'Clear'};
  Object? forecast = [
    {'timestamp': 1792800000, 'temp': 10},
  ];
  int status = 200;
  RequestOptions? last;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) async {
    calls++;
    last = options;
    return ResponseBody.fromString(
      jsonEncode(options.path.endsWith('weatherforecast') ? forecast : current),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  const stage = RallyStage(
    id: '1',
    name: 'Лесной',
    latitude: 55,
    longitude: 37,
  );
  late Dio dio;
  late TestAdapter adapter;
  late WeatherService service;
  setUp(() {
    adapter = TestAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://api.api-ninjas.com'))
      ..httpClientAdapter = adapter;
    service = WeatherService(dio);
  });
  tearDown(() => dio.close());
  test(
    'Ключ добавляется перехватчиком, координаты передаются в запрос',
    () async {
      dio.interceptors.add(TokenInterceptor('test-key'));
      await service.current(stage);
      expect(adapter.last!.headers['X-Api-Key'], 'test-key');
      expect(adapter.last!.queryParameters, {'lat': 55.0, 'lon': 37.0});
    },
  );
  test('Отсутствующий ключ не вызывает сетевой запрос', () async {
    dio.interceptors.add(TokenInterceptor(''));
    await expectLater(service.current(stage), throwsA(isA<DioException>()));
    expect(adapter.calls, 0);
    final cubit = WeatherCubit(service);
    await cubit.load(stage);
    expect(cubit.state.status, LoadStatus.error);
    expect(cubit.state.error, contains('Не указан API-ключ'));
    await cubit.close();
  });
  test(
    'Кэш общий, параллельные запросы объединяются, обновление принудительное',
    () async {
      await Future.wait([service.current(stage), service.current(stage)]);
      await service.current(stage);
      expect(adapter.calls, 1);
      await service.current(stage, refresh: true);
      expect(adapter.calls, 2);
      await service.current(
        const RallyStage(id: '1', name: 'Лесной', latitude: 56, longitude: 38),
      );
      expect(adapter.calls, 3);
    },
  );
  test('Некорректные ответы и пропущенные поля', () async {
    adapter.current = [];
    await expectLater(service.current(stage), throwsFormatException);
    adapter.current = {};
    expect((await service.current(stage, refresh: true)).temp, isNull);
    adapter.forecast = [
      {'temp': 12},
      null,
      {'timestamp': 'bad'},
    ];
    expect(await service.forecast(stage), isEmpty);
  });
  test('Погода доступна даже при отсутствии прогноза', () async {
    adapter.forecast = {'error': 'Unavailable'};
    final cubit = WeatherCubit(service);
    await cubit.load(stage);
    expect(cubit.state.status, LoadStatus.success);
    expect(cubit.state.current!.temp, 12);
    expect(cubit.state.forecastError, isNotNull);
    await cubit.close();
  });
  test('Русские сообщения об ошибках HTTP', () async {
    for (final code in [400, 401, 403, 429, 503]) {
      adapter.status = code;
      try {
        await service.current(stage, refresh: true);
        fail('Ожидалась ошибка');
      } catch (e) {
        expect(weatherError(e), isNotEmpty);
      }
    }
  });
}
