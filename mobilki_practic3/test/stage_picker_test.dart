import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rally_stage_analyzer/main.dart';
import 'package:rally_stage_analyzer/models/rally_stage.dart';
import 'package:rally_stage_analyzer/widgets/weather_widgets.dart';

void main() {
  testWidgets(
    'Меню ограничено полем и высотой, длинный список прокручивается',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final stages = List.generate(
        20,
        (i) => RallyStage(
          id: '$i',
          name: 'Спецучасток $i с длинным названием лесной дороги',
          latitude: 55,
          longitude: 37,
        ),
      );
      String? selected;
      await tester.pumpWidget(
        MaterialApp(
          theme: rallyTheme(),
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    StagePicker(
                      stages: stages,
                      value: null,
                      exclude: '0',
                      onChanged: (v) => selected = v,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      final field = tester.getRect(find.byType(StagePicker));
      await tester.tap(find.byType(StagePicker));
      await tester.pumpAndSettle();
      final menu = find.byWidgetPredicate(
        (w) =>
            w is Material &&
            w.shape is RoundedRectangleBorder &&
            (w.shape as RoundedRectangleBorder).side.color ==
                const Color(0xff454b57),
      );
      expect(menu, findsOneWidget);
      final rect = tester.getRect(menu);
      expect(rect.width, closeTo(field.width, 1));
      expect(rect.height, lessThanOrEqualTo(320));
      expect(rect.left, greaterThanOrEqualTo(16));
      expect(rect.right, lessThanOrEqualTo(344));
      expect(find.text(stages.first.name), findsNothing);
      final last = find.text(stages.last.name);
      await tester.scrollUntilVisible(
        last,
        160,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(last);
      await tester.pumpAndSettle();
      expect(selected, '19');
      expect(tester.takeException(), isNull);
    },
  );
}
