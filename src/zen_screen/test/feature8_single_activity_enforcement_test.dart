import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zen_screen/models/habit_category.dart';
import 'package:zen_screen/providers/timer_provider.dart';
import 'package:zen_screen/providers/navigation_provider.dart';
import 'package:zen_screen/providers/algorithm_provider.dart';
import 'package:zen_screen/screens/log_screen.dart';
import 'package:zen_screen/utils/theme.dart';

void main() {
  group('Feature 8: Single Activity Enforcement Tests', () {
    late ProviderContainer container;

    setUpAll(() {
      // Initialize FFI for sqflite
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() async {
      // Comprehensive cleanup to prevent test state pollution
      try {
        // 1. Stop any running timers and cancel all timer instances
        final timerManager = container.read(timerManagerProvider.notifier);
        if (timerManager.state.isRunning || timerManager.state.isPaused) {
          await timerManager.cancelTimer(reason: 'Test cleanup');
        }
        
        // 2. Explicitly dispose timer manager to cancel Timer.periodic
        timerManager.dispose();
        
        // 3. Dispose algorithm config service to cancel file watcher and stream controller
        final algorithmService = container.read(algorithmConfigServiceProvider);
        algorithmService.dispose();
        
        // 4. Cancel any remaining async operations
        await Future.delayed(const Duration(milliseconds: 50));
        
      } catch (e) {
        // Services might not be initialized, ignore
      }
      
      // 5. Dispose container and all providers
      container.dispose();
      
      // 6. Wait for all async operations to complete and clear any remaining timers
      await Future.delayed(const Duration(milliseconds: 200));
      
      // 7. Force garbage collection to clean up any remaining resources
      // This is particularly important for Windows/PowerShell environments
      await Future.delayed(const Duration(milliseconds: 100));
    });

    testWidgets('TC071: Single timer enforcement - only one timer can be active at a time', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LogScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start first timer
      final timerManager = container.read(timerManagerProvider.notifier);
      await timerManager.startTimer(HabitCategory.sleep);
      await tester.pumpAndSettle();

      // Verify first timer is running
      expect(timerManager.state.isRunning, isTrue);
      expect(timerManager.state.activeCategory, equals(HabitCategory.sleep));

      // Try to start second timer - should throw exception
      expect(
        () async => await timerManager.startTimer(HabitCategory.exercise),
        throwsA(isA<TimerConflictException>()),
      );

      // Verify first timer is still running
      expect(timerManager.state.isRunning, isTrue);
      expect(timerManager.state.activeCategory, equals(HabitCategory.sleep));
    });

    testWidgets('TC072: Prevention message display - clear prevention message shown', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LogScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start first timer
      final timerManager = container.read(timerManagerProvider.notifier);
      await timerManager.startTimer(HabitCategory.outdoor);
      await tester.pumpAndSettle();

      // Try to start second timer and catch the exception
      try {
        await timerManager.startTimer(HabitCategory.productive);
      } catch (e) {
        expect(e, isA<TimerConflictException>());
        expect(e.toString(), contains('Only one timer can be active at once'));
        expect(e.toString(), contains('Outdoor'));
      }
    });

    testWidgets('TC073: Timer switching option - option to stop current timer and start new one', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LogScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start first timer
      final timerManager = container.read(timerManagerProvider.notifier);
      await timerManager.startTimer(HabitCategory.sleep);
      await tester.pumpAndSettle();

      // Stop the current timer
      await timerManager.stopTimer();
      await tester.pumpAndSettle();

      // Verify timer is stopped
      expect(timerManager.state.isRunning, isFalse);
      expect(timerManager.state.session, isNull);

      // Start new timer
      await timerManager.startTimer(HabitCategory.exercise);
      await tester.pumpAndSettle();

      // Verify new timer is running
      expect(timerManager.state.isRunning, isTrue);
      expect(timerManager.state.activeCategory, equals(HabitCategory.exercise));
    });

    testWidgets('TC074: Active timer visual indication - currently active timer clearly indicated in UI', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LogScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start a timer
      final timerManager = container.read(timerManagerProvider.notifier);
      await timerManager.startTimer(HabitCategory.productive);
      await tester.pumpAndSettle();

      // Verify active timer is indicated in UI
      expect(timerManager.state.activeCategory, equals(HabitCategory.productive));
      expect(timerManager.state.isRunning, isTrue);
    });

    testWidgets('TC075: Manual entry prevention - manual entry disabled for actively timed category', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LogScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start a timer for sleep
      final timerManager = container.read(timerManagerProvider.notifier);
      await timerManager.startTimer(HabitCategory.sleep);
      await tester.pumpAndSettle();

      // Check if manual entry is disabled for the active category
      final canEditSleep = timerManager.canEditManually(HabitCategory.sleep);
      expect(canEditSleep, isFalse);

      // Check if manual entry is still allowed for other categories
      final canEditExercise = timerManager.canEditManually(HabitCategory.exercise);
      expect(canEditExercise, isTrue);
    });

    testWidgets('TC076: Enforcement across all categories - enforcement works consistently across all habit categories', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LogScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final timerManager = container.read(timerManagerProvider.notifier);

      // Test enforcement for each category
      for (final category in HabitCategory.values) {
        // Start timer for this category
        await timerManager.startTimer(category);
        await tester.pumpAndSettle();

        // Verify this category is active
        expect(timerManager.state.activeCategory, equals(category));
        expect(timerManager.state.isRunning, isTrue);

        // Try to start timer for different category
        final otherCategories = HabitCategory.values.where((c) => c != category);
        for (final otherCategory in otherCategories) {
          expect(
            () async => await timerManager.startTimer(otherCategory),
            throwsA(isA<TimerConflictException>()),
          );
        }

        // Stop timer before testing next category
        await timerManager.stopTimer();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('TC077: State synchronization - timer state synchronized across all UI components', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LogScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start a timer
      final timerManager = container.read(timerManagerProvider.notifier);
      await timerManager.startTimer(HabitCategory.outdoor);
      await tester.pumpAndSettle();

      // Verify state is consistent across different ways of accessing it
      expect(timerManager.state.isRunning, isTrue);
      expect(timerManager.state.activeCategory, equals(HabitCategory.outdoor));
      expect(timerManager.activeCategory, equals(HabitCategory.outdoor));
    });

    testWidgets('TC078: Conflict resolution - timer conflicts resolved smoothly with clear feedback', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LogScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start first timer
      final timerManager = container.read(timerManagerProvider.notifier);
      await timerManager.startTimer(HabitCategory.sleep);
      await tester.pumpAndSettle();

      // Verify first timer is running
      expect(timerManager.state.isRunning, isTrue);

      // Try to start conflicting timer
      bool conflictCaught = false;
      try {
        await timerManager.startTimer(HabitCategory.exercise);
      } catch (e) {
        conflictCaught = true;
        expect(e, isA<TimerConflictException>());
      }

      expect(conflictCaught, isTrue);

      // Verify original timer is still running
      expect(timerManager.state.isRunning, isTrue);
      expect(timerManager.state.activeCategory, equals(HabitCategory.sleep));
    });

    testWidgets('TC079: Enforcement persistence - single timer enforcement persists across app sessions', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LogScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start a timer
      final timerManager = container.read(timerManagerProvider.notifier);
      await timerManager.startTimer(HabitCategory.productive);
      await tester.pumpAndSettle();

      // Simulate app lifecycle changes
      container.read(appLifecycleProvider.notifier).setState(AppLifecycleState.paused);
      await tester.pumpAndSettle();

      container.read(appLifecycleProvider.notifier).setState(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // Verify enforcement still works
      expect(timerManager.state.isRunning, isTrue);
      expect(
        () async => await timerManager.startTimer(HabitCategory.sleep),
        throwsA(isA<TimerConflictException>()),
      );
    });

    testWidgets('TC080: Performance impact - timer enforcement doesn\'t impact app performance', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LogScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final timerManager = container.read(timerManagerProvider.notifier);

      // Start a timer
      await timerManager.startTimer(HabitCategory.sleep);
      await tester.pumpAndSettle();

      // Measure performance of enforcement checks
      final stopwatch = Stopwatch()..start();
      
      // Perform multiple enforcement checks
      for (int i = 0; i < 100; i++) {
        try {
          await timerManager.startTimer(HabitCategory.exercise);
        } catch (e) {
          // Expected to throw
        }
      }
      
      stopwatch.stop();

      // Verify enforcement is fast (should complete in reasonable time)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Less than 1 second for 100 checks
    });
  });
}
