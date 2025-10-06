import 'package:flutter/foundation.dart';
import 'dart:collection';

/// Service for logging and managing errors
/// 
/// **Product Learning:**
/// Error logging is critical for improving your app. You can't fix what you
/// don't know is broken. This service captures errors, categorizes them,
/// and provides insights for debugging.
/// 
/// **Privacy Note:**
/// We DON'T send errors to external services without user consent.
/// All logging is local-first, respecting user privacy.
class ErrorLoggingService {
  ErrorLoggingService();

  /// Maximum number of errors to keep in memory
  static const int maxErrorHistory = 100;

  /// Error history (circular buffer)
  final Queue<AppError> _errorHistory = Queue<AppError>();

  /// Error listeners
  final List<void Function(AppError)> _errorListeners = [];

  /// Log an error
  /// 
  /// **Product Learning:**
  /// Categorizing errors helps prioritize fixes. Critical errors (data loss)
  /// need immediate attention. Warning-level errors can wait.
  void logError({
    required String message,
    String? code,
    ErrorSeverity severity = ErrorSeverity.error,
    ErrorCategory category = ErrorCategory.unknown,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    dynamic originalError,
  }) {
    final error = AppError(
      message: message,
      code: code,
      severity: severity,
      category: category,
      timestamp: DateTime.now(),
      stackTrace: stackTrace,
      context: context,
      originalError: originalError,
    );

    // Add to history (maintain max size)
    _errorHistory.add(error);
    if (_errorHistory.length > maxErrorHistory) {
      _errorHistory.removeFirst();
    }

    // Notify listeners
    for (final listener in _errorListeners) {
      try {
        listener(error);
      } catch (e) {
        if (kDebugMode) {
          print('Error in error listener: $e');
        }
      }
    }

    // Log to console in debug mode
    if (kDebugMode) {
      _logToConsole(error);
    }
  }

  /// Add an error listener
  void addListener(void Function(AppError) listener) {
    _errorListeners.add(listener);
  }

  /// Remove an error listener
  void removeListener(void Function(AppError) listener) {
    _errorListeners.remove(listener);
  }

  /// Get error history
  List<AppError> getErrorHistory({
    ErrorSeverity? minSeverity,
    ErrorCategory? category,
    DateTime? since,
  }) {
    return _errorHistory.where((error) {
      if (minSeverity != null && error.severity.index < minSeverity.index) {
        return false;
      }
      if (category != null && error.category != category) {
        return false;
      }
      if (since != null && error.timestamp.isBefore(since)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Get error statistics
  ErrorStatistics getStatistics() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final lastHour = now.subtract(const Duration(hours: 1));

    final errors24h = _errorHistory.where((e) => e.timestamp.isAfter(last24Hours)).toList();
    final errors1h = _errorHistory.where((e) => e.timestamp.isAfter(lastHour)).toList();

    final categoryCounts = <ErrorCategory, int>{};
    for (final error in errors24h) {
      categoryCounts[error.category] = (categoryCounts[error.category] ?? 0) + 1;
    }

    return ErrorStatistics(
      totalErrors: _errorHistory.length,
      errorsLast24Hours: errors24h.length,
      errorsLastHour: errors1h.length,
      criticalErrors: errors24h.where((e) => e.severity == ErrorSeverity.critical).length,
      errorsByCategory: categoryCounts,
    );
  }

  /// Clear error history
  void clearHistory() {
    _errorHistory.clear();
  }

  /// Log to console with formatting
  void _logToConsole(AppError error) {
    final emoji = _getSeverityEmoji(error.severity);
    print('$emoji [${error.severity.name.toUpperCase()}] ${error.category.name}: ${error.message}');
    
    if (error.code != null) {
      print('   Code: ${error.code}');
    }
    
    if (error.context != null && error.context!.isNotEmpty) {
      print('   Context: ${error.context}');
    }
    
    if (error.stackTrace != null) {
      print('   Stack trace:\n${error.stackTrace}');
    }
  }

  String _getSeverityEmoji(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.debug:
        return '🔍';
      case ErrorSeverity.info:
        return 'ℹ️';
      case ErrorSeverity.warning:
        return '⚠️';
      case ErrorSeverity.error:
        return '❌';
      case ErrorSeverity.critical:
        return '🚨';
    }
  }
}

/// Represents an application error
class AppError {
  AppError({
    required this.message,
    this.code,
    required this.severity,
    required this.category,
    required this.timestamp,
    this.stackTrace,
    this.context,
    this.originalError,
  });

  final String message;
  final String? code;
  final ErrorSeverity severity;
  final ErrorCategory category;
  final DateTime timestamp;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? context;
  final dynamic originalError;
}

/// Error severity levels
enum ErrorSeverity {
  debug,    // Development information
  info,     // Informational messages
  warning,  // Potential issues
  error,    // Recoverable errors
  critical, // Critical failures
}

/// Error categories
enum ErrorCategory {
  network,     // Network/API errors
  database,    // Database errors
  auth,        // Authentication errors
  validation,  // Data validation errors
  sync,        // Synchronization errors
  permission,  // Permission errors
  unknown,     // Uncategorized errors
}

/// Error statistics
class ErrorStatistics {
  ErrorStatistics({
    required this.totalErrors,
    required this.errorsLast24Hours,
    required this.errorsLastHour,
    required this.criticalErrors,
    required this.errorsByCategory,
  });

  final int totalErrors;
  final int errorsLast24Hours;
  final int errorsLastHour;
  final int criticalErrors;
  final Map<ErrorCategory, int> errorsByCategory;
}

