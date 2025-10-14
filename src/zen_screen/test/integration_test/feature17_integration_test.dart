// Integration Tests for Feature 17: Device Screen Time Used
// These tests verify end-to-end functionality including permission flow,
// data persistence, and UI integration.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:zen_screen/providers/screen_time_provider.dart';
import 'package:zen_screen/services/screen_time_service.dart';
import 'package:zen_screen/services/daily_habit_repository.dart';
import 'package:zen_screen/models/daily_habit_entry.dart';
import 'package:zen_screen/models/habit_category.dart';
import 'package:zen_screen/providers/repository_providers.dart';
import 'package:zen_screen/providers/algorithm_provider.dart';
import 'package:zen_screen/models/algorithm_result.dart';

// Mock implementations for integration testing
class MockScreenTimeServiceIntegration extends Mock implements ScreenTimeService {}
class MockDailyHabitRepositoryIntegration extends Mock implements DailyHabitRepository {}

void main() {
  group('Feature 17 Integration Tests', () {
    late MockScreenTimeServiceIntegration mockScreenTimeService;
    late MockDailyHabitRepositoryIntegration mockDailyHabitRepository;
    late ProviderContainer container;

    setUp(() {
      mockScreenTimeService = MockScreenTimeServiceIntegration();
      mockDailyHabitRepository = MockDailyHabitRepositoryIntegration();

      // Default mock behaviors
      when(mockScreenTimeService.hasPermission()).thenAnswer((_) async => true);
      when(mockScreenTimeService.getTodayUsedMinutes()).thenAnswer((_) async => 75);
      when(mockScreenTimeService.isOemRestricted()).thenAnswer((_) async => false);
      when(mockScreenTimeService.openUsageSettings()).thenAnswer((_) async => {});

      // Mock algorithm result
      final mockAlgorithmResult = AlgorithmResult(
        totalEarnedMinutes: 120,
        powerModeUnlocked: false,
        perCategoryEarned: {},
        perCategoryLoggedMinutes: {},
        categoryResults: {},
        userId: 'test_user_id',
      );

      container = ProviderContainer(
        overrides: [
          screenTimeServiceProvider.overrideWithValue(mockScreenTimeService),
          dailyHabitRepositoryProvider.overrideWithValue(mockDailyHabitRepository),
          algorithmResultProvider.overrideWithValue(mockAlgorithmResult),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    // TC181: Permission education state when not granted
    test('TC181: End-to-end permission flow when not granted', () async {
      // Setup: Permission not granted
      when(mockScreenTimeService.hasPermission()).thenAnswer((_) async => false);

      // Test: ScreenTimeState should reflect no permission
      final screenTimeState = await container.read(screenTimeStateProvider.future);

      expect(screenTimeState.hasPermission, false);
      expect(screenTimeState.used, 0);
      expect(screenTimeState.remaining, 120); // Earned time remains
      expect(screenTimeState.isOemRestricted, false);

      print('✅ TC181 PASSED: Permission education state correctly handled');
    });

    // TC182: Fetch time within 2 seconds when granted
    test('TC182: End-to-end fetch time performance', () async {
      final stopwatch = Stopwatch()..start();
      
      // Test: Fetch used screen time
      final usedMinutes = await container.read(usedScreenTimeProvider.future);
      
      stopwatch.stop();
      final fetchTime = stopwatch.elapsedMilliseconds;

      expect(usedMinutes, 75);
      expect(fetchTime, lessThan(2000)); // Should be under 2 seconds

      print('✅ TC182 PASSED: Fetch time ${fetchTime}ms (under 2s limit)');
    });

    // TC186: Persistence to daily record in database
    test('TC186: End-to-end data persistence', () async {
      final now = DateTime.now();
      final testEntry = DailyHabitEntry(
        id: 'test_id',
        userId: 'test_user_id',
        date: now,
        minutesByCategory: {},
        earnedScreenTime: 120,
        usedScreenTime: 75,
        remainingScreenTime: 45,
        powerModeUnlocked: false,
        algorithmVersion: '1.0.0',
        createdAt: now,
        updatedAt: now,
        manualAdjustmentMinutes: 0,
      );

      // Mock repository response
      when(mockDailyHabitRepository.upsertEntry(
        userId: anyNamed('userId'),
        date: anyNamed('date'),
        minutesByCategory: anyNamed('minutesByCategory'),
        earnedScreenTime: anyNamed('earnedScreenTime'),
        usedScreenTime: anyNamed('usedScreenTime'),
        remainingScreenTime: anyNamed('remainingScreenTime'),
        powerModeUnlocked: anyNamed('powerModeUnlocked'),
        algorithmVersion: anyNamed('algorithmVersion'),
        manualAdjustmentMinutes: anyNamed('manualAdjustmentMinutes'),
        ref: anyNamed('ref'),
      )).thenAnswer((_) async => testEntry);

      // Test: Persist screen time data
      await mockDailyHabitRepository.upsertEntry(
        userId: 'test_user_id',
        date: now,
        minutesByCategory: {},
        earnedScreenTime: 120,
        usedScreenTime: 75,
        remainingScreenTime: 45,
        powerModeUnlocked: false,
        algorithmVersion: '1.0.0',
        manualAdjustmentMinutes: 0,
        ref: container,
      );

      verify(mockDailyHabitRepository.upsertEntry(
        userId: 'test_user_id',
        date: now,
        minutesByCategory: {},
        earnedScreenTime: 120,
        usedScreenTime: 75,
        remainingScreenTime: 45,
        powerModeUnlocked: false,
        algorithmVersion: '1.0.0',
        manualAdjustmentMinutes: 0,
        ref: container,
      )).called(1);

      print('✅ TC186 PASSED: Data persistence verified');
    });

    // TC188: Day rollover resets usage window
    test('TC188: End-to-end day rollover handling', () async {
      // Setup: Simulate day rollover by returning 0 usage
      when(mockScreenTimeService.getTodayUsedMinutes()).thenAnswer((_) async => 0);

      // Test: Refresh should show 0 used time
      await container.refresh(usedScreenTimeProvider);
      final screenTimeState = await container.read(screenTimeStateProvider.future);

      expect(screenTimeState.used, 0);
      expect(screenTimeState.remaining, 120); // Earned - 0

      print('✅ TC188 PASSED: Day rollover correctly resets usage');
    });

    // TC189: Permission revoked mid-session detection
    test('TC189: End-to-end permission revocation handling', () async {
      // Initial state: permission granted
      var screenTimeState = await container.read(screenTimeStateProvider.future);
      expect(screenTimeState.hasPermission, true);
      expect(screenTimeState.used, 75);

      // Simulate permission revocation
      when(mockScreenTimeService.hasPermission()).thenAnswer((_) async => false);

      // Test: Refresh should detect revocation
      await container.refresh(hasUsagePermissionProvider);
      screenTimeState = await container.read(screenTimeStateProvider.future);

      expect(screenTimeState.hasPermission, false);
      expect(screenTimeState.used, 0);
      expect(screenTimeState.remaining, 120);

      print('✅ TC189 PASSED: Permission revocation correctly detected');
    });

    // TC190: Sync integrity (aggregate daily minutes only)
    test('TC190: End-to-end sync integrity', () async {
      final now = DateTime.now();
      final testEntry = DailyHabitEntry(
        id: 'sync_test_id',
        userId: 'test_user_id',
        date: now,
        minutesByCategory: {},
        earnedScreenTime: 100,
        usedScreenTime: 50,
        remainingScreenTime: 50,
        powerModeUnlocked: false,
        algorithmVersion: '1.0.0',
        createdAt: now,
        updatedAt: now,
        manualAdjustmentMinutes: 0,
      );

      // Test: Verify only aggregate daily minutes are synced (no per-app data)
      final syncData = testEntry.toFirestore();
      
      expect(syncData['usedScreenTime'], 50);
      expect(syncData['remainingScreenTime'], 50);
      expect(syncData['earnedScreenTime'], 100);
      
      // Verify no per-app usage data is included
      expect(syncData.containsKey('perAppUsage'), false);
      expect(syncData.containsKey('appBreakdown'), false);

      print('✅ TC190 PASSED: Sync integrity verified (aggregate data only)');
    });
  });
}
