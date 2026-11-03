import 'package:dio/dio.dart';

class TokenInterceptor extends Interceptor {
  TokenInterceptor(this.apiKey);
  final String apiKey;
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (apiKey.trim().isEmpty) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Не указан API-ключ. Запустите приложение с --dart-define=API_NINJAS_KEY=ваш_ключ.',
        ),
      );
      return;
    }
    options.headers['X-Api-Key'] = apiKey;
    handler.next(options);
  }
}
