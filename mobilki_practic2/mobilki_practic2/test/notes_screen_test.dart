import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobilki_practic2/data/notes_repository.dart';
import 'package:mobilki_practic2/main.dart';
import 'package:mobilki_practic2/screens/note_detail_screen.dart';
import 'package:mobilki_practic2/widgets/note_card.dart';

const sampleText =
    'Идеи для выходных\nПрогуляться по городу, зайти в любимую кофейню и найти время для хорошей книги.';
final sampleId = DateTime(2026, 11, 5, 12, 30).microsecondsSinceEpoch;
final previewKey = GlobalKey();

Future<void> openApp(
  WidgetTester tester, {
  List<Map<String, Object>>? notes,
}) async {
  SharedPreferences.setMockInitialValues({
    NotesRepository.storageKey: jsonEncode(
      notes ??
          [
            {'id': sampleId, 'text': sampleText},
          ],
    ),
  });
  final repository = await NotesRepository.open();
  await tester.pumpWidget(
    RepaintBoundary(
      key: previewKey,
      child: NotesApp(repository: repository),
    ),
  );
  await tester.pumpAndSettle();
}

// Снимки можно обновить вручную: flutter test --dart-define=UI_PREVIEWS=true
Future<void> preview(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('UI_PREVIEWS')) return;
  await tester.runAsync(() async {
    final boundary =
        previewKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('build/ui-preview/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(() async {
    if (const bool.fromEnvironment('UI_PREVIEWS')) {
      final configFile = File('.dart_tool/package_config.json');
      final config =
          jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
      final flutter = (config['packages'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .firstWhere((package) => package['name'] == 'flutter');
      final flutterRoot = configFile.absolute.uri.resolve(
        '${flutter['rootUri']}/',
      );
      final font = File.fromUri(
        flutterRoot.resolve(
          '../../bin/cache/artifacts/material_fonts/roboto-regular.ttf',
        ),
      );
      final loader = FontLoader('Roboto')
        ..addFont(Future.value(ByteData.sublistView(await font.readAsBytes())));
      await loader.load();
      final icons = File.fromUri(
        flutterRoot.resolve(
          '../../bin/cache/artifacts/material_fonts/materialicons-regular.otf',
        ),
      );
      await (FontLoader('MaterialIcons')..addFont(
            Future.value(ByteData.sublistView(await icons.readAsBytes())),
          ))
          .load();
    }
  });

  testWidgets('Сохранённые заметки видны, нажатие открывает полный текст', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final longText = List.filled(12, sampleText).join('\n\n');
    await openApp(
      tester,
      notes: [
        {'id': sampleId, 'text': longText},
      ],
    );
    expect(find.byType(NoteCard), findsOneWidget);
    final cardText = tester.widget<Text>(find.text(longText));
    expect(cardText.maxLines, 4);
    await preview(tester, 'dark');
    await tester.tap(find.byTooltip('Включить светлую тему'));
    await tester.pumpAndSettle();
    await preview(tester, 'light');
    await tester.ensureVisible(find.text(longText));
    await tester.pumpAndSettle();
    await tester.tap(find.text(longText));
    await tester.pumpAndSettle();
    expect(find.byType(NoteDetailScreen), findsOneWidget);
    expect(tester.widget<Text>(find.text(longText)).maxLines, isNull);
    expect(find.byType(SelectionArea), findsOneWidget);
    await preview(tester, 'reader');
    await tester.tap(find.text('Редактировать'));
    await tester.pumpAndSettle();
    expect(find.byType(NoteDetailScreen), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      longText,
    );
    await tester.enterText(find.byType(TextField), 'Обновлённая заметка');
    await tester.ensureVisible(find.text('Сохранить'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.text('Обновлённая заметка'), findsOneWidget);
    expect(find.text('1 заметка'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Создание, подтверждение удаления и возврат в пустое состояние', (
    tester,
  ) async {
    await openApp(tester, notes: []);
    expect(find.text('Пока нет заметок'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Новая запись');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(NoteCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Действия с заметкой'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle();
    expect(find.text('Удалить заметку?'), findsOneWidget);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(find.text('Новая запись'), findsOneWidget);
    await tester.tap(find.byTooltip('Действия с заметкой'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle();
    expect(find.byType(NoteCard), findsNothing);
    expect(find.text('Пока нет заметок'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Маленький экран, клавиатура и крупный текст не вызывают переполнения',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openApp(tester, notes: []);
      await tester.enterText(
        find.byType(TextField),
        'Текст\nв несколько\nстрок',
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Сохранить'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();
      expect(find.text('1 заметка'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Просмотр другой заметки не стирает несохранённый черновик', (
    tester,
  ) async {
    await openApp(tester);
    await tester.enterText(find.byType(TextField), 'Несохранённый черновик');
    await tester.ensureVisible(find.text(sampleText));
    await tester.pumpAndSettle();
    await tester.tap(find.text(sampleText));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Редактировать'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Несохранённый черновик',
    );
    expect(
      find.text('Сначала сохраните или очистите текущий текст'),
      findsOneWidget,
    );
  });
}
