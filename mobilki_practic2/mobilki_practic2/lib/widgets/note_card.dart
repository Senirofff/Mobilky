import 'package:flutter/material.dart';

import '../models/note.dart';

/// Карточка заметки в списке.
///
/// [animation] приходит из `AnimatedList`, поэтому заметка плавно
/// появляется и плавно исчезает при удалении.
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.animation,
    required this.onEdit,
    required this.onDelete,
  });

  final Note note;
  final Animation<double> animation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SizeTransition(
      sizeFactor: animation,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                // На тёмном фоне тень заметнее, на светлом — почти незаметна.
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.text,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: onEdit,
                    tooltip: 'Редактировать',
                    iconSize: 20,
                    color: scheme.outline,
                    icon: const Icon(Icons.create_outlined),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    tooltip: 'Удалить',
                    iconSize: 20,
                    color: scheme.error,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
