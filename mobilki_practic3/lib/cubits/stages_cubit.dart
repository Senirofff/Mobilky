import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/rally_stage.dart';
import '../services/stage_storage_service.dart';

class StagesCubit extends Cubit<List<RallyStage>> {
  StagesCubit(this.storage) : super([]) {
    try {
      emit(storage.load());
    } catch (_) {
      loadError =
          'Не удалось прочитать сохранённые участки. Данные повреждены.';
    }
  }
  final StageStorageService storage;
  String? loadError;
  bool _saving = false;
  Future<void> put(RallyStage stage) =>
      _save([...state.where((s) => s.id != stage.id), stage]);
  Future<void> remove(String id) =>
      _save(state.where((s) => s.id != id).toList());
  Future<void> _save(List<RallyStage> next) async {
    if (_saving) throw StateError('Дождитесь сохранения');
    _saving = true;
    try {
      await storage.save(next);
      loadError = null;
      emit(next);
    } finally {
      _saving = false;
    }
  }
}
