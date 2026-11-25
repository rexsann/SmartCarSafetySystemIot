
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_car_safety_system/main.dart';

void main() {
  testWidgets('Aplikasi Smart Car Safety System berhasil dibuka',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SmartCarSafetyApp());

    expect(find.byType(SmartCarSafetyApp), findsOneWidget);
  });
}
