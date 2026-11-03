import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'cubit/theme_cubit.dart';
import 'data/notes_repository.dart';
import 'providers/notes_provider.dart';
import 'screens/notes_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // До обращения к платформенным каналам (SharedPreferences) движок Flutter
  // должен быть инициализирован.
  WidgetsFlutterBinding.ensureInitialized();

  // Хранилище открываем заранее: заметки читаются из него до первого кадра,
  // поэтому список появляется сразу, без «мигания» пустым экраном.
  final repository = await NotesRepository.open();

  runApp(NotesApp(repository: repository));
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key, required this.repository});

  final NotesRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Заметки: провайдер хранит список и сам сохраняет его в хранилище.
        ChangeNotifierProvider(
          create: (_) => NotesProvider(repository)..load(),
        ),
        // Cubit живёт столько же, сколько приложение, поэтому выбранная
        // тема не сбрасывается при перестройке интерфейса.
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        // MaterialApp пересобирается на каждое новое состояние темы,
        // а `themeMode` говорит ему, какую из двух тем показать.
        builder: (context, state) {
          return MaterialApp(
            title: 'Заметки',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(Brightness.light),
            darkTheme: buildAppTheme(Brightness.dark),
            themeMode: state.themeMode,
            home: const NotesScreen(),
          );
        },
      ),
    );
  }
}
