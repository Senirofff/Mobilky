import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobilki_practic2/main.dart';

Widget buildApp() => const NotesApp();

/// Вводит текст и дожидается перерисовки: кнопка «Сохранить»
/// становится активной только на следующем кадре.
Future<void> addNote(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pumpAndSettle();
  await tester.tap(find.byType(FilledButton), warnIfMissed: false);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('на экране есть поле ввода и кнопка «Сохранить»', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());

    expect(find.text('Мои заметки'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Сохранить'), findsOneWidget);
    expect(find.text('Пока нет заметок'), findsOneWidget);
  });

  testWidgets('введённый текст сохраняется в список', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await addNote(tester, 'Купить хлеб');

    expect(find.text('Купить хлеб'), findsOneWidget);
    expect(find.text('Пока нет заметок'), findsNothing);
  });

  testWidgets('заметку можно отредактировать', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await addNote(tester, 'Купить хлеб');

    await tester.tap(find.byTooltip('Редактировать').first);
    await tester.pumpAndSettle();
    expect(find.text('Редактирование заметки'), findsOneWidget);

    await addNote(tester, 'Купить хлеб и молоко');

    expect(find.text('Купить хлеб и молоко'), findsOneWidget);
    expect(find.text('Купить хлеб'), findsNothing);
    expect(find.text('Редактирование заметки'), findsNothing);
  });

  testWidgets('правку можно отменить', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await addNote(tester, 'Купить хлеб');

    await tester.tap(find.byTooltip('Редактировать').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Другой текст');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();

    expect(find.text('Купить хлеб'), findsOneWidget);
    expect(find.text('Другой текст'), findsNothing);
  });

  testWidgets('заметку можно удалить', (WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await addNote(tester, 'Позвонить другу');

    await tester.tap(find.byTooltip('Удалить').first);
    await tester.pumpAndSettle();

    expect(find.text('Позвонить другу'), findsNothing);
    expect(find.text('Пока нет заметок'), findsOneWidget);
  });
}
