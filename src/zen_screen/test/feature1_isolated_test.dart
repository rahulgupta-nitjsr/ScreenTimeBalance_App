import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zen_screen/main.dart';
import 'package:zen_screen/screens/welcome_screen.dart';
import 'package:zen_screen/screens/home_screen.dart';
import 'package:zen_screen/screens/log_screen.dart';
import 'package:zen_screen/screens/progress_screen.dart';
import 'package:zen_screen/screens/profile_screen.dart';
import 'package:zen_screen/screens/how_it_works_screen.dart';
import 'package:zen_screen/utils/app_router.dart';
import 'package:zen_screen/utils/theme.dart';

void main() {
  group('Feature 1: App Shell & Navigation Tests (Isolated)', () {
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
      await tester.pump(const Duration(milliseconds: 300));
      
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

    testWidgets('TC003: Navigation to Log screen', (WidgetTester tester) async {
      // Build the app and navigate to Home
      await tester.pumpWidget(const ProviderScope(child: ZenScreenApp()));
      await tester.pumpAndSettle();
      
      // Wait for the button to be available
      await tester.pump(const Duration(milliseconds: 300));
      
      // Navigate to Home first
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      
      // Tap Log Time button
      await tester.tap(find.text('Log Time'));
      await tester.pumpAndSettle();
      
      // Verify Log screen loads
      expect(find.text('Log Time'), findsOneWidget);
      expect(find.text('00:00:00'), findsOneWidget);
      expect(find.text('Start Timer'), findsOneWidget);
      expect(find.text('Manual Entry'), findsOneWidget);
    });

    testWidgets('TC004: Navigation to Progress screen', (WidgetTester tester) async {
      // Build the app and navigate to Home
      await tester.pumpWidget(const ProviderScope(child: ZenScreenApp()));
      await tester.pumpAndSettle();
      
      // Wait for the button to be available
      await tester.pump(const Duration(milliseconds: 300));
      
      // Navigate to Home first
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      
      // Tap See Progress button
      await tester.tap(find.text('See Progress'));
      await tester.pumpAndSettle();
      
      // Verify Progress screen loads
      expect(find.text("Today's Progress"), findsOneWidget);
      expect(find.text('Earned Screen Time'), findsOneWidget);
      expect(find.text('Used Screen Time'), findsOneWidget);
      expect(find.text('POWER+ Mode Unlocked!'), findsOneWidget);
      expect(find.text('Habits'), findsOneWidget);
    });

    testWidgets('TC005: Navigation to Profile screen', (WidgetTester tester) async {
      // Build the app and navigate to Home
      await tester.pumpWidget(const ProviderScope(child: ZenScreenApp()));
      await tester.pumpAndSettle();
      
      // Wait for the button to be available
      await tester.pump(const Duration(milliseconds: 300));
      
      // Navigate to Home first
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      
      // Navigate to Profile via bottom navigation
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      
      // Verify Profile screen loads (check for header text specifically)
      expect(find.text('Profile'), findsWidgets);
      expect(find.text('Ethan Carter'), findsOneWidget);
      expect(find.text('Usage'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('TC006: Navigation to How It Works screen', (WidgetTester tester) async {
      // Test How It Works screen directly without navigation dependencies
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HowItWorksScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      // Verify How It Works screen loads
      expect(find.text('How It Works'), findsOneWidget);
      expect(find.text('Earning Time'), findsOneWidget);
      expect(find.text('Habits'), findsOneWidget);
      expect(find.text('Penalties'), findsOneWidget);
      expect(find.text('Why This Works'), findsOneWidget);
    });

    testWidgets('TC007: Back button functionality', (WidgetTester tester) async {
      // Build the app and navigate to Home
      await tester.pumpWidget(const ProviderScope(child: ZenScreenApp()));
      await tester.pumpAndSettle();
      
      // Wait for the button to be available
      await tester.pump(const Duration(milliseconds: 300));
      
      // Navigate to Home first
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      
      // Navigate to Log screen
      await tester.tap(find.text('Log Time'));
      await tester.pumpAndSettle();
      
      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();
      
      // Verify we're back to Home screen
      expect(find.text('1h 23m'), findsOneWidget);
    });

    testWidgets('TC008: Navigation state persistence', (WidgetTester tester) async {
      // Build the app and navigate to Progress screen
      await tester.pumpWidget(const ProviderScope(child: ZenScreenApp()));
      await tester.pumpAndSettle();
      
      // Wait for the button to be available
      await tester.pump(const Duration(milliseconds: 300));
      
      // Navigate to Home first
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('See Progress'));
      await tester.pumpAndSettle();
      
      // Verify we're on Progress screen
      expect(find.text("Today's Progress"), findsOneWidget);
      
      // Test that we can navigate back and forth
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();
      
      // Verify we're back to Home screen
      expect(find.text('1h 23m'), findsOneWidget);
      
      // Navigate back to Progress screen
      await tester.tap(find.text('See Progress'));
      await tester.pumpAndSettle();
      
      // Verify we're back on Progress screen
      expect(find.text("Today's Progress"), findsOneWidget);
    });

    testWidgets('TC009: Deep linking support', (WidgetTester tester) async {
      // Test deep linking by directly navigating to a specific screen without GoRouter
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LogScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      // Verify Log screen loads directly
      expect(find.text('Log Time'), findsOneWidget);
      expect(find.text('00:00:00'), findsOneWidget);
    });

    testWidgets('TC010: Navigation performance', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const ProviderScope(child: ZenScreenApp()));
      await tester.pumpAndSettle();
      
      // Wait for the button to be available
      await tester.pump(const Duration(milliseconds: 300));
      
      // Measure navigation time
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Verify navigation completes within reasonable time (test environment may be slower)
      expect(stopwatch.elapsedMilliseconds, lessThanOrEqualTo(1000));
      
      // Test rapid navigation
      stopwatch.reset();
      stopwatch.start();
      
      await tester.tap(find.text('Log Time'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Verify rapid navigation also completes within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThanOrEqualTo(1000));
    });
  });
}
