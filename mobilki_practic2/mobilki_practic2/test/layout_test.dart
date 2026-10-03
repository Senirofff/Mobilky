import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobilki_practic2/main.dart';

void main() {
  Future<void> addNote(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton), warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  // Flutter сообщает о переполнении через ошибку в тесте, поэтому достаточно
  // проверить, что исключений нет: это охраняет вёрстку на разных экранах,
  // при крупном системном шрифте и с длинным текстом заметки.
  Future<void> checkLayout(
    WidgetTester tester,
    Size size,
    double textScale,
    String note, {
    bool editing = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: const NotesApp(),
      ),
    );
    await addNote(tester, note);
    if (editing) {
      // На низком экране карточка может быть ниже видимой области,
      // поэтому перед нажатием прокручиваем к ней.
      final editFinder = find.byTooltip('Редактировать');
      if (editFinder.evaluate().isNotEmpty) {
        await tester.ensureVisible(editFinder.first);
        await tester.pumpAndSettle();
        await tester.tap(editFinder.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    }
    expect(tester.takeException(), isNull);
  }

  const longNote =
      'Заметка с очень длинным текстом без пробелов, '
      'который должен переноситься по строкам в карточке';

  testWidgets('вёрстка не ломается на узком экране', (tester) async {
    await checkLayout(tester, const Size(320, 568), 1, longNote);
  });

  testWidgets('вёрстка выдерживает крупный системный шрифт', (tester) async {
    await checkLayout(tester, const Size(320, 568), 1.6, longNote);
  });

  testWidgets('вёрстка выдерживает режим правки и крупный шрифт', (
    tester,
  ) async {
    await checkLayout(
      tester,
      const Size(320, 568),
      1.4,
      longNote,
      editing: true,
    );
  });

  testWidgets('вёрстка выдерживает очень маленький экран', (tester) async {
    await checkLayout(tester, const Size(280, 480), 1, longNote, editing: true);
  });

  testWidgets('вёрстка выдерживает планшет', (tester) async {
    await checkLayout(
      tester,
      const Size(900, 1200),
      1,
      longNote,
      editing: true,
    );
  });

  testWidgets('список из many заметок прокручивается', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const NotesApp());
    for (var i = 0; i < 12; i++) {
      await addNote(tester, 'Заметка номер ${i + 1}');
    }

    // новые заметки добавляются в начало списка
    expect(find.text('Заметка номер 12'), findsOneWidget);

    await tester.fling(find.byType(AnimatedList), const Offset(0, -600), 2000);
    await tester.pumpAndSettle();

    final list = tester.widget<AnimatedList>(find.byType(AnimatedList));
    expect(list.controller!.offset, greaterThan(0));
    expect(find.text('Заметка номер 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
