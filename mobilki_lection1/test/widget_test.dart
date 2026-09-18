import 'package:flutter_test/flutter_test.dart';

import 'package:mobilki_lection1/main.dart';

void main() {
  testWidgets('Home shows all four layouts', (WidgetTester tester) async {
    await tester.pumpWidget(const MeditownApp());

    expect(find.text('Meditate'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('3D Design Basic'), findsOneWidget);
    expect(find.text('My E-Wallet'), findsOneWidget);
  });
}