# Заметки (mobilki_practic2)

Приложение «Заметки» на Flutter — учебная работа по темам
«Работа с текстом в Flutter: `TextEditingController` и `ListView`»,
«Управление состоянием: `Cubit`» и «Хранение данных: `Provider`
и `SharedPreferences`».

## Что умеет

- ввод текста в поле и сохранение заметки по кнопке **«Сохранить»**;
- список заметок: новые добавляются в начало, у каждой — кнопки правки
  и удаления;
- **редактирование** заметки: текст переносится в то же поле ввода,
  повторное «Сохранить» применяет правку, «Отмена» возвращает поле в исходное
  состояние;
- **удаление** заметки;
- счётчик заметок в шапке и подсказка, пока заметок нет;
- **переключение тёмной и светлой темы** кнопкой в шапке — состояние темы
  хранится в `ThemeCubit` (`flutter_bloc`);
- заметки **сохраняются между запусками**: список и операции над ним живут в
  `NotesProvider` (`provider`), а хранит их `NotesRepository` поверх
  `SharedPreferences`.

Выбранная тема между запусками не сохраняется — это отдельная задача.

## Как устроены заметки

```
main()
  ├─ NotesRepository.open()                    — открывает SharedPreferences до runApp
  └─ NotesApp → MultiProvider
       ├─ ChangeNotifierProvider<NotesProvider> — список заметок целиком
       │    └─ NotesProvider.load()             — читает сохранённое до первого кадра
       └─ BlocProvider<ThemeCubit>              — состояние темы (как и раньше)
            └─ MaterialApp → NotesScreen
```

Единственный владелец списка — `NotesProvider`: он хранит заметки и после
каждой операции (`add`/`update`/`remove`) ставит сохранение в очередь, чтобы
записи уходили в хранилище по порядку. Формат хранения знает только
`NotesRepository` — JSON-массив заметок под ключом `notes_v1`; повреждённые
данные приводят к пустому списку, а не к ошибке запуска.

Экран остаётся владельцем того, что привязано к интерфейсу: контроллера поля
ввода, режима правки (`_editingIndex`) и `AnimatedList`. Поэтому вставку и
удаление с анимацией по-прежнему запускает экран — сразу после вызова метода
провайдера, — и отдельный слушатель изменений не нужен.

## Как устроена тема

```
main.dart → MultiProvider
  └─ BlocProvider<ThemeCubit>        — создаёт Cubit на всё время работы приложения
       └─ BlocBuilder<ThemeCubit, ThemeState>
            └─ MaterialApp(theme: светлая, darkTheme: тёмная, themeMode: state)
screens/notes_screen.dart             — BlocBuilder для иконки солнца/луны в AppBar
theme/app_theme.dart                  — buildAppTheme(Brightness) для обеих тем
```

Виджеты ничего не знают про переключение: они берут цвета из
`Theme.of(context).colorScheme` (`surface`, `onSurface`, `onSurfaceVariant`,
`outline`, `error`, `primary`), поэтому смена темы меняет весь интерфейс без
правок в самих виджетах.

## Структура

```
lib/
  main.dart                    запуск, открытие хранилища, MultiProvider
  data/notes_repository.dart   чтение/запись заметок (SharedPreferences, JSON)
  providers/notes_provider.dart список заметок и операции над ним
  cubit/theme_cubit.dart       ThemeCubit и ThemeState: состояние темы
  theme/app_theme.dart         палитры светлой и тёмной темы
  models/note.dart             заметка: идентификатор и текст
  utils/format.dart            склонения числительных
  screens/notes_screen.dart    экран: ввод, правка, анимированный список
  widgets/
    note_composer.dart         поле ввода + кнопка «Сохранить»
    note_card.dart             карточка заметки
    empty_notes.dart           заглушка, когда заметок нет
```

## Запуск

```bash
flutter pub get
flutter run
```

## Проверка

```bash
flutter analyze     # статический анализ кода
```

Автоматических тестов в проекте пока нет.