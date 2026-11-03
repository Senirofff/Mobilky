import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/notes_repository.dart';
import '../models/note.dart';

/// Состояние заметок: список и операции над ним.
///
/// Единственный владелец списка: провайдер хранит заметки и сохраняет их в
/// [NotesRepository] после каждого изменения. Экран только читает список
/// (`context.watch`) и вызывает методы (`context.read`), поэтому данные
/// переживают перезапуск приложения.
class NotesProvider extends ChangeNotifier {
  NotesProvider(this._repository);

  final NotesRepository _repository;
  final List<Note> _notes = [];

  /// Очередь автосохранений: записи уходят в хранилище строго по порядку,
  /// иначе два быстрых изменения могли бы записаться в обратном порядке.
  Future<void> _pendingSave = Future<void>.value();

  /// Заметки только для чтения: неизменяемое представление не даёт виджетам
  /// менять список в обход провайдера.
  UnmodifiableListView<Note> get notes => UnmodifiableListView(_notes);

  /// Загружает сохранённые заметки (вызывается до `runApp`).
  void load() {
    _notes
      ..clear()
      ..addAll(_repository.load());
    notifyListeners();
  }

  /// Добавляет заметку в начало списка — новые заметки всегда сверху.
  void add(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _notes.insert(0, Note(id: _newId(), text: trimmed));
    _afterChange();
  }

  /// Заменяет текст заметки, сохраняя её идентификатор.
  void update(int index, String text) {
    final trimmed = text.trim();
    if (!_isValidIndex(index) || trimmed.isEmpty) return;

    _notes[index] = Note(id: _notes[index].id, text: trimmed);
    _afterChange();
  }

  /// Удаляет заметку по её позиции в списке.
  void remove(int index) {
    if (!_isValidIndex(index)) return;

    _notes.removeAt(index);
    _afterChange();
  }

  bool _isValidIndex(int index) => index >= 0 && index < _notes.length;

  /// Идентификатор новой заметки — время создания в микросекундах.
  int _newId() => DateTime.now().microsecondsSinceEpoch;

  /// Сообщает слушателям об изменении и ставит сохранение в очередь.
  void _afterChange() {
    notifyListeners();
    _pendingSave = _pendingSave.then((_) async {
      try {
        await _repository.save(_notes);
      } catch (error) {
        // Ошибка записи не должна ломать цепочку следующих сохранений.
        debugPrint('Не удалось сохранить заметки: $error');
      }
    });
  }
}
