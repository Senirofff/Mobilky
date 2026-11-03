import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';

/// Хранилище заметок поверх [SharedPreferences].
///
/// Единственное место, которое знает формат хранения: JSON-массив заметок
/// под ключом [storageKey]. Логики заметок здесь нет — только чтение и
/// запись, благодаря чему провайдер не зависит от конкретного хранилища.
class NotesRepository {
  NotesRepository(this._preferences);

  /// Ключ, под которым лежит JSON-массив заметок.
  ///
  /// Версия в имени ключа: если формат когда-нибудь изменится, старые данные
  /// просто не будут прочитаны и не сломают запуск приложения.
  static const String storageKey = 'notes_v1';

  final SharedPreferences _preferences;

  /// Открывает хранилище. Вызывается в `main()` до `runApp`.
  static Future<NotesRepository> open() async {
    return NotesRepository(await SharedPreferences.getInstance());
  }

  /// Читает сохранённые заметки.
  ///
  /// Синхронно: сам [SharedPreferences] уже загружен в [open], поэтому список
  /// доступен сразу и приложение не мелькает пустым экраном. Повреждённые
  /// данные приводят к пустому списку, а не к ошибке запуска.
  List<Note> load() {
    final raw = _preferences.getString(storageKey);
    if (raw == null || raw.isEmpty) return <Note>[];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Note.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return <Note>[];
    }
  }

  /// Сохраняет список заметок целиком (перезаписывает прежний).
  Future<void> save(List<Note> notes) {
    final encoded = jsonEncode(notes.map((note) => note.toJson()).toList());
    return _preferences.setString(storageKey, encoded);
  }
}
