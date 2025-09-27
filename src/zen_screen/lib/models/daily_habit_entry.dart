import 'habit_category.dart';

class DailyHabitEntry {
  DailyHabitEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.minutesByCategory,
    required this.earnedScreenTime,
    required this.usedScreenTime,
    required this.powerModeUnlocked,
    required this.algorithmVersion,
    required this.createdAt,
    required this.updatedAt,
    this.manualAdjustmentMinutes = 0,
  });

  final String id;
  final String userId;
  final DateTime date;
  final Map<HabitCategory, int> minutesByCategory;
  final int earnedScreenTime;
  final int usedScreenTime;
  final bool powerModeUnlocked;
  final String algorithmVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int manualAdjustmentMinutes;

  DailyHabitEntry copyWith({
    Map<HabitCategory, int>? minutesByCategory,
    int? earnedScreenTime,
    int? usedScreenTime,
    bool? powerModeUnlocked,
    String? algorithmVersion,
    DateTime? updatedAt,
    int? manualAdjustmentMinutes,
  }) {
    return DailyHabitEntry(
      id: id,
      userId: userId,
      date: date,
      minutesByCategory: minutesByCategory ?? this.minutesByCategory,
      earnedScreenTime: earnedScreenTime ?? this.earnedScreenTime,
      usedScreenTime: usedScreenTime ?? this.usedScreenTime,
      powerModeUnlocked: powerModeUnlocked ?? this.powerModeUnlocked,
      algorithmVersion: algorithmVersion ?? this.algorithmVersion,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      manualAdjustmentMinutes: manualAdjustmentMinutes ?? this.manualAdjustmentMinutes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'minutesByCategory': minutesByCategory.map((key, value) => MapEntry(key.id, value)),
      'earnedScreenTime': earnedScreenTime,
      'usedScreenTime': usedScreenTime,
      'powerModeUnlocked': powerModeUnlocked ? 1 : 0,
      'algorithmVersion': algorithmVersion,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'manualAdjustmentMinutes': manualAdjustmentMinutes,
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'entry_date': DateTime(date.year, date.month, date.day).toIso8601String(),
      'minutes_sleep': minutesByCategory[HabitCategory.sleep] ?? 0,
      'minutes_exercise': minutesByCategory[HabitCategory.exercise] ?? 0,
      'minutes_outdoor': minutesByCategory[HabitCategory.outdoor] ?? 0,
      'minutes_productive': minutesByCategory[HabitCategory.productive] ?? 0,
      'earned_screen_time': earnedScreenTime,
      'used_screen_time': usedScreenTime,
      'power_mode_unlocked': powerModeUnlocked ? 1 : 0,
      'algorithm_version': algorithmVersion,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'manual_adjustment_minutes': manualAdjustmentMinutes,
    };
  }

  factory DailyHabitEntry.fromMap(Map<String, dynamic> map) {
    final minutes = (map['minutesByCategory'] as Map<String, dynamic>? ?? const {})
        .map((key, value) => MapEntry(HabitCategoryX.fromId(key), (value as num).toInt()));

    return DailyHabitEntry(
      id: map['id'] as String,
      userId: map['userId'] as String,
      date: DateTime.parse(map['date'] as String),
      minutesByCategory: minutes,
      earnedScreenTime: (map['earnedScreenTime'] as num).toInt(),
      usedScreenTime: (map['usedScreenTime'] as num).toInt(),
      powerModeUnlocked: (map['powerModeUnlocked'] as num) == 1,
      algorithmVersion: map['algorithmVersion'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      manualAdjustmentMinutes: (map['manualAdjustmentMinutes'] as num?)?.toInt() ?? 0,
    );
  }

  factory DailyHabitEntry.fromDbMap(Map<String, dynamic> map) {
    final minutes = {
      HabitCategory.sleep: (map['minutes_sleep'] as num?)?.toInt() ?? 0,
      HabitCategory.exercise: (map['minutes_exercise'] as num?)?.toInt() ?? 0,
      HabitCategory.outdoor: (map['minutes_outdoor'] as num?)?.toInt() ?? 0,
      HabitCategory.productive: (map['minutes_productive'] as num?)?.toInt() ?? 0,
    };

    return DailyHabitEntry(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['entry_date'] as String),
      minutesByCategory: minutes,
      earnedScreenTime: (map['earned_screen_time'] as num).toInt(),
      usedScreenTime: (map['used_screen_time'] as num).toInt(),
      powerModeUnlocked: (map['power_mode_unlocked'] as num) == 1,
      algorithmVersion: map['algorithm_version'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      manualAdjustmentMinutes: (map['manual_adjustment_minutes'] as num?)?.toInt() ?? 0,
    );
  }
}
