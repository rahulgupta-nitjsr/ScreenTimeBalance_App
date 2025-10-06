import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service for handling network errors with retry logic
/// 
/// **Product Learning:**
/// Networks are unreliable. Mobile connections drop, WiFi fails, servers timeout.
/// Instead of showing errors immediately, smart apps retry with exponential backoff.
/// 
/// **Retry Strategy:**
/// 1. First retry: immediate (might be temporary)
/// 2. Second retry: 1 second delay
/// 3. Third retry: 2 seconds delay
/// 4. Fourth retry: 4 seconds delay
/// This gives the network time to recover without making users wait too long.
class NetworkResilienceService {
  NetworkResilienceService();

  /// Maximum number of retry attempts
  static const int maxRetries = 3;

  /// Base delay for exponential backoff (in milliseconds)
  static const int baseDelayMs = 1000;

  /// Execute an async operation with automatic retry logic
  /// 
  /// **Product Learning:**
  /// This is a "wrapper" pattern. Instead of adding retry logic everywhere,
  /// we wrap our network calls with this function and it handles retries automatically.
  Future<T> executeWithRetry<T>({
    required Future<T> Function() operation,
    int maxAttempts = maxRetries,
    bool exponentialBackoff = true,
    Duration? customDelay,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    dynamic lastError;

    while (attempt < maxAttempts) {
      try {
        if (kDebugMode && attempt > 0) {
          print('🔄 Retry attempt $attempt/$maxAttempts');
        }

        final result = await operation();
        
        if (kDebugMode && attempt > 0) {
          print('✅ Operation succeeded on attempt ${attempt + 1}');
        }

        return result;
      } catch (error) {
        lastError = error;
        attempt++;

        // Check if we should retry this error
        if (shouldRetry != null && !shouldRetry(error)) {
          if (kDebugMode) {
            print('❌ Error is not retryable: $error');
          }
          rethrow;
        }

        // Check if we've exhausted all attempts
        if (attempt >= maxAttempts) {
          if (kDebugMode) {
            print('❌ All retry attempts exhausted');
          }
          rethrow;
        }

        // Calculate delay before next retry
        final delay = customDelay ?? _calculateDelay(attempt, exponentialBackoff);

        if (kDebugMode) {
          print('⏳ Waiting ${delay.inMilliseconds}ms before retry...');
        }

        await Future.delayed(delay);
      }
    }

    throw lastError ?? Exception('Operation failed after $maxAttempts attempts');
  }

  /// Execute with timeout and retry
  /// 
  /// **Product Learning:**
  /// Some operations hang forever. Adding timeouts prevents users from
  /// waiting indefinitely. Combined with retries, this creates resilience.
  Future<T> executeWithTimeoutAndRetry<T>({
    required Future<T> Function() operation,
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = maxRetries,
    bool exponentialBackoff = true,
  }) async {
    return executeWithRetry(
      operation: () async {
        return await operation().timeout(
          timeout,
          onTimeout: () {
            throw TimeoutException(
              'Operation timed out after ${timeout.inSeconds} seconds',
            );
          },
        );
      },
      maxAttempts: maxAttempts,
      exponentialBackoff: exponentialBackoff,
      shouldRetry: (error) => _isRetryableError(error),
    );
  }

  /// Check if an error is retryable
  /// 
  /// **Product Learning:**
  /// Not all errors should be retried:
  /// - Network errors: YES (temporary)
  /// - Authentication errors: NO (won't fix itself)
  /// - Validation errors: NO (wrong data)
  /// - Server errors: MAYBE (depends on status code)
  bool _isRetryableError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network-related errors (retryable)
    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('unreachable')) {
      return true;
    }

    // Server errors (some are retryable)
    if (errorString.contains('500') || // Internal Server Error
        errorString.contains('502') || // Bad Gateway
        errorString.contains('503') || // Service Unavailable
        errorString.contains('504')) { // Gateway Timeout
      return true;
    }

    // Client errors (not retryable)
    if (errorString.contains('400') || // Bad Request
        errorString.contains('401') || // Unauthorized
        errorString.contains('403') || // Forbidden
        errorString.contains('404')) { // Not Found
      return false;
    }

