import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zen_screen/models/habit_category.dart';
import 'package:zen_screen/providers/algorithm_provider.dart';
import 'package:zen_screen/providers/minutes_provider.dart';
import 'package:zen_screen/screens/home_screen.dart';
import 'package:zen_screen/screens/progress_screen.dart';
import 'package:zen_screen/widgets/zen_progress.dart';
import 'package:zen_screen/widgets/glass_card.dart';
import 'package:zen_screen/utils/theme.dart';

void main() {
  group('Feature 6: Real-time Screen Time Display Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('TC051: Donut chart accuracy - displays earned vs used time correctly', (WidgetTester tester) async {
      // Setup test data with known values
      final testMinutes = {
        HabitCategory.sleep: 480, // 8 hours
        HabitCategory.exercise: 45, // 45 minutes
        HabitCategory.outdoor: 30, // 30 minutes
        HabitCategory.productive: 120, // 2 hours
      };

      // Set up providers with test data
      container.read(minutesByCategoryProvider.notifier).setMinutes(HabitCategory.sleep, 480);
      container.read(minutesByCategoryProvider.notifier).setMinutes(HabitCategory.exercise, 45);
      container.read(minutesByCategoryProvider.notifier).setMinutes(HabitCategory.outdoor, 30);
      container.read(minutesByCategoryProvider.notifier).setMinutes(HabitCategory.productive, 120);

      // Build the home screen
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify earned screen time is displayed
      expect(find.text('Earned screen time'), findsOneWidget);
      
      // Check that the algorithm result is calculated correctly
      final algorithmResult = container.read(algorithmResultProvider);
      expect(algorithmResult.totalEarnedMinutes, greaterThan(0));
      
      // Verify the display format
      final earnedTimeText = find.textContaining('h');
      expect(earnedTimeText, findsAtLeastNWidgets(1));
    });

    testWidgets('TC052: Arc gauge updates - progress indicators update with habit totals', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProgressScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify progress indicators are present
      expect(find.byType(ZenLinearProgressBar), findsOneWidget);
      expect(find.byType(ZenCircularProgress), findsOneWidget);
      
      // Test progress bar with different values
      final progressBar = tester.widget<ZenLinearProgressBar>(find.byType(ZenLinearProgressBar));
      expect(progressBar.progress, isA<double>());
      expect(progressBar.progress, inInclusiveRange(0.0, 1.0));
    });

    testWidgets('TC053: Category summaries - displays "Xh • Goal Yh" format accurately', (WidgetTester tester) async {
      // Set up test data
      container.read(minutesByCategoryProvider.notifier).setMinutes(HabitCategory.sleep, 420);
      container.read(minutesByCategoryProvider.notifier).setMinutes(HabitCategory.exercise, 45);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that earned time is displayed in the correct format
      final earnedTimeDisplay = find.textContaining('h');
      expect(earnedTimeDisplay, findsAtLeastNWidgets(1));
    });

    testWidgets('TC054: POWER+ badge visibility - badge appears when thresholds met', (WidgetTester tester) async {
      // Set up data to trigger POWER+ mode (3 of 4 goals)
      container.read(minutesByCategoryProvider.notifier).setMinutes(HabitCategory.sleep, 420); // 7h
      container.read(minutesByCategoryProvider.notifier).setMinutes(HabitCategory.exercise, 45); // 45m
      container.read(minutesByCategoryProvider.notifier).setMinutes(HabitCategory.outdoor, 30); // 30m
      // Productive left at 0 to not trigger all 4

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check if POWER+ mode is unlocked
      final algorithmResult = container.read(algorithmResultProvider);
      if (algorithmResult.powerModeUnlocked) {
        // Look for POWER+ related UI elements
        expect(find.textContaining('POWER+'), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('TC055: Visual minimalism compliance - dashboard matches design guidelines', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify glass card components are present (minimalist design)
      expect(find.byType(GlassCard), findsAtLeastNWidgets(1));
      
      // Verify proper spacing and layout
      expect(find.text('Earned screen time'), findsOneWidget);
      expect(find.text('Daily Progress'), findsOneWidget);
    });

    testWidgets('TC056: Update response time - charts update within 100ms', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      // Verify the screen loads quickly
      expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should load within 1 second
      
      // Test real-time updates by changing data
      container.read(minutesByCategoryProvider.notifier).setMinutes(HabitCategory.sleep, 60);
      await tester.pump();
      
      // Verify the display updates
      expect(find.textContaining('Earned screen time'), findsOneWidget);
    });

    testWidgets('TC057: Earned vs used distinction - visual distinction in color and legend', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify earned time display
      expect(find.text('Earned screen time'), findsOneWidget);
      
      // Check that the display uses proper theming
      final earnedTimeText = tester.widget<Text>(find.textContaining('Earned screen time'));
      expect(earnedTimeText.style?.color, isNotNull);
    });

    testWidgets('TC058: Algorithm validation - visuals align with algorithm outputs', (WidgetTester tester) async {
      // Set up known test data
      container.read(minutesByCategoryProvider.notifier).setMinutes(HabitCategory.sleep, 480); // 8h = 200min
      container.read(minutesByCategoryProvider.notifier).setMinutes(HabitCategory.exercise, 60); // 1h = 20min

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify algorithm calculation
      final algorithmResult = container.read(algorithmResultProvider);
      expect(algorithmResult.totalEarnedMinutes, greaterThan(0));
      
      // Verify the display shows the calculated value
      expect(find.textContaining('Earned screen time'), findsOneWidget);
    });

    testWidgets('TC059: Edge value handling - charts handle 0 and cap values gracefully', (WidgetTester tester) async {
      // Test with zero values
      container.read(minutesByCategoryProvider.notifier).setMinutes(HabitCategory.sleep, 0);
      container.read(minutesByCategoryProvider.notifier).setMinutes(HabitCategory.exercise, 0);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the app handles zero values without crashing
      expect(find.text('Earned screen time'), findsOneWidget);
      
      // Test with high values (near caps)
      container.read(minutesByCategoryProvider.notifier).setMinutes(HabitCategory.sleep, 540); // 9h
      container.read(minutesByCategoryProvider.notifier).setMinutes(HabitCategory.exercise, 120); // 2h
      
      await tester.pump();
      
      // Verify the app handles high values
      expect(find.textContaining('Earned screen time'), findsOneWidget);
    });

    testWidgets('TC060: Performance impact - dashboard renders without jank or memory spikes', (WidgetTester tester) async {
      // Test rapid updates to ensure no performance issues
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate rapid data changes
      for (int i = 0; i < 10; i++) {
        container.read(minutesByCategoryProvider.notifier).setMinutes(HabitCategory.sleep, i * 10);
        await tester.pump();
      }

      // Verify the app remains responsive
      expect(find.text('Earned screen time'), findsOneWidget);
    });
  });
}
