import 'package:flutter/material.dart';

import '../models/note.dart';
import '../theme/app_theme.dart';

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
    return SizeTransition(
      sizeFactor: animation,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
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
                style: const TextStyle(
                  color: Colors.white,
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
                    color: AppColors.iconMuted,
                    icon: const Icon(Icons.create_outlined),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    tooltip: 'Удалить',
                    iconSize: 20,
                    color: AppColors.danger,
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
