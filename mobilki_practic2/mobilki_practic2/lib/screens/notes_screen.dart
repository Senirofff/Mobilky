import 'package:flutter/material.dart';

import '../models/note.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/empty_notes.dart';
import '../widgets/note_card.dart';
import '../widgets/note_composer.dart';

/// Экран «Заметки»: одно поле ввода, кнопка «Сохранить» и список заметок.
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  /// Заметки в памяти; новые добавляются в начало списка.
  final List<Note> _notes = [];

  String _displayText = '';
  int? _editingIndex;

  bool get _isEditing => _editingIndex != null;
  bool get _canSubmit => _displayText.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Слушаем контроллер, чтобы включать кнопку «Сохранить»,
    // как только в поле появился текст.
    _controller.addListener(() {
      setState(() => _displayText = _controller.text);
    });
  }

  @override
  void dispose() {
    // Контроллер обязательно освобождаем, иначе будет утечка памяти.
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Действия с заметками -------------------------------------------------

  /// Кнопка «Сохранить»: добавляет новую заметку или сохраняет правку.
  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final editingIndex = _editingIndex;
    if (editingIndex != null) {
      _notes[editingIndex] = Note(text);
      setState(() => _editingIndex = null);
    } else {
      _notes.insert(0, Note(text));
      _listKey.currentState?.insertItem(0);
      _scrollToTop();
    }

    _clearInput();
  }

  /// Текст заметки переносится в то же поле, где она была создана.
  void _startEdit(int index) {
    setState(() => _editingIndex = index);
    _controller.text = _notes[index].text;
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  void _cancelEdit() {
    setState(() => _editingIndex = null);
    _clearInput();
  }

  void _deleteNote(int index) {
    if (index < 0 || index >= _notes.length) return;

    final note = _notes.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => NoteCard(
        note: note,
        animation: animation,
        onEdit: () {},
        onDelete: () {},
      ),
    );

    // Если правилась удалённая или соседняя заметка — поправляем индекс.
    final editingIndex = _editingIndex;
    if (editingIndex != null) {
      if (editingIndex == index) {
        _cancelEdit();
      } else if (editingIndex > index) {
        setState(() => _editingIndex = editingIndex - 1);
      }
    }

    setState(() {});
  }

  void _clearInput() {
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  // --- Интерфейс ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заметки'),
        actions: [
          if (_notes.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_notes.length} ${pluralize(_notes.length, 'заметка', 'заметки', 'заметок')}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          NoteComposer(
            controller: _controller,
            hintText: _isEditing
                ? 'Измените текст заметки'
                : 'Введите текст заметки',
            isEditing: _isEditing,
            canSubmit: _canSubmit,
            onSubmit: _submit,
            onCancel: _cancelEdit,
          ),
          Expanded(child: _buildNotes()),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedList(
          key: _listKey,
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemBuilder: (context, index, animation) {
            if (index >= _notes.length) return const SizedBox.shrink();
            return NoteCard(
              note: _notes[index],
              animation: animation,
              onEdit: () => _startEdit(index),
              onDelete: () => _deleteNote(index),
            );
          },
        ),
        if (_notes.isEmpty)
          const Positioned.fill(child: IgnorePointer(child: EmptyNotes())),
      ],
    );
  }
}
