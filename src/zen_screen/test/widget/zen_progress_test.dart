import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zen_screen/utils/theme.dart';
import 'package:zen_screen/widgets/zen_progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ZenLinearProgressBar shows provided progress', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: ZenLinearProgressBar(
            progress: 0.5,
            showLabel: true,
            label: 'Progress',
          ),
        ),
      ),
    );

    expect(find.text('Progress'), findsOneWidget);
    final indicator = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
    expect(indicator.value, 0.5);
  });

  testWidgets('ZenCircularProgress renders percentage text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: ZenCircularProgress(
            progress: 0.75,
            center: Text('75%'),
          ),
        ),
      ),
    );

    expect(find.text('75%'), findsOneWidget);
  });
}

