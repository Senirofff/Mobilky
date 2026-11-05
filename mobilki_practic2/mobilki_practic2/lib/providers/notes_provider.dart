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
    final savedNotes = _repository.load();
    final regularNotes = savedNotes.where((note) => !note.isImportant).toList()
      ..sort((a, b) => b.id.compareTo(a.id));
    _notes
      ..clear()
      ..addAll(savedNotes.where((note) => note.isImportant))
      ..addAll(regularNotes);
    notifyListeners();
  }

  /// Добавляет новую запись после закреплённых и возвращает её позицию.
  int? add(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final note = Note(id: _newId(), text: trimmed);
    final index = _regularInsertionIndex(note.id);
    _notes.insert(index, note);
    _afterChange();
    return index;
  }

  /// Заменяет текст заметки, сохраняя её идентификатор.
  void update(int index, String text) {
    final trimmed = text.trim();
    if (!_isValidIndex(index) || trimmed.isEmpty) return;

    _notes[index] = _notes[index].copyWith(text: trimmed);
    _afterChange();
  }

  /// Меняет важность по идентификатору, независимо от позиции в списке.
  void setImportant(int id, bool isImportant) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index < 0 || _notes[index].isImportant == isImportant) return;

    final note = _notes.removeAt(index).copyWith(isImportant: isImportant);
    // Закреплённая заметка становится первой, а после снятия закрепления
    // возвращается на своё место по времени создания среди обычных записей.
    _notes.insert(isImportant ? 0 : _regularInsertionIndex(note.id), note);
    _afterChange();
  }

  int _regularInsertionIndex(int id) {
    final index = _notes.indexWhere(
      (note) => !note.isImportant && note.id < id,
    );
    return index < 0 ? _notes.length : index;
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
