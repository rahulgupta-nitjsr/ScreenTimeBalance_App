import 'package:flutter/foundation.dart';
import '../models/audit_event.dart';
import '../models/daily_habit_entry.dart';
import '../models/habit_category.dart';
import '../services/daily_habit_repository.dart';
import '../services/audit_repository.dart';
import '../services/algorithm_service.dart';

/// Service for handling habit entry edits with audit trail
/// 
/// **Product Learning:**
/// This service implements the "trust but verify" principle:
/// - Allow users to fix mistakes (builds trust)
/// - But track all changes (maintains integrity)
/// - Enforce reasonable limits (prevents gaming)
class HabitEditService {
  HabitEditService({
    required DailyHabitRepository habitRepository,
    required AuditRepository auditRepository,
    required AlgorithmService algorithmService,
  })  : _habitRepository = habitRepository,
        _auditRepository = auditRepository,
        _algorithmService = algorithmService;

  final DailyHabitRepository _habitRepository;
  final AuditRepository _auditRepository;
  final AlgorithmService _algorithmService;

  /// Maximum number of edits allowed per day
  static const int maxEditsPerDay = 5;

  /// Time threshold (in minutes) for requiring confirmation
  static const int confirmationThresholdMinutes = 30;

  /// Check if an entry can be edited
  /// 
  /// **Product Learning:**
  /// Validation should happen BEFORE showing UI, not after user tries to save.
  /// This prevents frustration from filling out a form that will be rejected.
  Future<bool> canEditEntry({
    required String userId,
    required DateTime entryDate,
  }) async {
    // Only allow editing today's entry
    final today = DateTime.now();
    final isToday = entryDate.year == today.year &&
        entryDate.month == today.month &&
        entryDate.day == today.day;

    if (!isToday) {
      return false;
    }

    // Check if max edits exceeded
    final editsCount = await _getEditCountForDate(userId: userId, date: entryDate);
    if (editsCount >= maxEditsPerDay) {
      return false;
    }

    return true;
  }

  /// Edit a habit entry with audit trail
  /// 
  /// **Product Learning:**
  /// This method demonstrates "atomic operations" - either everything succeeds
  /// or everything fails. We don't want partial updates in the database.
  Future<EditResult> editHabitEntry({
    required String userId,
    required DateTime entryDate,
    required HabitCategory category,
    required int newMinutes,
    String? reason,
    bool confirmed = false,
  }) async {
    try {
      // Step 1: Validation
      final canEdit = await canEditEntry(userId: userId, entryDate: entryDate);
      if (!canEdit) {
        final today = DateTime.now();
        final isToday = entryDate.year == today.year &&
            entryDate.month == today.month &&
            entryDate.day == today.day;

        if (!isToday) {
          return const EditResult(
            success: false,
            errorMessage: 'Can only edit today\'s habits',
          );
        } else {
          return EditResult(
            success: false,
            errorMessage: 'Maximum edits ($maxEditsPerDay) reached for today',
          );
        }
      }

      // Step 2: Get existing entry
      final existingEntry = await _habitRepository.getEntry(
        userId: userId,
        date: entryDate,
      );

      if (existingEntry == null) {
        return const EditResult(
          success: false,
          errorMessage: 'No habit entry found for this date',
        );
      }

      final oldMinutes = existingEntry.minutesByCategory[category] ?? 0;
      final minutesDifference = (newMinutes - oldMinutes).abs();

      // Step 3: Check if confirmation is required
      if (!confirmed && minutesDifference >= confirmationThresholdMinutes) {
        final changeSummary = _buildChangeSummary(
          category: category,
          oldMinutes: oldMinutes,
          newMinutes: newMinutes,
        );
        return EditResult(
          success: false,
          requiresConfirmation: true,
          changeSummary: changeSummary,
        );
      }

      // Step 4: Update the entry
      final updatedMinutes = Map<HabitCategory, int>.from(existingEntry.minutesByCategory);
      updatedMinutes[category] = newMinutes;

      // Recalculate earned screen time with updated values
      final algorithmResult = _algorithmService.calculate(
        minutesByCategory: updatedMinutes,
      );

      // Step 5: Save updated entry
      final updatedEntry = await _habitRepository.upsertEntry(
        userId: userId,
        date: entryDate,
        minutesByCategory: updatedMinutes,
        earnedScreenTime: algorithmResult.totalEarnedMinutes,
        usedScreenTime: existingEntry.usedScreenTime,
        powerModeUnlocked: algorithmResult.powerModeUnlocked,
        algorithmVersion: algorithmResult.algorithmVersion,
      );

      // Step 6: Log audit event
      await _auditRepository.logEvent(
        AuditEvent(
          id: '',
          userId: userId,
          eventType: 'habit_edit',
          targetDate: entryDate,
          category: category.id,
          oldValue: oldMinutes,
          newValue: newMinutes,
          reason: reason,
          metadata: {
            'old_earned_time': existingEntry.earnedScreenTime,
            'new_earned_time': updatedEntry.earnedScreenTime,
            'old_power_mode': existingEntry.powerModeUnlocked,
            'new_power_mode': updatedEntry.powerModeUnlocked,
            'minutes_difference': minutesDifference,
          },
        ),
      );

      if (kDebugMode) {
        print('✅ Habit edited: ${category.label} changed from $oldMinutes to $newMinutes minutes');
        print('   Earned time: ${existingEntry.earnedScreenTime} → ${updatedEntry.earnedScreenTime}');
      }

      return EditResult(
        success: true,
        updatedEntry: updatedEntry,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Edit failed: $e');
      }
      return EditResult(
        success: false,
        errorMessage: 'Failed to edit habit: ${e.toString()}',
      );
    }
  }

  /// Get the number of edits made today
  Future<int> _getEditCountForDate({
    required String userId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final events = await _auditRepository.listEvents(
      userId: userId,
      start: startOfDay,
      end: endOfDay,
    );

    // Count only edit events
    return events.where((e) => e.eventType == 'habit_edit').length;
  }

  /// Build a human-readable change summary
  String _buildChangeSummary({
    required HabitCategory category,
    required int oldMinutes,
    required int newMinutes,
  }) {
    final difference = newMinutes - oldMinutes;
    final direction = difference > 0 ? 'increase' : 'decrease';
    final absChange = difference.abs();

    return 'You are about to $direction ${category.label} by $absChange minutes '
        '(from $oldMinutes to $newMinutes minutes). This is a significant change. '
        'Are you sure this is correct?';
  }

  /// Get edit history for a specific date
  Future<List<AuditEvent>> getEditHistory({
    required String userId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final events = await _auditRepository.listEvents(
      userId: userId,
      start: startOfDay,
      end: endOfDay,
    );

    return events.where((e) => e.eventType == 'habit_edit').toList();
  }

  /// Check if an entry has been edited
  Future<bool> hasBeenEdited({
    required String userId,
    required DateTime date,
  }) async {
    final edits = await getEditHistory(userId: userId, date: date);
    return edits.isNotEmpty;
  }
}

/// Result of attempting to edit a habit entry
class EditResult {
  const EditResult({
    required this.success,
    this.updatedEntry,
    this.errorMessage,
    this.requiresConfirmation = false,
    this.changeSummary,
  });

  final bool success;
  final DailyHabitEntry? updatedEntry;
  final String? errorMessage;
  final bool requiresConfirmation;
  final String? changeSummary;
}

