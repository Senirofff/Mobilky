import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/rally_stage.dart';

class StageStorageService {
  StageStorageService(this.preferences);
  final SharedPreferences preferences;
  List<RallyStage> load() {
    final raw = preferences.getString('rally_stages');
    if (raw == null) return [];
    final items = jsonDecode(raw);
    if (items is! List) throw const FormatException('Некорректное хранилище');
    return items
        .map((e) => RallyStage.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> save(List<RallyStage> stages) async {
    if (!await preferences.setString(
      'rally_stages',
      jsonEncode(stages.map((s) => s.toJson()).toList()),
    )) {
      throw StateError('Не удалось сохранить участки');
    }
  }
}
