import 'package:flutter/material.dart';

import '../models/rally_stage.dart';
import '../models/weather_model.dart';
import '../services/weather_analysis_service.dart';

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xff191c23),
      borderRadius: BorderRadius.circular(14),
    ),
    child: child,
  );
}

class Notice extends StatelessWidget {
  const Notice(this.text, {super.key, this.icon = Icons.info_outline});
  final String text;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Panel(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: const Color(0xffff777e)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.white70)),
        ),
      ],
    ),
  );
}

class StagePicker extends StatelessWidget {
  const StagePicker({
    super.key,
    required this.stages,
    required this.value,
    required this.onChanged,
    this.label = 'Спецучасток',
    this.exclude,
  });
  final List<RallyStage> stages;
  final String? value, exclude;
  final String label;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) {
    final available = stages.where((s) => s.id != exclude).toList();
    final selected = available.where((s) => s.id == value).firstOrNull;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LayoutBuilder(
        builder: (context, bounds) {
          final width = bounds.maxWidth;
          final height = (MediaQuery.sizeOf(context).height * .45).clamp(
            120.0,
            320.0,
          );
          return Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
            ),
            child: PopupMenuButton<String>(
              tooltip: 'Выбрать участок',
              enabled: available.isNotEmpty,
              position: PopupMenuPosition.under,
              offset: const Offset(0, 8),
              constraints: BoxConstraints(
                minWidth: width,
                maxWidth: width,
                maxHeight: height,
              ),
              color: const Color(0xff22262e),
              surfaceTintColor: Colors.transparent,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xff454b57)),
              ),
              clipBehavior: Clip.antiAlias,
              menuPadding: const EdgeInsets.symmetric(vertical: 6),
              popUpAnimationStyle: MediaQuery.disableAnimationsOf(context)
                  ? AnimationStyle.noAnimation
                  : const AnimationStyle(
                      duration: Duration(milliseconds: 240),
                      reverseDuration: Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      reverseCurve: Curves.easeInCubic,
                    ),
              onSelected: onChanged,
              itemBuilder: (context) => available
                  .map(
                    (stage) => PopupMenuItem<String>(
                      value: stage.id,
                      height: 56,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              stage.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                color: stage.id == value
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.white,
                              ),
                            ),
                          ),
                          if (stage.id == value) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.check,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                  .toList(),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: const TextStyle(color: Color(0xffff777e)),
                  prefixIconColor: const Color(0xffff777e),
                  suffixIconColor: const Color(0xffff777e),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xff74404b)),
                  ),
                  prefixIcon: const Icon(Icons.route_outlined),
                  suffixIcon: const Icon(Icons.expand_more),
                ),
                isEmpty: false,
                child: Text(
                  selected?.name ?? 'Выберите участок',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected == null ? Colors.white54 : Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge(this.difficulty, {super.key});
  final Difficulty difficulty;
  @override
  Widget build(BuildContext context) {
    final score = difficulty.score;
    final color = score == null
        ? Colors.grey
        : score == 0
        ? const Color(0xff73deb0)
        : score < 3
        ? const Color(0xffffce6b)
        : const Color(0xffff6969);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${difficulty.label}${score == null ? '' : ' · $score б.'}',
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

IconData weatherIcon(WeatherModel w) => switch (w.condition) {
  'Ясно' => Icons.wb_sunny_outlined,
  'Дождь' => Icons.water_drop_outlined,
  'Снег' => Icons.ac_unit,
  'Гроза' => Icons.thunderstorm_outlined,
  'Туман' || 'Дымка' => Icons.blur_on,
  _ => Icons.cloud_outlined,
};

class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
    required this.weather,
    required this.analysis,
    this.title = 'Сейчас на участке',
  });
  final WeatherModel weather;
  final WeatherAnalysisService analysis;
  final String title;
  @override
  Widget build(BuildContext context) {
    final w = weather, d = analysis.evaluate(weather);
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: const Color(0xffff777e)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(weatherIcon(w), size: 40, color: const Color(0xffffce6b)),
              Text(
                metric(w.temp, '°'),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -2,
                ),
              ),
            ],
          ),
          Text(w.condition, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Ощущается как ${metric(w.feelsLike, ' °C')}',
            style: const TextStyle(color: Colors.white60),
          ),
          const Divider(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              stat(Icons.air, 'Ветер', metric(w.windSpeed, ' м/с')),
              stat(
                Icons.explore_outlined,
                'Направление',
                metric(w.windDegrees, '°'),
              ),
              stat(
                Icons.water_drop_outlined,
                'Влажность',
                metric(w.humidity, '%'),
              ),
              stat(Icons.cloud_outlined, 'Облачность', metric(w.cloudPct, '%')),
            ],
          ),
          const Divider(height: 24),
          DifficultyBadge(d),
          const SizedBox(height: 12),
          Text(d.recommendation),
        ],
      ),
    );
  }

  Widget stat(IconData icon, String label, String value) => SizedBox(
    width: 120,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xffff777e)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(label, style: const TextStyle(color: Colors.white60)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ],
    ),
  );
}

class DaySelector extends StatelessWidget {
  const DaySelector({
    super.key,
    required this.days,
    required this.selected,
    required this.onSelected,
  });
  final List<String> days;
  final String? selected;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: days
          .map(
            (d) => Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 16),
              child: ChoiceChip(
                label: Text(dayLabel(d)),
                selectedColor: const Color(0xff51232b),
                checkmarkColor: const Color(0xffff777e),
                labelStyle: TextStyle(
                  color: d == selected
                      ? const Color(0xffff777e)
                      : Colors.white70,
                ),
                side: BorderSide(
                  color: d == selected
                      ? const Color(0xffa64c5b)
                      : const Color(0xff34313a),
                ),
                selected: d == selected,
                onSelected: (_) => onSelected(d),
              ),
            ),
          )
          .toList(),
    ),
  );
}

List<String> forecastDays(List<WeatherModel> forecast) => forecast
    .where(
      (w) =>
          w.timestamp != null && w.timestamp!.isAfter(DateTime.now().toUtc()),
    )
    .map((w) => dayKey(w.timestamp!))
    .toSet()
    .take(5)
    .toList();
