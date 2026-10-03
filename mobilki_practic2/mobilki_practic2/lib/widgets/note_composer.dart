import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Поле ввода новой заметки и кнопка «Сохранить».
///
/// Поле одно на всё приложение: и новые заметки, и правки вводятся здесь.
class NoteComposer extends StatelessWidget {
  const NoteComposer({
    super.key,
    required this.controller,
    required this.hintText,
    required this.isEditing,
    required this.canSubmit,
    required this.onSubmit,
    required this.onCancel,
  });

  final TextEditingController controller;
  final String hintText;

  /// Редактируется существующая заметка: показываем подпись и «Отмена».
  final bool isEditing;
  final bool canSubmit;

  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Редактирование заметки',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Отмена'),
                  ),
                ],
              ),
            ),
          TextField(
            controller: controller,
            minLines: 1,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.sentences,
            cursorColor: AppColors.accent,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: AppColors.textMuted),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: canSubmit ? onSubmit : null,
              child: const Text('Сохранить'),
            ),
          ),
        ],
      ),
    );
  }
}
