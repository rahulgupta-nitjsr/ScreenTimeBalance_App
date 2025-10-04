import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../models/daily_habit_entry.dart';
import '../models/habit_category.dart';

/// Data Export Service
/// 
/// Exports user data to CSV format for backup and analysis.
/// 
/// **Product Learning Note:**
/// Data export is important for:
/// 1. User trust - they can access their data anytime
/// 2. GDPR compliance - users have right to data portability
/// 3. Data analysis - users can analyze in Excel/Sheets
/// 4. Backup - users feel secure knowing data isn't locked in
class DataExportService {
  /// Export all habit entries to CSV
  /// Returns the file path of the exported CSV
  Future<String> exportHabitData({
    required String userId,
    required List<DailyHabitEntry> entries,
  }) async {
    try {
      // Prepare CSV data
      final List<List<dynamic>> csvData = [
        // Header row
        [
          'Date',
          'Sleep (minutes)',
          'Exercise (minutes)',
          'Outdoor (minutes)',
          'Productive (minutes)',
          'Total Habit Time',
          'Earned Screen Time',
          'Used Screen Time',
          'POWER+ Mode',
          'Streak Day',
        ],
      ];

      // Sort entries by date (most recent first)
      final sortedEntries = List<DailyHabitEntry>.from(entries)
        ..sort((a, b) => b.date.compareTo(a.date));

      // Add data rows
      for (final entry in sortedEntries) {
        final dateStr = DateFormat('yyyy-MM-dd').format(entry.date);
        final sleepMinutes = entry.minutesByCategory[HabitCategory.sleep] ?? 0;
        final exerciseMinutes = entry.minutesByCategory[HabitCategory.exercise] ?? 0;
        final outdoorMinutes = entry.minutesByCategory[HabitCategory.outdoor] ?? 0;
        final productiveMinutes = entry.minutesByCategory[HabitCategory.productive] ?? 0;
        final totalHabitTime = sleepMinutes + exerciseMinutes + outdoorMinutes + productiveMinutes;

        csvData.add([
          dateStr,
          sleepMinutes,
          exerciseMinutes,
          outdoorMinutes,
          productiveMinutes,
          totalHabitTime,
          entry.earnedScreenTime,
          entry.usedScreenTime,
          entry.powerModeUnlocked ? 'Yes' : 'No',
          'N/A', // Streak day info not available in current model
        ]);
      }

      // Convert to CSV string
      final csv = const ListToCsvConverter().convert(csvData);

      // Get file path
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'zenscreen_data_$timestamp.csv';
      final filePath = '${directory.path}/$fileName';

      // Write to file
      final file = File(filePath);
      await file.writeAsString(csv);

      return filePath;
    } catch (e) {
      throw DataExportException('Failed to export data: $e');
    }
  }

  /// Export summary statistics to CSV
  Future<String> exportSummaryStats({
    required String userId,
    required Map<String, dynamic> stats,
  }) async {
    try {
      final List<List<dynamic>> csvData = [
        ['Statistic', 'Value'],
        ['Total Days Tracked', stats['totalDays'] ?? 0],
        ['Days Active', stats['daysActive'] ?? 0],
        ['Total Screen Time Earned', '${stats['totalEarned'] ?? 0} minutes'],
        ['Total Screen Time Used', '${stats['totalUsed'] ?? 0} minutes'],
        ['POWER+ Mode Achieved', '${stats['powerModeDays'] ?? 0} times'],
        ['Current Streak', '${stats['currentStreak'] ?? 0} days'],
        ['Longest Streak', '${stats['longestStreak'] ?? 0} days'],
        ['Average Daily Habits', '${stats['avgDailyHabits'] ?? 0} minutes'],
      ];

      final csv = const ListToCsvConverter().convert(csvData);

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'zenscreen_summary_$timestamp.csv';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsString(csv);

      return filePath;
    } catch (e) {
      throw DataExportException('Failed to export summary: $e');
    }
  }

  /// Get export directory path (for showing to user)
  Future<String> getExportDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}

/// Custom exception for data export errors
class DataExportException implements Exception {
  final String message;
  DataExportException(this.message);

  @override
  String toString() => message;
}

