/// Заметка: текст, который пользователь ввёл в поле.
class Note {
  const Note({required this.id, required this.text});

  /// Идентификатор заметки: время создания в микросекундах.
  ///
  /// Отличает заметки друг от друга независимо от позиции в списке и не
  /// теряется при сохранении, поэтому одинаковые по тексту заметки остаются
  /// разными записями.
  final int id;

  final String text;

  /// Представление для записи в хранилище (JSON-объект).
  Map<String, dynamic> toJson() => {'id': id, 'text': text};

  /// Восстанавливает заметку из JSON-объекта хранилища.
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(id: json['id'] as int, text: json['text'] as String);
  }
}
