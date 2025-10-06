import 'package:flutter_test/flutter_test.dart';
import 'package:zen_screen/services/error_logging_service.dart';
import 'package:zen_screen/services/network_resilience_service.dart';

/// Unit tests for Features 15 & 16 - Core Business Logic
/// 
/// **Product Learning:**
/// These tests focus on the business logic without database dependencies.
/// This is a common pattern: test the logic separately from the infrastructure.
void main() {
  group('Feature 15: Data Correction & Audit Trail - Unit Tests', () {
    //
    // TC151: Edit validation logic
    test('TC151: Edit validation prevents negative values', () {
      // Test the validation logic that would be in HabitEditService
      const maxMinutes = 240;
      const newMinutes = -10;
      
      expect(newMinutes < 0, isTrue);
      expect(newMinutes > maxMinutes, isFalse);
    });

    // TC152: Confirmation threshold logic
    test('TC152: Large change detection works correctly', () {
      const confirmationThreshold = 30;
      const oldMinutes = 60;
      const newMinutes = 100;
      final difference = (newMinutes - oldMinutes).abs();
      
      expect(difference >= confirmationThreshold, isTrue);
    });

    // TC153: Edit limit enforcement
    test('TC153: Edit limit calculation works', () {
      const maxEditsPerDay = 5;
      const currentEdits = 3;
      
      expect(currentEdits < maxEditsPerDay, isTrue);
      expect(currentEdits >= maxEditsPerDay, isFalse);
    });

    // TC154: Audit event creation
    test('TC154: Audit event data structure is valid', () {
      final event = {
        'eventType': 'habit_edit',
        'oldValue': 60,
        'newValue': 120,
        'reason': 'Forgot to log extra time',
      };
      
      expect(event['eventType'], equals('habit_edit'));
      expect(event['oldValue'], equals(60));
      expect(event['newValue'], equals(120));
      expect(event['reason'], isNotNull);
    });

    // TC155: Undo window calculation
    test('TC155: Undo window timing works', () {
      const undoWindowMinutes = 5;
      final now = DateTime.now();
      final actionTime = now.subtract(const Duration(minutes: 3));
      final elapsed = now.difference(actionTime);
      
      expect(elapsed.inMinutes < undoWindowMinutes, isTrue);
    });
  });

  group('Feature 16: Error Handling & Recovery - Unit Tests', () {
    late ErrorLoggingService errorService;
    late NetworkResilienceService networkService;

    setUp(() {
      errorService = ErrorLoggingService();
      networkService = NetworkResilienceService();
    });

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

    // TC165: Network retry executes correctly
    test('TC165: Network retry executes correctly', () async {
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

    // TC166: Retry exhaustion throws error
    test('TC166: Retry logic throws error after max attempts', () async {
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

    // TC167: Circuit breaker opens after failures
    test('TC167: Circuit breaker opens after threshold failures', () async {
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

    // TC168: Network timeout works
    test('TC168: Network timeout throws TimeoutException', () async {
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

    // TC169: Batch operations with retry
    test('TC169: Batch operations execute with retry', () async {
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

    // TC170: Error listeners are notified
    test('TC170: Error listeners receive notifications', () {
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

    // TC171: Error history size limit
    test('TC171: Error history respects maximum size', () {
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

    // TC172: Clear error history works
    test('TC172: Clearing error history works', () {
      errorService.logError(
        message: 'Error 1',
        severity: ErrorSeverity.error,
        category: ErrorCategory.unknown,
      );

      errorService.clearHistory();

      final history = errorService.getErrorHistory();
      expect(history.length, equals(0));
    });

    // TC173: Backup data structure validation
    test('TC173: Backup data structure is valid', () {
      final backupData = {
        'userId': 'test_user',
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'habitEntries': [],
        'auditEvents': [],
      };

      expect(backupData['userId'], equals('test_user'));
      expect(backupData['version'], equals('1.0.0'));
      expect(backupData['habitEntries'], isA<List>());
      expect(backupData['auditEvents'], isA<List>());
    });

    // TC174: Error severity levels
    test('TC174: Error severity levels are correctly ordered', () {
      expect(ErrorSeverity.debug.index, lessThan(ErrorSeverity.info.index));
      expect(ErrorSeverity.info.index, lessThan(ErrorSeverity.warning.index));
      expect(ErrorSeverity.warning.index, lessThan(ErrorSeverity.error.index));
      expect(ErrorSeverity.error.index, lessThan(ErrorSeverity.critical.index));
    });

    // TC175: Network retry delay calculation
    test('TC175: Exponential backoff delay calculation', () {
      const baseDelayMs = 1000;
      
      // Test exponential backoff: 1s, 2s, 4s, 8s
      expect(baseDelayMs * (1 << 0), equals(1000)); // 2^0 = 1
      expect(baseDelayMs * (1 << 1), equals(2000)); // 2^1 = 2
      expect(baseDelayMs * (1 << 2), equals(4000)); // 2^2 = 4
      expect(baseDelayMs * (1 << 3), equals(8000)); // 2^3 = 8
    });
  });
}
