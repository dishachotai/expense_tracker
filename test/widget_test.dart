import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('App starts with LoginView smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the login title card is present
    expect(find.text('Smart Expense Tracker'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);

    // Verify email field prefix icon or text input existence
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
  });
}
