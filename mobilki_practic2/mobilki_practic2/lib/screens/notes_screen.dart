import 'package:flutter/material.dart';
// context.read/context.watch приходят из flutter_bloc: он реэкспортирует
// extensions пакета provider, поэтому отдельный импорт provider не нужен.
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/theme_cubit.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
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
  ///
  /// Данные меняет провайдер (он же сохраняет их в хранилище), а анимацию
  /// списка запускает экран — поэтому вставка и удаление остаются парой
  /// действий в одном обработчике.
  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final provider = context.read<NotesProvider>();
    final editingIndex = _editingIndex;
    if (editingIndex != null) {
      provider.update(editingIndex, text);
      setState(() => _editingIndex = null);
    } else {
      provider.add(text);
      _listKey.currentState?.insertItem(0);
      _scrollToTop();
    }

    _clearInput();
  }

  /// Текст заметки переносится в то же поле, где она была создана.
  void _startEdit(int index) {
    final notes = context.read<NotesProvider>().notes;
    if (index < 0 || index >= notes.length) return;

    setState(() => _editingIndex = index);
    _controller.text = notes[index].text;
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  void _cancelEdit() {
    setState(() => _editingIndex = null);
    _clearInput();
  }

  void _deleteNote(int index) {
    final provider = context.read<NotesProvider>();
    final notes = provider.notes;
    if (index < 0 || index >= notes.length) return;

    final note = notes[index];
    provider.remove(index);
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
    final scheme = Theme.of(context).colorScheme;
    // Список берём у провайдера: при изменении заметок экран перестраивается
    // сам, а сами заметки уже лежат в хранилище.
    final notes = context.watch<NotesProvider>().notes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заметки'),
        actions: [
          BlocBuilder<ThemeCubit, ThemeState>(
            // Иконка зависит от состояния, поэтому перестраивается вместе с ним.
            builder: (context, state) => IconButton(
              tooltip: state.isDarkTheme
                  ? 'Включить светлую тему'
                  : 'Включить тёмную тему',
              icon: Icon(
                state.isDarkTheme
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              color: scheme.onSurfaceVariant,
              onPressed: context.read<ThemeCubit>().toggleTheme,
            ),
          ),
          if (notes.isNotEmpty)
            Flexible(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '${notes.length} ${pluralize(notes.length, 'заметка', 'заметки', 'заметок')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
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
          Expanded(child: _buildNotes(notes)),
        ],
      ),
    );
  }

  Widget _buildNotes(List<Note> notes) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedList(
          key: _listKey,
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemBuilder: (context, index, animation) {
            if (index >= notes.length) return const SizedBox.shrink();
            return NoteCard(
              note: notes[index],
              animation: animation,
              onEdit: () => _startEdit(index),
              onDelete: () => _deleteNote(index),
            );
          },
        ),
        if (notes.isEmpty)
          const Positioned.fill(child: IgnorePointer(child: EmptyNotes())),
      ],
    );
  }
}
