import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zen_screen/main.dart';
import 'package:zen_screen/screens/welcome_screen.dart';
import 'package:zen_screen/screens/home_screen.dart';

void main() {
  group('Isolated Feature 1 Tests', () {
    testWidgets('TC001: App startup navigation - Welcome Screen loads', (WidgetTester tester) async {
      // Build the app with GoRouter
      await tester.pumpWidget(const ProviderScope(child: ZenScreenApp()));
      await tester.pumpAndSettle();
      
      // Verify welcome screen loads
      expect(find.text('Welcome to ZenScreen'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      
      // Verify navigation state
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('TC002: Navigation to Home screen', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const ProviderScope(child: ZenScreenApp()));
      await tester.pumpAndSettle();
      
      // Wait for the button to be available
      await tester.pump(const Duration(milliseconds: 100));
      
      // Find and tap Get Started button
      final getStartedButton = find.text('Get Started');
      expect(getStartedButton, findsOneWidget);
      
      await tester.tap(getStartedButton);
      await tester.pumpAndSettle();
      
      // Verify Home screen loads
      expect(find.text('1h 23m'), findsOneWidget);
      expect(find.text('POWER+ Mode: Active'), findsOneWidget);
      expect(find.text('Log Time'), findsOneWidget);
      expect(find.text('See Progress'), findsOneWidget);
    });
  });
}
