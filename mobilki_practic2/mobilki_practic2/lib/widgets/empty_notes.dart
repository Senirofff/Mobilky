import 'package:flutter/material.dart';

/// Подсказка, которая показывается, пока заметок нет.
class EmptyNotes extends StatelessWidget {
  const EmptyNotes({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_alt_outlined, size: 56, color: scheme.outline),
          const SizedBox(height: 12),
          Text(
            'Пока нет заметок',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
