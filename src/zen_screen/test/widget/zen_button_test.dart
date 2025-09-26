import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zen_screen/utils/theme.dart';
import 'package:zen_screen/widgets/zen_button.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Primary ZenButton triggers callback', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ZenButton.primary(
            'Tap me',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tap me'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('Secondary ZenButton renders label and leading/trailing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ZenButton.secondary(
            'Continue',
            onPressed: () {},
            leading: const Icon(Icons.timer),
            trailing: const Icon(Icons.arrow_forward),
          ),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
    expect(find.byIcon(Icons.timer), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
  });
}

