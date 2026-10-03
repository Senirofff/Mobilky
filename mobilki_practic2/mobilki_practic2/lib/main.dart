import 'package:flutter/material.dart';

import 'screens/notes_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Заметки',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const NotesScreen(),
    );
  }
}
