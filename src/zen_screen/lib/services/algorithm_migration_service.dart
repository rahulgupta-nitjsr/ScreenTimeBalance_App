import 'package:flutter/foundation.dart';

import '../models/algorithm_config.dart';
import '../models/daily_habit_entry.dart';
import 'algorithm_service.dart';

/// Service responsible for handling algorithm configuration changes and data migration
class AlgorithmMigrationService {
  AlgorithmMigrationService();

  /// Migrates existing daily entries when algorithm configuration changes
  Future<List<DailyHabitEntry>> migrateEntries({
    required List<DailyHabitEntry> existingEntries,
    required AlgorithmConfig oldConfig,
    required AlgorithmConfig newConfig,
    required AlgorithmService newAlgorithmService,
  }) async {
    if (oldConfig.version == newConfig.version) {
      if (kDebugMode) {
        print('✅ Algorithm versions match, no migration needed');
      }
      return existingEntries;
    }

    if (kDebugMode) {
      print('🔄 Migrating algorithm from ${oldConfig.version} to ${newConfig.version}');
    }

    final migratedEntries = <DailyHabitEntry>[];
    
    for (final entry in existingEntries) {
      // Recalculate with new algorithm
      final newResult = newAlgorithmService.calculate(
        minutesByCategory: entry.minutesByCategory,
      );
      
      // Create migrated entry with new algorithm version
      final migratedEntry = entry.copyWith(
        earnedScreenTime: newResult.totalEarnedMinutes,
        powerModeUnlocked: newResult.powerModeUnlocked,
        algorithmVersion: newResult.algorithmVersion,
        updatedAt: DateTime.now(),
      );
      
      migratedEntries.add(migratedEntry);
    }

    if (kDebugMode) {
      print('✅ Migrated ${migratedEntries.length} entries to algorithm ${newConfig.version}');
    }

    return migratedEntries;
  }

  /// Detects if algorithm configuration has breaking changes
  bool hasBreakingChanges(AlgorithmConfig oldConfig, AlgorithmConfig newConfig) {
    // Check for changes in earning rates
    for (final categoryId in oldConfig.categories.keys) {
      final oldCategory = oldConfig.categories[categoryId];
      final newCategory = newConfig.categories[categoryId];
      
      if (oldCategory == null || newCategory == null) continue;
      
      if (oldCategory.minutesPerHour != newCategory.minutesPerHour) {
        return true;
      }
      
      if (oldCategory.maxMinutes != newCategory.maxMinutes) {
        return true;
      }
    }

    // Check for changes in POWER+ Mode requirements
    if (oldConfig.powerPlus.requiredGoals != newConfig.powerPlus.requiredGoals) {
      return true;
    }
    
    if (oldConfig.powerPlus.bonusMinutes != newConfig.powerPlus.bonusMinutes) {
      return true;
    }

    // Check for changes in daily caps
    if (oldConfig.dailyCaps.baseMinutes != newConfig.dailyCaps.baseMinutes) {
      return true;
    }
    
    if (oldConfig.dailyCaps.powerPlusMinutes != newConfig.dailyCaps.powerPlusMinutes) {
      return true;
    }

    return false;
  }

  /// Generates a migration report for developers
  String generateMigrationReport({
    required AlgorithmConfig oldConfig,
    required AlgorithmConfig newConfig,
    required int entriesMigrated,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🔄 Algorithm Migration Report');
    buffer.writeln('============================');
    buffer.writeln('From: ${oldConfig.version}');
    buffer.writeln('To: ${newConfig.version}');
    buffer.writeln('Entries migrated: $entriesMigrated');
    buffer.writeln();
    
    if (hasBreakingChanges(oldConfig, newConfig)) {
      buffer.writeln('⚠️ BREAKING CHANGES DETECTED:');
      
      // Check earning rate changes
      for (final categoryId in oldConfig.categories.keys) {
        final oldCategory = oldConfig.categories[categoryId];
        final newCategory = newConfig.categories[categoryId];
        
        if (oldCategory == null || newCategory == null) continue;
        
        if (oldCategory.minutesPerHour != newCategory.minutesPerHour) {
          buffer.writeln('  • ${oldCategory.label}: ${oldCategory.minutesPerHour} → ${newCategory.minutesPerHour} min/hour');
        }
        
        if (oldCategory.maxMinutes != newCategory.maxMinutes) {
          buffer.writeln('  • ${oldCategory.label}: max ${oldCategory.maxMinutes} → ${newCategory.maxMinutes} minutes');
        }
      }
      
      // Check POWER+ changes
      if (oldConfig.powerPlus.requiredGoals != newConfig.powerPlus.requiredGoals) {
        buffer.writeln('  • POWER+ goals: ${oldConfig.powerPlus.requiredGoals} → ${newConfig.powerPlus.requiredGoals}');
      }
      
      if (oldConfig.powerPlus.bonusMinutes != newConfig.powerPlus.bonusMinutes) {
        buffer.writeln('  • POWER+ bonus: ${oldConfig.powerPlus.bonusMinutes} → ${newConfig.powerPlus.bonusMinutes} minutes');
      }
      
      // Check daily cap changes
      if (oldConfig.dailyCaps.baseMinutes != newConfig.dailyCaps.baseMinutes) {
        buffer.writeln('  • Base daily cap: ${oldConfig.dailyCaps.baseMinutes} → ${newConfig.dailyCaps.baseMinutes} minutes');
      }
      
      if (oldConfig.dailyCaps.powerPlusMinutes != newConfig.dailyCaps.powerPlusMinutes) {
        buffer.writeln('  • POWER+ daily cap: ${oldConfig.dailyCaps.powerPlusMinutes} → ${newConfig.dailyCaps.powerPlusMinutes} minutes');
      }
    } else {
      buffer.writeln('✅ No breaking changes detected');
    }
    
    return buffer.toString();
  }
}
