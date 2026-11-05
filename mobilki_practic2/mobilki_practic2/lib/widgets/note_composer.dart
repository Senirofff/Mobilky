import 'package:flutter/material.dart';

class NoteComposer extends StatelessWidget {
  const NoteComposer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.isEditing,
    required this.canSubmit,
    required this.onSubmit,
    required this.onCancel,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool isEditing;
  final bool canSubmit;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isEditing ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            focusNode: focusNode,
            minLines: 1,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.sentences,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: scheme.onSurfaceVariant),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (isEditing || canSubmit)
                  TextButton(
                    onPressed: onCancel,
                    child: Text(isEditing ? 'Отмена' : 'Очистить'),
                  ),
                FilledButton.icon(
                  onPressed: canSubmit ? onSubmit : null,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Сохранить'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
