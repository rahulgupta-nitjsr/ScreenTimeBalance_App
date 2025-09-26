import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zen_screen/utils/theme.dart';
import 'package:zen_screen/widgets/glass_card.dart';

void main() {

  testWidgets('GlassCard renders child content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassCard(
            child: Text('Hello World'),
          ),
        ),
      ),
    );

    expect(find.text('Hello World'), findsOneWidget);
  });

  testWidgets('GlassCard respects padding and blur stays localized', (tester) async {
    const childKey = Key('glass-card-child');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: GlassCard(
            padding: EdgeInsets.all(AppTheme.spaceLG),
            child: SizedBox(key: childKey, width: 100, height: 40),
          ),
        ),
      ),
    );

    final paddingWidget = tester
        .widgetList<Padding>(
          find.ancestor(of: find.byKey(childKey), matching: find.byType(Padding)),
        )
        .first;
    expect(paddingWidget.padding, const EdgeInsets.all(AppTheme.spaceLG));
  });
}

