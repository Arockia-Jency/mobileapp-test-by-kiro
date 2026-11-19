// Integration test: happy-path login → dashboard flow.
// Run with: flutter test test/integration_test/happy_path_test.dart
// Requires a connected device or simulator for full integration_test package usage.
// This test uses WidgetTester only and does NOT require the integration_test package,
// making it runnable with flutter test directly.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_test_ai/main.dart' as app;

void main() {
  testWidgets(
    'Happy path: app launch → login with demo credentials → Dashboard visible',
    (tester) async {
      // Pump the full application
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // The app starts on the Login Screen
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);

      // Enter demo credentials
      await tester.enterText(
          find.byKey(const Key('email_field')), 'demo@example.com');
      await tester.enterText(
          find.byKey(const Key('password_field')), 'password123');

      // Tap the login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Dashboard should be visible
      expect(find.byKey(const Key('total_customers_card')), findsOneWidget);
    },
  );
}
