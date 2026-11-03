import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/weather_cubit.dart';
import '../di.dart';
import '../models/rally_stage.dart';
import '../models/weather_model.dart';
import '../services/weather_analysis_service.dart';
import '../widgets/weather_widgets.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({
    super.key,
    required this.stages,
    required this.selected,
    required this.onSelected,
  });
  final List<RallyStage> stages;
  final String? selected;
  final ValueChanged<String?> onSelected;
  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String? day;
  @override
  Widget build(BuildContext context) {
    final analysis = getIt<WeatherAnalysisService>();
    if (widget.stages.isEmpty) {
      return const Notice('Сначала добавьте спецучасток во вкладке «Участки».');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StagePicker(
          stages: widget.stages,
          value: widget.selected,
          onChanged: (id) {
            day = null;
            widget.onSelected(id);
          },
        ),
        BlocBuilder<WeatherCubit, WeatherState>(
          builder: (context, state) {
            final days = forecastDays(state.forecast);
            final selectedDay = days.contains(day) ? day : days.firstOrNull;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.selected == null)
                  const Notice('Выберите участок для получения погоды.'),
                if (widget.selected != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: OutlinedButton.icon(
                      onPressed: state.status == LoadStatus.loading
                          ? null
                          : () => context.read<WeatherCubit>().load(
                              widget.stages.firstWhere(
                                (s) => s.id == widget.selected,
                              ),
                              refresh: true,
                            ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Обновить'),
                    ),
                  ),
                if (state.status == LoadStatus.loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (state.error != null) Notice(state.error!),
                if (state.current != null)
                  WeatherCard(weather: state.current!, analysis: analysis),
                if (state.status != LoadStatus.initial &&
                    state.status != LoadStatus.loading) ...[
                  Text(
                    'Прогноз · время UTC',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: const Color(0xffff777e)),
                  ),
                  const SizedBox(height: 16),
                  if (state.forecastError != null)
                    Notice(state.forecastError!)
                  else if (days.isEmpty)
                    const Notice('Нет доступного прогноза.')
                  else ...[
                    DaySelector(
                      days: days,
                      selected: selectedDay,
                      onSelected: (d) => setState(() => day = d),
                    ),
                    ...state.forecast
                        .where(
                          (w) =>
                              w.timestamp!.isAfter(DateTime.now().toUtc()) &&
                              dayKey(w.timestamp!) == selectedDay,
                        )
                        .map(
                          (w) => Panel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 10,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      timeLabel(w.timestamp!),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xffff777e),
                                      ),
                                    ),
                                    Icon(weatherIcon(w)),
                                    Text(metric(w.temp, ' °C')),
                                    Text(w.condition),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                DifficultyBadge(analysis.evaluate(w)),
                              ],
                            ),
                          ),
                        ),
                  ],
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
