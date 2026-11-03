import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/rally_stage.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

enum LoadStatus { initial, loading, success, error }

class WeatherState {
  const WeatherState({
    this.status = LoadStatus.initial,
    this.current,
    this.forecast = const [],
    this.error,
    this.forecastError,
  });
  final LoadStatus status;
  final WeatherModel? current;
  final List<WeatherModel> forecast;
  final String? error, forecastError;
}

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit(this.service) : super(const WeatherState());
  final WeatherService service;
  int _generation = 0;
  void clear() {
    _generation++;
    emit(const WeatherState());
  }

  Future<void> load(RallyStage stage, {bool refresh = false}) async {
    final generation = ++_generation;
    emit(const WeatherState(status: LoadStatus.loading));
    WeatherModel? current;
    List<WeatherModel> forecast = [];
    String? error, forecastError;
    await Future.wait([
      () async {
        try {
          current = await service.current(stage, refresh: refresh);
        } catch (e) {
          error = weatherError(e);
        }
      }(),
      () async {
        try {
          forecast = await service.forecast(stage, refresh: refresh);
        } catch (e) {
          forecastError = weatherError(e);
        }
      }(),
    ]);
    if (!isClosed && generation == _generation) {
      emit(
        WeatherState(
          status: current == null ? LoadStatus.error : LoadStatus.success,
          current: current,
          forecast: forecast,
          error: error,
          forecastError: forecastError,
        ),
      );
    }
  }
}
