import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/stages_cubit.dart';
import '../models/rally_stage.dart';
import '../widgets/weather_widgets.dart';

class StagesScreen extends StatelessWidget {
  const StagesScreen({super.key, required this.onAnalyze});
  final ValueChanged<RallyStage> onAnalyze;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<StagesCubit, List<RallyStage>>(
        builder: (context, stages) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (context.read<StagesCubit>().loadError case final String error)
              Notice(error),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Text(
                'Сохранено участков: ${stages.length}',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
            if (stages.isEmpty)
              const Notice(
                'Нет сохранённых участков. Нажмите «Добавить участок» и укажите координаты.',
                icon: Icons.route_outlined,
              ),
            ...stages.asMap().entries.map((entry) {
              final stage = entry.value;
              return Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xff342127),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: Color(0xffff777e),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stage.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                stage.coordinates,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => onAnalyze(stage),
                              icon: const Icon(
                                Icons.insights_outlined,
                                size: 18,
                              ),
                              label: const Text('Анализ погоды'),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Редактировать',
                          onPressed: () => editStage(context, stage),
                          icon: const Icon(Icons.edit_outlined, size: 20),
                        ),
                        IconButton(
                          tooltip: 'Удалить',
                          onPressed: () => deleteStage(context, stage),
                          icon: const Icon(Icons.delete_outline, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
  Future<void> deleteStage(BuildContext context, RallyStage stage) async {
    final confirmed = await showDialog<bool>(
      context: context,
      animationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: Duration(milliseconds: 240),
              reverseDuration: Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            ),
      builder: (c) => AlertDialog(
        title: const Text('Удалить участок?'),
        content: Text('«${stage.name}» будет удалён из сохранённых участков.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await context.read<StagesCubit>().remove(stage.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось удалить участок. Повторите попытку.'),
          ),
        );
      }
    }
  }

  static Future<void> editStage(
    BuildContext context, [
    RallyStage? stage,
  ]) async {
    final cubit = context.read<StagesCubit>();
    await showModalBottomSheet<void>(
      context: context,
      sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: Duration(milliseconds: 300),
              reverseDuration: Duration(milliseconds: 220),
            ),
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => StageDialog(cubit: cubit, stage: stage),
    );
  }
}

class StageDialog extends StatefulWidget {
  const StageDialog({super.key, required this.cubit, this.stage});
  final StagesCubit cubit;
  final RallyStage? stage;
  @override
  State<StageDialog> createState() => _StageDialogState();
}

class _StageDialogState extends State<StageDialog> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.stage?.name);
  late final lat = TextEditingController(
    text: widget.stage?.latitude.toString(),
  );
  late final lon = TextEditingController(
    text: widget.stage?.longitude.toString(),
  );
  bool saving = false;
  String? error;
  @override
  void dispose() {
    name.dispose();
    lat.dispose();
    lon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.stage == null
                    ? 'Новый участок'
                    : 'Редактировать участок',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: name,
                maxLength: 80,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Название'),
                validator: (v) =>
                    RallyStage.validName(v ?? '') ? null : 'Укажите название',
              ),
              const SizedBox(height: 12),
              field(lat, true),
              const SizedBox(height: 16),
              field(lon, false),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: saving ? null : save,
                child: Text(saving ? 'Сохранение…' : 'Сохранить'),
              ),
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Widget field(TextEditingController controller, bool latitude) =>
      TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        decoration: InputDecoration(
          labelText: latitude ? 'Широта' : 'Долгота',
          helperText: latitude ? 'От −90 до 90' : 'От −180 до 180',
        ),
        validator: (v) =>
            RallyStage.coordinate(v ?? '', latitude: latitude) == null
            ? 'Введите корректную координату'
            : null,
      );
  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.cubit.put(
        RallyStage(
          id:
              widget.stage?.id ??
              DateTime.now().microsecondsSinceEpoch.toString(),
          name: name.text.trim(),
          latitude: RallyStage.coordinate(lat.text, latitude: true)!,
          longitude: RallyStage.coordinate(lon.text, latitude: false)!,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          error = 'Не удалось сохранить участок. Повторите попытку.';
        });
      }
    }
  }
}
