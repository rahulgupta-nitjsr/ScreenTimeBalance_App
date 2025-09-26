import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zen_screen/utils/theme.dart';
import 'package:zen_screen/widgets/zen_input_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ZenInputField displays label and accepts input', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: ZenInputField(
              label: 'Minutes',
              hint: '15',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Minutes'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '25');
    expect(find.text('25'), findsOneWidget);
  });
}