    // Default: retry
    return true;
  }

  /// Calculate delay for exponential backoff
  Duration _calculateDelay(int attempt, bool exponential) {
    if (!exponential) {
      return Duration(milliseconds: baseDelayMs);
    }

    // Exponential backoff: 1s, 2s, 4s, 8s, etc.
    final delayMs = baseDelayMs * (1 << (attempt - 1)); // 2^(attempt-1)
    return Duration(milliseconds: delayMs);
  }

  /// Execute a batch of operations with retry
  /// 
  /// **Product Learning:**
  /// Sometimes we need to do multiple network operations. This helper
  /// retries each one independently and collects the results.
  Future<List<T>> executeBatchWithRetry<T>({
    required List<Future<T> Function()> operations,
    int maxAttempts = maxRetries,
    bool continueOnError = false,
  }) async {
    final results = <T>[];
    final errors = <dynamic>[];

    for (int i = 0; i < operations.length; i++) {
      try {
        final result = await executeWithRetry(
          operation: operations[i],
          maxAttempts: maxAttempts,
        );
        results.add(result);
      } catch (error) {
        errors.add(error);
        
        if (!continueOnError) {
          throw BatchOperationException(
            'Batch operation failed at index $i',
            completedOperations: i,
            totalOperations: operations.length,
            errors: errors,
          );
        }
      }
    }

    return results;
  }

  /// Create a circuit breaker to prevent cascading failures
  /// 
  /// **Product Learning:**
  /// Circuit breakers are like electrical breakers. If a service keeps failing,
  /// we "open the circuit" and stop trying for a while. This prevents:
  /// 1. Wasting resources on failing calls
  /// 2. Overwhelming a struggling server
  /// 3. Poor user experience from repeated failures
  CircuitBreaker createCircuitBreaker({
    required String name,
    int failureThreshold = 5,
    Duration resetTimeout = const Duration(minutes: 1),
  }) {
    return CircuitBreaker(
      name: name,
      failureThreshold: failureThreshold,
      resetTimeout: resetTimeout,
    );
  }
}

/// Circuit breaker implementation
class CircuitBreaker {
  CircuitBreaker({
    required this.name,
    required this.failureThreshold,
    required this.resetTimeout,
  });

  final String name;
  final int failureThreshold;
  final Duration resetTimeout;

  int _failureCount = 0;
  DateTime? _lastFailureTime;
  bool _isOpen = false;

  /// Execute an operation through the circuit breaker
  Future<T> execute<T>(Future<T> Function() operation) async {
    // Check if circuit is open
    if (_isOpen) {
      final timeSinceFailure = DateTime.now().difference(_lastFailureTime!);
      
      if (timeSinceFailure < resetTimeout) {
        throw CircuitBreakerOpenException(
          'Circuit breaker "$name" is open. Try again in ${resetTimeout.inSeconds - timeSinceFailure.inSeconds}s',
        );
      } else {
        // Reset circuit breaker
        _reset();
      }
    }

    try {
      final result = await operation();
      _onSuccess();
      return result;
    } catch (error) {
      _onFailure();
      rethrow;
    }
  }

  void _onSuccess() {
    _failureCount = 0;
    _isOpen = false;
    
    if (kDebugMode) {
      print('✅ Circuit breaker "$name": Operation successful');
    }
  }

  void _onFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();

    if (_failureCount >= failureThreshold) {
      _isOpen = true;
      
      if (kDebugMode) {
        print('🚨 Circuit breaker "$name": OPENED after $failureThreshold failures');
      }
    } else {
      if (kDebugMode) {
        print('⚠️ Circuit breaker "$name": Failure $_failureCount/$failureThreshold');
      }
    }
  }

  void _reset() {
    _failureCount = 0;
    _isOpen = false;
    _lastFailureTime = null;
    
    if (kDebugMode) {
      print('🔄 Circuit breaker "$name": Reset');
    }
  }

  /// Get circuit breaker status
  CircuitBreakerStatus get status {
    return CircuitBreakerStatus(
      name: name,
      isOpen: _isOpen,
      failureCount: _failureCount,
      failureThreshold: failureThreshold,
      lastFailureTime: _lastFailureTime,
    );
  }
}

/// Circuit breaker status
class CircuitBreakerStatus {
  const CircuitBreakerStatus({
    required this.name,
    required this.isOpen,
    required this.failureCount,
    required this.failureThreshold,
    this.lastFailureTime,
  });

  final String name;
  final bool isOpen;
  final int failureCount;
  final int failureThreshold;
  final DateTime? lastFailureTime;
}

/// Exception thrown when circuit breaker is open
class CircuitBreakerOpenException implements Exception {
  CircuitBreakerOpenException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when batch operation fails
class BatchOperationException implements Exception {
  BatchOperationException(
    this.message, {
    required this.completedOperations,
    required this.totalOperations,
    required this.errors,
  });

  final String message;
  final int completedOperations;
  final int totalOperations;
  final List<dynamic> errors;

  @override
  String toString() {
    return '$message (completed: $completedOperations/$totalOperations, errors: ${errors.length})';
  }
}

/// Timeout exception
class TimeoutException implements Exception {
  TimeoutException(this.message);
  final String message;

  @override
  String toString() => message;
}

