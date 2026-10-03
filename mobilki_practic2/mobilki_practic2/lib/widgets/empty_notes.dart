import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Подсказка, которая показывается, пока заметок нет.
class EmptyNotes extends StatelessWidget {
  const EmptyNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.note_alt_outlined,
            size: 56,
            color: AppColors.iconMuted,
          ),
          const SizedBox(height: 12),
          const Text(
            'Пока нет заметок',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
