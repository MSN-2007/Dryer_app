import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dryer_app/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Smart Dryer App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartDryerApp());

    // Allow internal async timers and provider initializations to resolve
    await tester.pumpAndSettle();

    // Verify that the top dashboard elements are present on start
    expect(find.text('SMART DRYER'), findsOneWidget);
    expect(find.text('Control Console'), findsOneWidget);
  });
}
