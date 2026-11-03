import 'package:flutter/material.dart';

import '../di.dart';
import '../models/rally_stage.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/weather_analysis_service.dart';
import '../widgets/weather_widgets.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key, required this.stages});
  final List<RallyStage> stages;
  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  String? first, second, error;
  List<WeatherModel>? result;
  bool loading = false;
  int generation = 0;
  @override
  void didUpdateWidget(ComparisonScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stages != widget.stages) {
      generation++;
      loading = false;
      result = null;
      error = null;
      if (!widget.stages.any((s) => s.id == first)) first = null;
      if (!widget.stages.any((s) => s.id == second)) second = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stages.length < 2) {
      return const Notice(
        'Для сравнения добавьте хотя бы два спецучастка.',
        icon: Icons.compare_arrows,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StagePicker(
          stages: widget.stages,
          value: first,
          exclude: second,
          label: 'Первый участок',
          onChanged: (v) => change(v, true),
        ),
        StagePicker(
          stages: widget.stages,
          value: second,
          exclude: first,
          label: 'Второй участок',
          onChanged: (v) => change(v, false),
        ),
        FilledButton.icon(
          onPressed: loading || first == null || second == null
              ? null
              : compare,
          icon: const Icon(Icons.compare_arrows),
          label: const Text('Сравнить'),
        ),
        const SizedBox(height: 20),
        if (loading) const Center(child: CircularProgressIndicator()),
        if (error != null) Notice(error!),
        if (result != null) ...table(),
      ],
    );
  }

  void change(String? value, bool isFirst) => setState(() {
    generation++;
    loading = false;
    if (isFirst) {
      first = value;
    } else {
      second = value;
    }
    result = null;
    error = null;
  });
  Future<void> compare() async {
    if (first == second) {
      setState(() => error = 'Выберите разные участки.');
      return;
    }
    final version = ++generation;
    final a = widget.stages.firstWhere((s) => s.id == first),
        b = widget.stages.firstWhere((s) => s.id == second);
    setState(() {
      loading = true;
      error = null;
      result = null;
    });
    try {
      final values = await Future.wait([
        getIt<WeatherService>().current(a),
        getIt<WeatherService>().current(b),
      ]);
      if (mounted && version == generation) setState(() => result = values);
    } catch (e) {
      if (mounted && version == generation) {
        setState(() => error = weatherError(e));
      }
    } finally {
      if (mounted && version == generation) setState(() => loading = false);
    }
  }

  List<Widget> table() {
    final a = result![0],
        b = result![1],
        analysis = getIt<WeatherAnalysisService>();
    final da = analysis.evaluate(a), db = analysis.evaluate(b);
    final nameA = widget.stages.firstWhere((s) => s.id == first).name,
        nameB = widget.stages.firstWhere((s) => s.id == second).name;
    final rows = <List<String>>[
      ['Температура', metric(a.temp, ' °C'), metric(b.temp, ' °C')],
      ['Ветер', metric(a.windSpeed, ' м/с'), metric(b.windSpeed, ' м/с')],
      ['Влажность', metric(a.humidity, '%'), metric(b.humidity, '%')],
      ['Облачность', metric(a.cloudPct, '%'), metric(b.cloudPct, '%')],
      ['Условия', a.condition, b.condition],
      ['Сложность', da.label, db.label],
      [
        'Баллы',
        da.score?.toString() ?? 'Нет данных',
        db.score?.toString() ?? 'Нет данных',
      ],
    ];
    final summary = da.score == null || db.score == null
        ? 'Недостаточно данных для вывода о погодной сложности.'
        : da.score == db.score
        ? 'Погодная сложность участков одинакова.'
        : 'На участке «${da.score! < db.score! ? nameA : nameB}» погодные условия более благоприятные для проведения заезда.';
    return [
      Panel(
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(),
            2: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: const TableBorder(
            horizontalInside: BorderSide(color: Color(0xff2c3038)),
          ),
          children: [
            TableRow(
              children: ['Показатель', nameA, nameB]
                  .map(
                    (text) => Padding(
                      padding: const EdgeInsets.fromLTRB(0, 4, 8, 12),
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xffff777e),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            ...rows.map(
              (row) => TableRow(
                children: row
                    .asMap()
                    .entries
                    .map(
                      (cell) => Padding(
                        padding: const EdgeInsets.fromLTRB(0, 12, 8, 12),
                        child: Text(
                          cell.value,
                          style: TextStyle(
                            fontSize: 13,
                            color: cell.key == 0
                                ? Colors.white60
                                : Colors.white,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      Notice(summary, icon: Icons.flag_outlined),
    ];
  }
}
