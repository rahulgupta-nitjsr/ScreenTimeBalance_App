import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/error_logging_service.dart';
import '../services/backup_recovery_service.dart';
import '../services/network_resilience_service.dart';
import 'repository_providers.dart';

/// Provider for global error logging service
/// 
/// **Product Learning:**
/// Centralized error handling makes debugging easier and improves user experience.
/// All errors flow through this single service for consistent handling.
final errorLoggingServiceProvider = Provider<ErrorLoggingService>((ref) {
  return ErrorLoggingService();
});

/// Provider for backup and recovery service
final backupRecoveryServiceProvider = Provider<BackupRecoveryService>((ref) {
  return BackupRecoveryService(
    habitRepository: ref.watch(dailyHabitRepositoryProvider),
    auditRepository: ref.watch(auditRepositoryProvider),
  );
});

/// Provider for network resilience service
final networkResilienceServiceProvider = Provider<NetworkResilienceService>((ref) {
  return NetworkResilienceService();
});

/// Initialize global error handling
/// 
/// **Product Learning:**
/// This should be called early in app initialization to catch all errors.
void initializeErrorHandling(WidgetRef ref) {
  final errorService = ref.read(errorLoggingServiceProvider);
  
  // Add listener to log critical errors
  errorService.addListener((error) {
    if (error.severity == ErrorSeverity.critical) {
      // In production, you might send this to a crash reporting service
      print('🚨 Critical error logged: ${error.message}');
    }
  });
}

