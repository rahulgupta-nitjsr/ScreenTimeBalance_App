import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../models/daily_habit_entry.dart';
import '../models/audit_event.dart';
import '../services/daily_habit_repository.dart';
import '../services/audit_repository.dart';
import '../services/platform_database_service.dart';

/// Service for backing up and recovering data
/// 
/// **Product Learning:**
/// Data loss is unacceptable. Users trust us with their habit tracking data.
/// Regular backups ensure we can always recover, even from catastrophic failures.
/// 
/// **Backup Strategy:**
/// 1. Automatic backups before risky operations
/// 2. Manual backups on demand
/// 3. Keep multiple backup versions
/// 4. Fast recovery with integrity checks
class BackupRecoveryService {
  BackupRecoveryService({
    required DailyHabitRepository habitRepository,
    required AuditRepository auditRepository,
  })  : _habitRepository = habitRepository,
        _auditRepository = auditRepository;

  final DailyHabitRepository _habitRepository;
  final AuditRepository _auditRepository;

  /// Maximum number of backup versions to keep
  static const int maxBackupVersions = 5;

  /// Create a backup of all user data
  /// 
  /// **Product Learning:**
  /// Backups should be fast and non-blocking. Users shouldn't wait for backups.
  /// We export to JSON format for portability and human-readability.
  Future<BackupResult> createBackup({
    required String userId,
    String? reason,
  }) async {
    try {
      final timestamp = DateTime.now();
      
      if (kDebugMode) {
        print('📦 Starting backup for user $userId...');
      }

      // Get all habit entries
      final habits = await _habitRepository.getAllEntries(userId: userId);
      
      // Get all audit events
      final audits = await _auditRepository.getAllEvents(userId: userId);

      // Create backup data structure
      final backup = BackupData(
        userId: userId,
        timestamp: timestamp,
        version: '1.0.0',
        reason: reason,
        habitEntries: habits.map((e) => e.toMap()).toList(),
        auditEvents: audits.map((e) => e.toMap()).toList(),
      );

      // Serialize to JSON
      final jsonString = jsonEncode(backup.toJson());
      final bytes = utf8.encode(jsonString);

      if (kDebugMode) {
        print('✅ Backup created: ${habits.length} habits, ${audits.length} audit events');
        print('   Size: ${(bytes.length / 1024).toStringAsFixed(2)} KB');
      }

      return BackupResult(
        success: true,
        backup: backup,
        sizeBytes: bytes.length,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Backup failed: $e');
        print(stackTrace);
      }

      return BackupResult(
        success: false,
        errorMessage: 'Failed to create backup: ${e.toString()}',
      );
    }
  }

  /// Restore data from a backup
  /// 
  /// **Product Learning:**
  /// Recovery is a critical path. It must be:
  /// 1. Fast (users are stressed when recovering)
  /// 2. Reliable (can't fail during recovery!)
  /// 3. Transparent (show progress and results)
  Future<RecoveryResult> restoreFromBackup({
    required BackupData backup,
    bool overwriteExisting = false,
  }) async {
    try {
      if (kDebugMode) {
        print('♻️ Starting recovery from backup...');
      }

      int habitsRestored = 0;
      int auditsRestored = 0;
      final errors = <String>[];

      // Restore habit entries
      for (final habitMap in backup.habitEntries) {
        try {
          final entry = DailyHabitEntry.fromMap(habitMap);
          
          if (overwriteExisting) {
            await _habitRepository.upsertEntry(
              userId: entry.userId,
              date: entry.date,
              minutesByCategory: entry.minutesByCategory,
              earnedScreenTime: entry.earnedScreenTime,
              usedScreenTime: entry.usedScreenTime,
              powerModeUnlocked: entry.powerModeUnlocked,
              algorithmVersion: entry.algorithmVersion,
            );
            habitsRestored++;
          } else {
            // Only restore if entry doesn't exist
            final existing = await _habitRepository.getEntry(
              userId: entry.userId,
              date: entry.date,
            );
            
            if (existing == null) {
              await _habitRepository.upsertEntry(
                userId: entry.userId,
                date: entry.date,
                minutesByCategory: entry.minutesByCategory,
                earnedScreenTime: entry.earnedScreenTime,
                usedScreenTime: entry.usedScreenTime,
                powerModeUnlocked: entry.powerModeUnlocked,
                algorithmVersion: entry.algorithmVersion,
              );
              habitsRestored++;
            }
          }
        } catch (e) {
          errors.add('Habit entry: ${e.toString()}');
        }
      }

      // Restore audit events
      for (final auditMap in backup.auditEvents) {
        try {
          final event = AuditEvent.fromMap(auditMap);
          await _auditRepository.createEvent(event);
          auditsRestored++;
        } catch (e) {
          errors.add('Audit event: ${e.toString()}');
        }
      }

      if (kDebugMode) {
        print('✅ Recovery complete: $habitsRestored habits, $auditsRestored audit events');
        if (errors.isNotEmpty) {
          print('⚠️ ${errors.length} errors during recovery');
        }
      }

      return RecoveryResult(
        success: true,
        habitEntriesRestored: habitsRestored,
        auditEventsRestored: auditsRestored,
        errors: errors,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Recovery failed: $e');
        print(stackTrace);
      }

      return RecoveryResult(
        success: false,
        errorMessage: 'Failed to restore backup: ${e.toString()}',
        habitEntriesRestored: 0,
        auditEventsRestored: 0,
        errors: [],
      );
    }
  }

