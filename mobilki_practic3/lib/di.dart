import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'network/token_interceptor.dart';
import 'services/stage_storage_service.dart';
import 'services/weather_service.dart';
import 'services/weather_analysis_service.dart';

final getIt = GetIt.instance;
Future<void> configureDependencies() async {
  final preferences = await SharedPreferences.getInstance();
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.api-ninjas.com',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  const apiKey = String.fromEnvironment('API_NINJAS_KEY');
  // Headers stay hidden; redact the secret even if a server echoes it.
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: false,
      responseHeader: false,
      requestBody: false,
      responseBody: true,
      error: true,
      logPrint: (object) {
        final text = object.toString();
        debugPrint(apiKey.isEmpty ? text : text.replaceAll(apiKey, '[СКРЫТО]'));
      },
      enabled: kDebugMode,
    ),
  );
  dio.interceptors.add(TokenInterceptor(apiKey));
  getIt.registerSingleton<Dio>(dio);
  getIt.registerSingleton(StageStorageService(preferences));
  getIt.registerSingleton(WeatherService(dio));
  getIt.registerSingleton(WeatherAnalysisService());
}
