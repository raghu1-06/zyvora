// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:zyvora/main.dart';

void main() {
  testWidgets('routes to mode selection after onboarding is seen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'zyvora.onboardingSeen': true,
      'zyvora.authCompleted': true,
    });

    await tester.pumpWidget(
      const ProviderScope(child: ZyvoraApp()),
    );
    await _pumpUntilFound(tester, find.text('Welcome to Zyvora'));

    expect(find.text('Welcome to Zyvora'), findsOneWidget);
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Professional'), findsOneWidget);
  });
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 8),
}) async {
  var elapsed = Duration.zero;
  const step = Duration(milliseconds: 100);

  while (elapsed < timeout) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
    elapsed += step;
  }

  await tester.pumpAndSettle();
}
