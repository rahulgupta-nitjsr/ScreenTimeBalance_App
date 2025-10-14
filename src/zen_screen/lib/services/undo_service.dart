import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/daily_habit_entry.dart';
import '../models/habit_category.dart';
import '../services/daily_habit_repository.dart';
import '../services/audit_repository.dart';
import '../services/algorithm_service.dart';
import '../models/audit_event.dart';

/// Service for managing undo operations
/// 
/// **Product Learning:**
/// The "undo" feature is one of the most user-friendly patterns in UX design.
/// It allows users to experiment without fear, knowing they can reverse mistakes.
/// 
/// **Implementation Pattern:**
/// We store the last action in memory with a 5-minute expiration timer.
/// After 5 minutes, the undo opportunity expires to prevent abuse.
class UndoService {
  UndoService({
    required DailyHabitRepository habitRepository,
    required AuditRepository auditRepository,
    required AlgorithmService algorithmService,
  })  : _habitRepository = habitRepository,
        _auditRepository = auditRepository,
        _algorithmService = algorithmService;

  final DailyHabitRepository _habitRepository;
  final AuditRepository _auditRepository;
  final AlgorithmService _algorithmService;

  /// Undo window in minutes
  static const int undoWindowMinutes = 5;

  /// Stores the last undoable action
  _UndoableAction? _lastAction;
  Timer? _undoExpirationTimer;

  /// Callback when undo availability changes
  Function(bool canUndo)? onUndoAvailabilityChanged;

  /// Check if undo is available
  bool get canUndo {
    if (_lastAction == null) return false;

    final now = DateTime.now();
    final elapsed = now.difference(_lastAction!.timestamp);

    return elapsed.inMinutes < undoWindowMinutes;
  }

  /// Get remaining undo time in seconds
  int get remainingUndoSeconds {
    if (_lastAction == null) return 0;

    final now = DateTime.now();
    final elapsed = now.difference(_lastAction!.timestamp);
    final remaining = (undoWindowMinutes * 60) - elapsed.inSeconds;

    return remaining > 0 ? remaining : 0;
  }

  /// Register an action that can be undone
  /// 
  /// **Product Learning:**
  /// We don't automatically save every action as undoable. Only actions
  /// that modify data and are likely to be mistakes (like edits) are undoable.
  Future<void> registerUndoableAction({
    required String userId,
    required DateTime entryDate,
    required HabitCategory category,
    required int oldMinutes,
    required int newMinutes,
    required DailyHabitEntry previousEntry,
  }) async {
    // Cancel any existing timer
    _undoExpirationTimer?.cancel();

    // Store the action
    _lastAction = _UndoableAction(
      userId: userId,
      entryDate: entryDate,
      category: category,
      oldMinutes: oldMinutes,
      newMinutes: newMinutes,
      previousEntry: previousEntry,
      timestamp: DateTime.now(),
    );

    // Set expiration timer
    _undoExpirationTimer = Timer(
      Duration(minutes: undoWindowMinutes),
      () {
        _lastAction = null;
        onUndoAvailabilityChanged?.call(false);
        if (kDebugMode) {
          print('⏰ Undo window expired');
        }
      },
    );

    onUndoAvailabilityChanged?.call(true);

    if (kDebugMode) {
      print('📝 Registered undoable action: ${category.label} $oldMinutes → $newMinutes');
    }
  }

  /// Perform undo operation
  /// 
  /// **Product Learning:**
  /// Undo should be fast and reliable. Users expect instant feedback.
  /// We restore the previous state and log the undo as an audit event.
  Future<UndoResult> performUndo() async {
    if (!canUndo) {
      return const UndoResult(
        success: false,
        errorMessage: 'No action available to undo',
      );
    }

    final action = _lastAction!;

    try {
      // Restore the previous entry
      final restoredMinutes = Map<HabitCategory, int>.from(
        action.previousEntry.minutesByCategory,
      );

      // Recalculate with restored values
      final algorithmResult = _algorithmService.calculate(
        minutesByCategory: restoredMinutes,
      );

      // Save restored entry
      final restoredEntry = await _habitRepository.upsertEntry(
        userId: action.userId,
        date: action.entryDate,
        minutesByCategory: restoredMinutes,
        earnedScreenTime: algorithmResult.totalEarnedMinutes,
        usedScreenTime: action.previousEntry.usedScreenTime,
        remainingScreenTime: action.previousEntry.remainingScreenTime,
        powerModeUnlocked: algorithmResult.powerModeUnlocked,
        algorithmVersion: algorithmResult.algorithmVersion,
      );

      // Log undo as audit event
      await _auditRepository.logEvent(
        AuditEvent(
          id: '',
          userId: action.userId,
          eventType: 'habit_undo',
          targetDate: action.entryDate,
          category: action.category.id,
          oldValue: action.newMinutes,
          newValue: action.oldMinutes,
          reason: 'Undo: Reverted change within ${undoWindowMinutes}-minute window',
          metadata: {
            'action_type': 'undo',
            'original_change_timestamp': action.timestamp.toIso8601String(),
            'undo_timestamp': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Clear the undo action
      _clearUndo();

      if (kDebugMode) {
        print('↩️ Undo successful: ${action.category.label} restored to ${action.oldMinutes}');
      }

      return UndoResult(
        success: true,
        restoredEntry: restoredEntry,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Undo failed: $e');
      }
      return UndoResult(
        success: false,
        errorMessage: 'Failed to undo: ${e.toString()}',
      );
    }
  }

  /// Clear the undo action
  void _clearUndo() {
    _undoExpirationTimer?.cancel();
    _undoExpirationTimer = null;
    _lastAction = null;
    onUndoAvailabilityChanged?.call(false);
  }

  /// Get description of the action that can be undone
  String? getUndoDescription() {
    if (!canUndo) return null;

    final action = _lastAction!;
    final remaining = remainingUndoSeconds;
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;

    return 'Undo ${action.category.label} change: '
        '${action.oldMinutes} → ${action.newMinutes} min '
        '(${minutes}m ${seconds}s remaining)';
  }

  /// Dispose resources
  void dispose() {
    _undoExpirationTimer?.cancel();
    _lastAction = null;
  }
}

/// Result of an undo operation
class UndoResult {
  const UndoResult({
    required this.success,
    this.restoredEntry,
    this.errorMessage,
  });

  final bool success;
  final DailyHabitEntry? restoredEntry;
  final String? errorMessage;
}

/// Internal class to store undoable action data
class _UndoableAction {
  const _UndoableAction({
    required this.userId,
    required this.entryDate,
    required this.category,
    required this.oldMinutes,
    required this.newMinutes,
    required this.previousEntry,
    required this.timestamp,
  });

  final String userId;
  final DateTime entryDate;
  final HabitCategory category;
  final int oldMinutes;
  final int newMinutes;
  final DailyHabitEntry previousEntry;
  final DateTime timestamp;
}

