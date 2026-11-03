import 'package:flutter/material.dart';

import '../di.dart';
import '../models/rally_stage.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/weather_analysis_service.dart';
import '../widgets/weather_widgets.dart';

class StartPlannerScreen extends StatefulWidget {
  const StartPlannerScreen({super.key, required this.stages});
  final List<RallyStage> stages;
  @override
  State<StartPlannerScreen> createState() => _StartPlannerScreenState();
}

class _StartPlannerScreenState extends State<StartPlannerScreen> {
  String? selected, day, error;
  List<WeatherModel> forecast = [];
  WeatherModel? best;
  bool loading = false, searched = false;
  int generation = 0;
  @override
  void didUpdateWidget(StartPlannerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stages != widget.stages) {
      generation++;
      selected = null;
      day = null;
      error = null;
      forecast = [];
      best = null;
      searched = false;
      loading = false;
    }
  }

  Future<void> load(String? id, {bool refresh = false}) async {
    final version = ++generation;
    setState(() {
      selected = id;
      loading = id != null;
      forecast = [];
      best = null;
      error = null;
      day = null;
      searched = false;
    });
    if (id == null) return;
    try {
      final data = await getIt<WeatherService>().forecast(
        widget.stages.firstWhere((s) => s.id == id),
        refresh: refresh,
      );
      if (mounted && version == generation) {
        setState(() {
          forecast = data;
          day = forecastDays(data).firstOrNull;
        });
      }
    } catch (e) {
      if (mounted && version == generation) {
        setState(() => error = weatherError(e));
      }
    } finally {
      if (mounted && version == generation) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stages.isEmpty) {
      return const Notice('Сначала добавьте спецучасток во вкладке «Участки».');
    }
    final analysis = getIt<WeatherAnalysisService>(),
        days = forecastDays(forecast);
    final selectedDay = days.contains(day) ? day : days.firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StagePicker(stages: widget.stages, value: selected, onChanged: load),
        if (selected != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: OutlinedButton.icon(
              onPressed: loading ? null : () => load(selected, refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Обновить прогноз'),
            ),
          ),
        if (loading) const Center(child: CircularProgressIndicator()),
        if (error != null) Notice(error!),
        if (!loading && selected != null && error == null) ...[
          if (days.isEmpty)
            const Notice('Нет доступных будущих интервалов прогноза.')
          else ...[
            const Text(
              'День прогноза · UTC',
              style: TextStyle(color: Color(0xffff777e)),
            ),
            const SizedBox(height: 12),
            DaySelector(
              days: days,
              selected: selectedDay,
              onSelected: (d) => setState(() {
                day = d;
                best = null;
                searched = false;
              }),
            ),
            FilledButton.icon(
              onPressed: () => setState(() {
                best = analysis.bestInterval(forecast, selectedDay!);
                searched = true;
              }),
              icon: const Icon(Icons.flag_outlined),
              label: const Text('Подобрать время'),
            ),
            const SizedBox(height: 20),
          ],
        ],
        if (searched && best == null)
          const Notice(
            'Недостаточно данных для выбора времени. Нужны будущие интервалы с температурой, ветром и погодными условиями.',
          ),
        if (best != null) ...[
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Рекомендуемое время',
                  style: TextStyle(
                    color: Color(0xffff777e),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  timeLabel(best!.timestamp!),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(dayLabel(dayKey(best!.timestamp!))),
                const SizedBox(height: 14),
                const Text(
                  'Выбран интервал с наименьшей сложностью. При равных баллах — с меньшим ветром, затем более ранний.',
                ),
              ],
            ),
          ),
          WeatherCard(
            weather: best!,
            analysis: analysis,
            title: 'Погода к старту',
          ),
        ],
      ],
    );
  }
}
