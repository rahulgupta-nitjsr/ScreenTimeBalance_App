import 'package:flutter_test/flutter_test.dart';
import 'package:zen_screen/models/daily_habit_entry.dart';
import 'package:zen_screen/models/audit_event.dart';
import 'package:zen_screen/models/habit_category.dart';
import 'package:zen_screen/services/habit_edit_service.dart';
import 'package:zen_screen/services/undo_service.dart';
import 'package:zen_screen/services/error_logging_service.dart';
import 'package:zen_screen/services/backup_recovery_service.dart';
import 'package:zen_screen/services/network_resilience_service.dart';
import 'package:zen_screen/services/daily_habit_repository.dart';
import 'package:zen_screen/services/audit_repository.dart';
import 'package:zen_screen/services/algorithm_service.dart';
import 'package:zen_screen/services/algorithm_config_service.dart';
import 'package:zen_screen/services/platform_database_service.dart';

/// Comprehensive test suite for Iteration 8: Features 15 & 16
/// 
/// **Product Learning:**
/// This test suite validates both features end-to-end:
/// - Feature 15: Data Correction & Audit Trail
/// - Feature 16: Error Handling & Recovery
/// 
/// Total test cases: 25 (exceeds minimum requirement of 20)
void main() {
  late DailyHabitRepository habitRepository;
  late AuditRepository auditRepository;
  late AlgorithmService algorithmService;
  late HabitEditService editService;
  late UndoService undoService;
  late ErrorLoggingService errorService;
  late BackupRecoveryService backupService;
  late NetworkResilienceService networkService;

  setUp(() async {
    // Initialize database for testing
    await PlatformDatabaseService.instance.initializeForTesting();

    // Initialize repositories
    habitRepository = DailyHabitRepository();
    auditRepository = AuditRepository();

    final configService = AlgorithmConfigService();
    final config = await configService.loadConfig();
    algorithmService = AlgorithmService(config: config);

    editService = HabitEditService(
      habitRepository: habitRepository,
      auditRepository: auditRepository,
      algorithmService: algorithmService,
    );

    undoService = UndoService(
      habitRepository: habitRepository,
      auditRepository: auditRepository,
      algorithmService: algorithmService,
    );

    errorService = ErrorLoggingService();

    backupService = BackupRecoveryService(
      habitRepository: habitRepository,
      auditRepository: auditRepository,
    );

    networkService = NetworkResilienceService();
  });

  group('Feature 15: Data Correction & Audit Trail', () {
    //
    // TC151: Can edit today's habit entry
    test('TC151: Successfully edit today\'s habit entry', () async {
      final userId = 'test_user_151';
      final today = DateTime.now();

      // Create initial entry
      await habitRepository.upsertEntry(
        userId: userId,
        date: today,
        minutesByCategory: {
          HabitCategory.sleep: 60,
          HabitCategory.exercise: 30,
          HabitCategory.outdoor: 20,
          HabitCategory.productive: 40,
        },
        earnedScreenTime: 150,
        usedScreenTime: 0,
        powerModeUnlocked: false,
        algorithmVersion: '1.0.0',
      );

      // Edit the entry
      final result = await editService.editHabitEntry(
        userId: userId,
        entryDate: today,
        category: HabitCategory.sleep,
        newMinutes: 120,
        confirmed: true,
      );

      expect(result.success, isTrue);
      expect(result.updatedEntry, isNotNull);
      expect(result.updatedEntry!.minutesByCategory[HabitCategory.sleep], equals(120));
    });

    // TC152: Cannot edit yesterday's entry
    test('TC152: Cannot edit past entries (yesterday)', () async {
      final userId = 'test_user_152';
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      await habitRepository.upsertEntry(
        userId: userId,
        date: yesterday,
        minutesByCategory: {HabitCategory.sleep: 60},
        earnedScreenTime: 30,
        usedScreenTime: 0,
        powerModeUnlocked: false,
        algorithmVersion: '1.0.0',
      );

      final result = await editService.editHabitEntry(
        userId: userId,
        entryDate: yesterday,
        category: HabitCategory.sleep,
        newMinutes: 120,
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('today'));
    });

    // TC153: Large change requires confirmation
    test('TC153: Large change (>30 min) requires confirmation', () async {
      final userId = 'test_user_153';
      final today = DateTime.now();

      await habitRepository.upsertEntry(
        userId: userId,
        date: today,
        minutesByCategory: {HabitCategory.exercise: 30},
        earnedScreenTime: 15,
        usedScreenTime: 0,
        powerModeUnlocked: false,
        algorithmVersion: '1.0.0',
      );

      // Try to change by 40 minutes without confirmation
      final result = await editService.editHabitEntry(
        userId: userId,
        entryDate: today,
        category: HabitCategory.exercise,
        newMinutes: 70,
        confirmed: false,
      );

      expect(result.success, isFalse);
      expect(result.requiresConfirmation, isTrue);
      expect(result.changeSummary, isNotNull);
    });

    // TC154: Edit creates audit trail entry
    test('TC154: Edit creates audit trail entry', () async {
      final userId = 'test_user_154';
      final today = DateTime.now();

      await habitRepository.upsertEntry(
        userId: userId,
        date: today,
        minutesByCategory: {HabitCategory.outdoor: 40},
        earnedScreenTime: 20,
        usedScreenTime: 0,
        powerModeUnlocked: false,
        algorithmVersion: '1.0.0',
      );

      await editService.editHabitEntry(
        userId: userId,
        entryDate: today,
        category: HabitCategory.outdoor,
        newMinutes: 60,
        confirmed: true,
        reason: 'Forgot to log extra 20 minutes',
      );

      final auditEvents = await auditRepository.getAllEvents(userId: userId);
      expect(auditEvents.length, greaterThan(0));
      
      final editEvent = auditEvents.firstWhere(
        (e) => e.eventType == 'habit_edit',
      );
      expect(editEvent.oldValue, equals(40));
      expect(editEvent.newValue, equals(60));
      expect(editEvent.reason, equals('Forgot to log extra 20 minutes'));
    });

    // TC155: Max edit limit is enforced
    test('TC155: Maximum edit limit (5) per day is enforced', () async {
      final userId = 'test_user_155';
      final today = DateTime.now();

      await habitRepository.upsertEntry(
        userId: userId,
        date: today,
        minutesByCategory: {HabitCategory.sleep: 60},
        earnedScreenTime: 30,
        usedScreenTime: 0,
        remainingScreenTime: 30,
        powerModeUnlocked: false,
        algorithmVersion: '1.0.0',
      );

      // Make 5 successful edits
      for (int i = 0; i < 5; i++) {
        final result = await editService.editHabitEntry(
          userId: userId,
          entryDate: today,
          category: HabitCategory.sleep,
          newMinutes: 60 + i + 1,
          confirmed: true,
        );
        expect(result.success, isTrue);
      }

      // 6th edit should fail
      final result = await editService.editHabitEntry(
        userId: userId,
        entryDate: today,
        category: HabitCategory.sleep,
        newMinutes: 100,
        confirmed: true,
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Maximum edits'));
    });

    // TC156: Algorithm recalculates after edit
    test('TC156: Earned time recalculates after edit', () async {
      final userId = 'test_user_156';
      final today = DateTime.now();

      // Initial entry
      final initialEntry = await habitRepository.upsertEntry(
        userId: userId,
        date: today,
        minutesByCategory: {
          HabitCategory.sleep: 60,
          HabitCategory.exercise: 0,
        },
        earnedScreenTime: 30,
        usedScreenTime: 0,
        powerModeUnlocked: false,
        algorithmVersion: '1.0.0',
      );

      // Edit to add exercise
      final result = await editService.editHabitEntry(
        userId: userId,
        entryDate: today,
        category: HabitCategory.exercise,
        newMinutes: 60,
        confirmed: true,
      );

      expect(result.success, isTrue);
      expect(
        result.updatedEntry!.earnedScreenTime,
        greaterThan(initialEntry.earnedScreenTime),
      );
    });

    // TC157: Undo within 5-minute window works
    test('TC157: Undo action within 5-minute window', () async {
      final userId = 'test_user_157';
      final today = DateTime.now();

      // Create entry
      final original = await habitRepository.upsertEntry(
        userId: userId,
        date: today,
        minutesByCategory: {HabitCategory.productive: 40},
        earnedScreenTime: 20,
        usedScreenTime: 0,
        powerModeUnlocked: false,
        algorithmVersion: '1.0.0',
      );

      // Register undo action
      await undoService.registerUndoableAction(
        userId: userId,
        entryDate: today,
        category: HabitCategory.productive,
        oldMinutes: 40,
        newMinutes: 80,
        previousEntry: original,
      );

      expect(undoService.canUndo, isTrue);

      // Perform undo
      final undoResult = await undoService.performUndo();
      expect(undoResult.success, isTrue);
      expect(undoResult.restoredEntry!.minutesByCategory[HabitCategory.productive], equals(40));
    });

    // TC158: Undo creates audit trail entry
    test('TC158: Undo creates audit trail entry', () async {
      final userId = 'test_user_158';
      final today = DateTime.now();

      final original = await habitRepository.upsertEntry(
        userId: userId,
        date: today,
        minutesByCategory: {HabitCategory.sleep: 60},
        earnedScreenTime: 30,
        usedScreenTime: 0,
        powerModeUnlocked: false,
        algorithmVersion: '1.0.0',
      );

      await undoService.registerUndoableAction(
        userId: userId,
        entryDate: today,
        category: HabitCategory.sleep,
        oldMinutes: 60,
        newMinutes: 120,
        previousEntry: original,
      );

      await undoService.performUndo();

      final auditEvents = await auditRepository.getAllEvents(userId: userId);
      final undoEvent = auditEvents.firstWhere(
        (e) => e.eventType == 'habit_undo',
      );

      expect(undoEvent, isNotNull);
      expect(undoEvent.reason, contains('Undo'));
    });

    // TC159: Cannot undo if no action available
    test('TC159: Cannot undo if no action is available', () async {
      expect(undoService.canUndo, isFalse);

      final result = await undoService.performUndo();
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('No action available'));
    });

    // TC160: Audit trail displays correctly
    test('TC160: Audit trail retrieval works correctly', () async {
      final userId = 'test_user_160';
      final today = DateTime.now();

      // Create some audit events
      await auditRepository.logEvent(AuditEvent(
        id: '',
        userId: userId,
        eventType: 'habit_edit',
        targetDate: today,
        category: HabitCategory.sleep.id,
        oldValue: 60,
        newValue: 120,
      ));

      await auditRepository.logEvent(AuditEvent(
        id: '',
        userId: userId,
        eventType: 'habit_edit',
        targetDate: today,
        category: HabitCategory.exercise.id,
        oldValue: 30,
        newValue: 60,
      ));

      final events = await auditRepository.getAllEvents(userId: userId);
      expect(events.length, equals(2));
    });
  });

  group('Feature 16: Error Handling & Recovery', () {
    //
    // TC161: Error logging captures errors
    test('TC161: Error logging service captures errors', () {
      errorService.logError(
        message: 'Test error message',
        code: 'TEST_001',
        severity: ErrorSeverity.error,
        category: ErrorCategory.database,
      );

      final history = errorService.getErrorHistory();
      expect(history.length, equals(1));
      expect(history.first.message, equals('Test error message'));
      expect(history.first.code, equals('TEST_001'));
    });

    // TC162: Error severity filtering works
    test('TC162: Error filtering by severity works', () {
      errorService.logError(
        message: 'Warning 1',
        severity: ErrorSeverity.warning,
        category: ErrorCategory.unknown,
      );

      errorService.logError(
        message: 'Error 1',
        severity: ErrorSeverity.error,
        category: ErrorCategory.unknown,
      );

      errorService.logError(
        message: 'Critical 1',
        severity: ErrorSeverity.critical,
        category: ErrorCategory.unknown,
      );

      final errors = errorService.getErrorHistory(minSeverity: ErrorSeverity.error);
      expect(errors.length, equals(2)); // error + critical
    });

    // TC163: Error category filtering works
    test('TC163: Error filtering by category works', () {
      errorService.logError(
        message: 'Network error',
        severity: ErrorSeverity.error,
        category: ErrorCategory.network,
      );

      errorService.logError(
        message: 'Database error',
        severity: ErrorSeverity.error,
        category: ErrorCategory.database,
      );

      final networkErrors = errorService.getErrorHistory(category: ErrorCategory.network);
      expect(networkErrors.length, equals(1));
      expect(networkErrors.first.message, equals('Network error'));
    });

    // TC164: Error statistics calculation
    test('TC164: Error statistics are calculated correctly', () {
      for (int i = 0; i < 3; i++) {
        errorService.logError(
          message: 'Error $i',
          severity: ErrorSeverity.error,
          category: ErrorCategory.network,
        );
      }

      for (int i = 0; i < 2; i++) {
        errorService.logError(
          message: 'Critical $i',
          severity: ErrorSeverity.critical,
          category: ErrorCategory.database,
        );
      }

      final stats = errorService.getStatistics();
      expect(stats.totalErrors, equals(5));
      expect(stats.criticalErrors, equals(2));
      expect(stats.errorsByCategory[ErrorCategory.network], equals(3));
      expect(stats.errorsByCategory[ErrorCategory.database], equals(2));
    });

    // TC165: Backup creation works
    test('TC165: Database backup creation succeeds', () async {
      final userId = 'test_user_165';
      final today = DateTime.now();

      // Create some data
      await habitRepository.upsertEntry(
        userId: userId,
        date: today,
        minutesByCategory: {HabitCategory.sleep: 60},
        earnedScreenTime: 30,
        usedScreenTime: 0,
        powerModeUnlocked: false,
        algorithmVersion: '1.0.0',
      );

      final backupResult = await backupService.createBackup(
        userId: userId,
        reason: 'Test backup',
      );

      expect(backupResult.success, isTrue);
      expect(backupResult.backup, isNotNull);
      expect(backupResult.backup!.habitEntries.length, greaterThan(0));
    });

    // TC166: Backup verification works
    test('TC166: Backup verification detects valid backups', () async {
      final userId = 'test_user_166';

      final backupData = BackupData(
        userId: userId,
        timestamp: DateTime.now(),
        version: '1.0.0',
        habitEntries: [],
        auditEvents: [],
      );

      final verification = await backupService.verifyBackup(backupData);
      expect(verification.isValid, isTrue);
    });

    // TC167: Recovery from backup works
    test('TC167: Data recovery from backup succeeds', () async {
      final userId = 'test_user_167';
      final today = DateTime.now();

      // Create and backup data
      await habitRepository.upsertEntry(
        userId: userId,
        date: today,
        minutesByCategory: {HabitCategory.exercise: 45},
        earnedScreenTime: 22,
        usedScreenTime: 0,
        powerModeUnlocked: false,
        algorithmVersion: '1.0.0',
      );

      final backupResult = await backupService.createBackup(userId: userId);
      expect(backupResult.success, isTrue);

      // Delete the data
      final entry = await habitRepository.getEntry(userId: userId, date: today);
      await habitRepository.deleteEntry(id: entry!.id);

      // Restore from backup
      final recoveryResult = await backupService.restoreFromBackup(
        backup: backupResult.backup!,
        overwriteExisting: true,
      );

      expect(recoveryResult.success, isTrue);
      expect(recoveryResult.habitEntriesRestored, greaterThan(0));

      // Verify data is restored
      final restored = await habitRepository.getEntry(userId: userId, date: today);
      expect(restored, isNotNull);
    });

    // TC168: Network retry logic works
    test('TC168: Network retry executes correctly', () async {
      int attemptCount = 0;

      final result = await networkService.executeWithRetry(
        operation: () async {
          attemptCount++;
          if (attemptCount < 2) {
            throw Exception('Network error');
          }
          return 'Success';
        },
        maxAttempts: 3,
      );

      expect(result, equals('Success'));
      expect(attemptCount, equals(2)); // Failed once, succeeded on second try
    });

    // TC169: Retry exhaustion throws error
    test('TC169: Retry logic throws error after max attempts', () async {
      expect(
        () => networkService.executeWithRetry(
          operation: () async {
            throw Exception('Persistent error');
          },
          maxAttempts: 3,
        ),
        throwsException,
      );
    });

    // TC170: Circuit breaker opens after failures
    test('TC170: Circuit breaker opens after threshold failures', () async {
      final circuitBreaker = networkService.createCircuitBreaker(
        name: 'test_circuit',
        failureThreshold: 3,
      );

      // Cause 3 failures
      for (int i = 0; i < 3; i++) {
        try {
          await circuitBreaker.execute(() async {
            throw Exception('Failure $i');
          });
        } catch (_) {
          // Expected
        }
      }

      // Circuit should now be open
      expect(circuitBreaker.status.isOpen, isTrue);

      // Next call should fail immediately
      expect(
        () => circuitBreaker.execute(() async => 'Should not execute'),
        throwsA(isA<CircuitBreakerOpenException>()),
      );
    });

    // TC171: Network timeout works
    test('TC171: Network timeout throws TimeoutException', () async {
      expect(
        () => networkService.executeWithTimeoutAndRetry(
          operation: () async {
            await Future.delayed(const Duration(seconds: 2));
            return 'Done';
          },
          timeout: const Duration(milliseconds: 100),
          maxAttempts: 1,
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    // TC172: Batch operations with retry
    test('TC172: Batch operations execute with retry', () async {
      int successCount = 0;

      final results = await networkService.executeBatchWithRetry(
        operations: [
          () async {
            successCount++;
            return 'Result 1';
          },
          () async {
            successCount++;
            return 'Result 2';
          },
          () async {
            successCount++;
            return 'Result 3';
          },
        ],
        maxAttempts: 2,
      );

      expect(results.length, equals(3));
      expect(successCount, equals(3));
    });

    // TC173: Error listeners are notified
    test('TC173: Error listeners receive notifications', () {
      int listenerCallCount = 0;
      AppError? capturedError;

      errorService.addListener((error) {
        listenerCallCount++;
        capturedError = error;
      });

      errorService.logError(
        message: 'Test notification',
        severity: ErrorSeverity.warning,
        category: ErrorCategory.validation,
      );

      expect(listenerCallCount, equals(1));
      expect(capturedError, isNotNull);
      expect(capturedError!.message, equals('Test notification'));
    });

    // TC174: Error history size limit
    test('TC174: Error history respects maximum size', () {
      // Add more than max errors
      for (int i = 0; i < 150; i++) {
        errorService.logError(
          message: 'Error $i',
          severity: ErrorSeverity.info,
          category: ErrorCategory.unknown,
        );
      }

      final history = errorService.getErrorHistory();
      expect(history.length, lessThanOrEqualTo(ErrorLoggingService.maxErrorHistory));
    });

    // TC175: Clear error history works
    test('TC175: Clearing error history works', () {
      errorService.logError(
        message: 'Error 1',
        severity: ErrorSeverity.error,
        category: ErrorCategory.unknown,
      );

      errorService.clearHistory();

      final history = errorService.getErrorHistory();
      expect(history.length, equals(0));
    });
  });
}

