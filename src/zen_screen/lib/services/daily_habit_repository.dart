import 'dart:math';

import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_habit_entry.dart';
import '../models/habit_category.dart';
import 'platform_database_service.dart';
import '../providers/screen_time_provider.dart';

class DailyHabitRepository {
  DailyHabitRepository({PlatformDatabaseService? databaseService})
      : _database = databaseService ?? PlatformDatabaseService.instance;

  final PlatformDatabaseService _database;
  final _uuid = const Uuid();

  static const _table = 'daily_habit_entries';

  Future<DailyHabitEntry> upsertEntry({
    required String userId,
    required DateTime date,
    required Map<HabitCategory, int> minutesByCategory,
    required int earnedScreenTime,
    int? usedScreenTime,
    int? remainingScreenTime,
    required bool powerModeUnlocked,
    required String algorithmVersion,
    int? manualAdjustmentMinutes,
    WidgetRef? ref, // Add WidgetRef for accessing providers
  }) async {
    final sanitizedMinutes = _sanitizeMinutes(minutesByCategory);

    // Fetch latest screen time values if not provided
    int actualUsedScreenTime = usedScreenTime ?? 0;
    if (ref != null && usedScreenTime == null) {
      final screenTimeState = await ref.read(screenTimeStateProvider.future);
      actualUsedScreenTime = screenTimeState.used;
    }

    // Compute remainingScreenTime if not provided
    final computedRemaining = remainingScreenTime ?? max(earnedScreenTime - actualUsedScreenTime, 0);

    _validateInputs(
      userId: userId,
      minutesByCategory: sanitizedMinutes,
      earnedScreenTime: earnedScreenTime,
      usedScreenTime: actualUsedScreenTime,
      remainingScreenTime: computedRemaining,
      algorithmVersion: algorithmVersion,
    );

    final existing = await getEntry(userId: userId, date: date);
    final now = DateTime.now();
    final entry = DailyHabitEntry(
      id: existing?.id ?? _uuid.v4(),
      userId: userId,
      date: DateTime(date.year, date.month, date.day),
      minutesByCategory: sanitizedMinutes,
      earnedScreenTime: earnedScreenTime,
      usedScreenTime: actualUsedScreenTime,
      remainingScreenTime: computedRemaining,
      powerModeUnlocked: powerModeUnlocked,
      algorithmVersion: algorithmVersion,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      manualAdjustmentMinutes: manualAdjustmentMinutes ?? existing?.manualAdjustmentMinutes ?? 0,
    );

    if (existing != null) {
      // Update existing entry
      await _database.update(
        _table,
        _toDbMap(entry),
        where: 'id = ?',
        whereArgs: [entry.id],
      );
    } else {
      // Insert new entry
      await _database.insert(_table, _toDbMap(entry));
    }
    
    return entry;
  }

  Future<DailyHabitEntry?> getEntry({required String userId, required DateTime date}) async {
    final rows = await _database.query(
      _table,
      where: 'user_id = ? AND entry_date = ?',
      whereArgs: [userId, _formatDate(date)],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromDbMap(rows.first);
  }

  // Alias for getEntry to match expected interface
  Future<DailyHabitEntry?> getEntryForDate({required String userId, required DateTime date}) async {
    return getEntry(userId: userId, date: date);
  }

  Future<List<DailyHabitEntry>> getEntriesWithinRange({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    final rows = await _database.query(
      _table,
      where: 'user_id = ? AND entry_date BETWEEN ? AND ?',
      whereArgs: [userId, _formatDate(start), _formatDate(end)],
      orderBy: 'entry_date DESC',
    );
    return rows.map(_fromDbMap).toList();
  }

  Future<int> deleteEntry({required String id}) {
    return _database.delete(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _toDbMap(DailyHabitEntry entry) => entry.toDbMap();

  DailyHabitEntry _fromDbMap(Map<String, dynamic> map) => DailyHabitEntry.fromDbMap(map);

  String _formatDate(DateTime date) => DateTime(date.year, date.month, date.day).toIso8601String();

  Map<HabitCategory, int> _sanitizeMinutes(Map<HabitCategory, int> minutes) {
    final sanitized = <HabitCategory, int>{
      for (final category in HabitCategory.values)
        category: minutes[category] ?? 0,
    };
    return sanitized;
  }

  void _validateInputs({
    required String userId,
    required Map<HabitCategory, int> minutesByCategory,
    required int earnedScreenTime,
    required int usedScreenTime,
    required int remainingScreenTime,
    required String algorithmVersion,
  }) {
    if (userId.isEmpty) {
      throw ArgumentError('userId is required');
    }
    if (algorithmVersion.trim().isEmpty) {
      throw ArgumentError('algorithmVersion is required');
    }
    if (earnedScreenTime < 0 || usedScreenTime < 0 || remainingScreenTime < 0) {
      throw ArgumentError('Screen time values cannot be negative');
    }
    if (minutesByCategory.values.any((minutes) => minutes < 0)) {
      throw ArgumentError('Habit minutes cannot be negative');
    }
  }

  /// Get all entries for a user
  Future<List<DailyHabitEntry>> getAllEntries({required String userId}) async {
    final results = await _database.query(
      _table,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'entry_date DESC',
    );

    return results.map((row) => DailyHabitEntry.fromDbMap(row)).toList();
  }
}
