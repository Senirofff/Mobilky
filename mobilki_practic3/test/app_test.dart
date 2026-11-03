import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rally_stage_analyzer/di.dart';
import 'package:rally_stage_analyzer/main.dart';
import 'package:rally_stage_analyzer/services/stage_storage_service.dart';
import 'package:rally_stage_analyzer/models/rally_stage.dart';
import 'package:rally_stage_analyzer/widgets/weather_widgets.dart';
import 'package:rally_stage_analyzer/screens/analysis_screen.dart';
import 'package:rally_stage_analyzer/screens/comparison_screen.dart';
import 'package:rally_stage_analyzer/screens/start_planner_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });
  tearDown(() async => getIt.reset());
  testWidgets('Свайпы синхронизируют вкладки и нижнюю навигацию', (
    tester,
  ) async {
    await tester.pumpWidget(const RallyApp());
    await tester.pumpAndSettle();
    expect(find.text('Погодный штурман'), findsNothing);
    int currentTab() =>
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;
    expect(currentTab(), 0);
    final analysis = tester.widget(
      find.byType(AnalysisScreen, skipOffstage: false),
    );
    final comparison = tester.widget(
      find.byType(ComparisonScreen, skipOffstage: false),
    );
    final planner = tester.widget(
      find.byType(StartPlannerScreen, skipOffstage: false),
    );
    for (var index = 1; index < 4; index++) {
      await tester.drag(find.byType(PageView), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(currentTab(), index);
    }
    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(currentTab(), 3);
    await tester.drag(find.byType(PageView), const Offset(600, 0));
    await tester.pumpAndSettle();
    expect(currentTab(), 2);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Участки'),
      ),
    );
    await tester.pumpAndSettle();
    expect(currentTab(), 0);
    await tester.drag(find.byType(PageView), const Offset(600, 0));
    await tester.pumpAndSettle();
    expect(currentTab(), 0);
    expect(tester.takeException(), isNull);
    expect(
      tester.widget(find.byType(AnalysisScreen, skipOffstage: false)),
      same(analysis),
    );
    expect(
      tester.widget(find.byType(ComparisonScreen, skipOffstage: false)),
      same(comparison),
    );
    expect(
      tester.widget(find.byType(StartPlannerScreen, skipOffstage: false)),
      same(planner),
    );
  });
  testWidgets('Погода, прогноз, сравнение и подбор старта на экране 360 px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await getIt<StageStorageService>().save([
      const RallyStage(id: '1', name: 'Лесной', latitude: 55, longitude: 37),
      const RallyStage(id: '2', name: 'Горный', latitude: 56, longitude: 38),
    ]);
    final now = DateTime.now().toUtc();
    final next = DateTime.utc(now.year, now.month, now.day + 1, 9);
    var calls = 0;
    getIt<Dio>().interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (options, handler) {
          calls++;
          final bad = options.queryParameters['lat'] == 56.0;
          final data = <String, dynamic>{
            'temp': 12,
            'feels_like': 10,
            'wind_speed': 3,
            'wind_degrees': 90,
            'humidity': 60,
            'cloud_pct': 20,
            'weather': bad ? 'Rain' : 'Clear',
          };
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: options.path.endsWith('weatherforecast')
                  ? [
                      {
                        ...data,
                        'timestamp': next.millisecondsSinceEpoch ~/ 1000,
                      },
                      {
                        ...data,
                        'timestamp':
                            next
                                .add(const Duration(hours: 3))
                                .millisecondsSinceEpoch ~/
                            1000,
                      },
                    ]
                  : data,
            ),
          );
        },
      ),
    );
    await tester.pumpWidget(const RallyApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Анализ погоды').first);
    await tester.tap(find.text('Анализ погоды').first);
    await tester.pumpAndSettle();
    expect(find.text('Ясно'), findsWidgets);
    expect(find.text('Низкая · 0 б.'), findsWidgets);
    expect(calls, 2);
    Future<void> navigate(String label) async {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> pick(int index, String value) async {
      await tester.tap(find.byType(StagePicker).at(index));
      await tester.pumpAndSettle();
      await tester.tap(find.text(value).last);
      await tester.pumpAndSettle();
    }

    await navigate('Сравнение');
    await pick(0, 'Лесной');
    await pick(1, 'Горный');
    await tester.tap(find.widgetWithText(FilledButton, 'Сравнить'));
    await tester.pumpAndSettle();
    expect(find.textContaining('На участке «Лесной»'), findsOneWidget);
    expect(calls, 3);
    await navigate('Старт');
    await pick(0, 'Лесной');
    await tester.ensureVisible(find.text('Подобрать время'));
    await tester.tap(find.text('Подобрать время'));
    await tester.pumpAndSettle();
    expect(find.text('09:00 UTC'), findsOneWidget);
    expect(calls, 3);
    await navigate('Анализ');
    expect(calls, 3);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Создание участка, валидация, анализ без ключа, редактирование и удаление',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const RallyApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Добавить участок'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();
      expect(find.text('Укажите название'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(0), 'Лесной');
      await tester.enterText(find.byType(TextFormField).at(1), '91');
      await tester.enterText(find.byType(TextFormField).at(2), '37,62');
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();
      expect(find.text('Введите корректную координату'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(1), '55,75');
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();
      expect(getIt<StageStorageService>().load().single.name, 'Лесной');
      await tester.ensureVisible(find.text('Анализ погоды'));
      await tester.tap(find.text('Анализ погоды'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Не указан API-ключ'), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Участки'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Редактировать'));
      await tester.tap(find.byTooltip('Редактировать'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Горный');
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();
      expect(getIt<StageStorageService>().load().single.name, 'Горный');
      await tester.ensureVisible(find.byTooltip('Удалить'));
      await tester.tap(find.byTooltip('Удалить'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();
      expect(getIt<StageStorageService>().load(), hasLength(1));
      await tester.tap(find.byTooltip('Удалить'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Удалить'));
      await tester.pumpAndSettle();
      expect(getIt<StageStorageService>().load(), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
}