  /// Verify backup integrity
  /// 
  /// **Product Learning:**
  /// Before attempting recovery, verify the backup is valid.
  /// Better to fail early than corrupt existing data.
  Future<BackupVerification> verifyBackup(BackupData backup) async {
    final issues = <String>[];
    int validHabits = 0;
    int validAudits = 0;

    // Verify habit entries
    for (final habitMap in backup.habitEntries) {
      try {
        DailyHabitEntry.fromMap(habitMap);
        validHabits++;
      } catch (e) {
        issues.add('Invalid habit entry: ${e.toString()}');
      }
    }

    // Verify audit events
    for (final auditMap in backup.auditEvents) {
      try {
        AuditEvent.fromMap(auditMap);
        validAudits++;
      } catch (e) {
        issues.add('Invalid audit event: ${e.toString()}');
      }
    }

    final isValid = issues.isEmpty;

    return BackupVerification(
      isValid: isValid,
      validHabitEntries: validHabits,
      validAuditEvents: validAudits,
      issues: issues,
    );
  }
}

/// Backup data structure
class BackupData {
  BackupData({
    required this.userId,
    required this.timestamp,
    required this.version,
    this.reason,
    required this.habitEntries,
    required this.auditEvents,
  });

  final String userId;
  final DateTime timestamp;
  final String version;
  final String? reason;
  final List<Map<String, dynamic>> habitEntries;
  final List<Map<String, dynamic>> auditEvents;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'version': version,
      'reason': reason,
      'habitEntries': habitEntries,
      'auditEvents': auditEvents,
    };
  }

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      userId: json['userId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      version: json['version'] as String,
      reason: json['reason'] as String?,
      habitEntries: List<Map<String, dynamic>>.from(json['habitEntries'] as List),
      auditEvents: List<Map<String, dynamic>>.from(json['auditEvents'] as List),
    );
  }
}

/// Result of backup operation
class BackupResult {
  const BackupResult({
    required this.success,
    this.backup,
    this.sizeBytes,
    this.errorMessage,
  });

  final bool success;
  final BackupData? backup;
  final int? sizeBytes;
  final String? errorMessage;
}

/// Result of recovery operation
class RecoveryResult {
  const RecoveryResult({
    required this.success,
    required this.habitEntriesRestored,
    required this.auditEventsRestored,
    required this.errors,
    this.errorMessage,
  });

  final bool success;
  final int habitEntriesRestored;
  final int auditEventsRestored;
  final List<String> errors;
  final String? errorMessage;
}

/// Backup verification result
class BackupVerification {
  const BackupVerification({
    required this.isValid,
    required this.validHabitEntries,
    required this.validAuditEvents,
    required this.issues,
  });

  final bool isValid;
  final int validHabitEntries;
  final int validAuditEvents;
  final List<String> issues;
}

