import 'package:flutter_test/flutter_test.dart';

import 'package:flutqr/main.dart';

void main() {
  testWidgets('Smoke test flutqr app initialization', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlutQrApp());

    // Verify app renders without throwing exceptions
    expect(find.byType(FlutQrApp), findsOneWidget);
  });
}
