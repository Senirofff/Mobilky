import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/theme_cubit.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../utils/format.dart';
import '../widgets/empty_notes.dart';
import '../widgets/note_card.dart';
import '../widgets/note_composer.dart';
import 'note_detail_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _inputFocus = FocusNode();
  final _listKey = GlobalKey<SliverAnimatedListState>();
  int? _editingId;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final provider = context.read<NotesProvider>();
    if (_editingId != null) {
      final index = provider.notes.indexWhere((note) => note.id == _editingId);
      if (index < 0) return;
      provider.update(index, text);
    } else {
      final index = provider.add(text);
      if (index != null) _listKey.currentState?.insertItem(index);
    }
    _clearInput();
  }

  Future<void> _openNote(Note note) async {
    FocusScope.of(context).unfocus();
    final edit = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
    );
    if (!mounted || edit != true) return;
    _startEdit(note);
  }

  void _startEdit(Note note) {
    // Не затираем несохранённый черновик другим текстом.
    if (_controller.text.trim().isNotEmpty && _editingId != note.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала сохраните или очистите текущий текст'),
        ),
      );
      return;
    }
    if (_editingId != note.id) {
      setState(() => _editingId = note.id);
      _controller.text = note.text;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
    _inputFocus.requestFocus();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _clearInput() {
    setState(() => _editingId = null);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  void _setImportant(int id, bool isImportant) {
    final provider = context.read<NotesProvider>();
    final oldIndex = provider.notes.indexWhere((note) => note.id == id);
    if (oldIndex < 0 || provider.notes[oldIndex].isImportant == isImportant) {
      return;
    }

    provider.setImportant(id, isImportant);
    final newIndex = provider.notes.indexWhere((note) => note.id == id);
    if (oldIndex == newIndex) return;

    // Синхронизируем позиции AnimatedList с новым порядком провайдера.
    final list = _listKey.currentState;
    list?.removeItem(
      oldIndex,
      (_, _) => const SizedBox.shrink(),
      duration: Duration.zero,
    );
    list?.insertItem(newIndex);
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить заметку?'),
        content: const Text('Восстановить её после удаления не получится.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    _removeNote(note);
  }

  /// Свайп удаляет сразу; удаление из меню запрашивает подтверждение.
  void _removeNote(Note note) {
    final provider = context.read<NotesProvider>();
    final index = provider.notes.indexWhere((item) => item.id == note.id);
    if (index < 0) return;
    provider.remove(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => IgnorePointer(
        child: NoteCard(
          note: note,
          animation: animation,
          onTap: () {},
          onMarkImportant: () {},
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );
    if (_editingId == note.id) _clearInput();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final notes = context.watch<NotesProvider>().notes;
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: CustomScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 16, 16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Мои заметки',
                                style: theme.textTheme.titleLarge,
                              ),
                              if (notes.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${notes.length} ${pluralize(notes.length, 'заметка', 'заметки', 'заметок')}',
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        BlocBuilder<ThemeCubit, ThemeState>(
                          builder: (context, state) => IconButton.filledTonal(
                            tooltip: state.isDarkTheme
                                ? 'Включить светлую тему'
                                : 'Включить тёмную тему',
                            onPressed: context.read<ThemeCubit>().toggleTheme,
                            icon: Icon(
                              state.isDarkTheme
                                  ? Icons.light_mode_outlined
                                  : Icons.dark_mode_outlined,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, _) => NoteComposer(
                      controller: _controller,
                      focusNode: _inputFocus,
                      hintText: _editingId != null
                          ? 'Измените текст заметки…'
                          : 'Введите текст заметки',
                      isEditing: _editingId != null,
                      canSubmit: value.text.trim().isNotEmpty,
                      onSubmit: _submit,
                      onCancel: _clearInput,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverAnimatedList(
                    key: _listKey,
                    initialItemCount: notes.length,
                    itemBuilder: (context, index, animation) {
                      final note = notes[index];
                      return Dismissible(
                        key: ValueKey(note.id),
                        direction: DismissDirection.horizontal,
                        resizeDuration: null,
                        background: _swipeBackground(
                          alignment: Alignment.centerLeft,
                          color: scheme.primaryContainer,
                          foreground: scheme.onPrimaryContainer,
                          icon: Icons.star_outline_rounded,
                        ),
                        secondaryBackground: _swipeBackground(
                          alignment: Alignment.centerRight,
                          color: scheme.errorContainer,
                          foreground: scheme.onErrorContainer,
                          icon: Icons.delete_outline_rounded,
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            _setImportant(note.id, false);
                            return false;
                          }
                          return true;
                        },
                        onDismissed: (_) => _removeNote(note),
                        child: NoteCard(
                          note: note,
                          animation: animation,
                          onTap: () => _openNote(note),
                          onMarkImportant: () => _setImportant(note.id, true),
                          onEdit: () => _startEdit(note),
                          onDelete: () => _deleteNote(note),
                        ),
                      );
                    },
                  ),
                ),
                if (notes.isEmpty)
                  const SliverToBoxAdapter(child: EmptyNotes()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _swipeBackground({
    required Alignment alignment,
    required Color color,
    required Color foreground,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: foreground),
    );
  }
}
