import 'package:flutter/material.dart';

import '../models/note.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.animation,
    required this.onTap,
    required this.onMarkImportant,
    required this.onEdit,
    required this.onDelete,
  });

  final Note note;
  final Animation<double> animation;
  final VoidCallback onTap;
  final VoidCallback onMarkImportant;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: note.isImportant
                ? Color.alphaBlend(
                    scheme.primary.withValues(alpha: 0.12),
                    scheme.surface,
                  )
                : scheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: note.isImportant
                    ? scheme.primary
                    : scheme.outlineVariant,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              onDoubleTap: onMarkImportant,
              onLongPress: onEdit,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.isImportant)
                      Padding(
                        padding: const EdgeInsets.only(top: 10, right: 8),
                        child: Icon(
                          Icons.star_rounded,
                          size: 20,
                          color: scheme.primary,
                          semanticLabel: 'Важная заметка',
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          note.text,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Действия с заметкой',
                      onSelected: (action) =>
                          action == 'edit' ? onEdit() : onDelete(),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Редактировать'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete_outline),
                            title: Text('Удалить'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                      icon: Icon(
                        Icons.more_horiz_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
