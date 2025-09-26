import 'habit_category.dart';

enum TimerSessionStatus { running, completed, cancelled }

class TimerSession {
  TimerSession({
    required this.id,
    required this.userId,
    required this.category,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
    required this.status,
    required this.createdAt,
    this.syncedAt,
    this.notes,
  });

  final String id;
  final String userId;
  final HabitCategory category;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMinutes;
  final TimerSessionStatus status;
  final DateTime createdAt;
  final DateTime? syncedAt;
  final String? notes;

  TimerSession copyWith({
    DateTime? endTime,
    int? durationMinutes,
    TimerSessionStatus? status,
    DateTime? syncedAt,
    String? notes,
  }) {
    return TimerSession(
      id: id,
      userId: userId,
      category: category,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      createdAt: createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'category': category.id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  factory TimerSession.fromMap(Map<String, dynamic> map) {
    return TimerSession(
      id: map['id'] as String,
      userId: map['userId'] as String,
      category: HabitCategoryX.fromId(map['category'] as String),
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime'] as String) : null,
      durationMinutes: map['durationMinutes'] != null ? (map['durationMinutes'] as num).toInt() : null,
      status: TimerSessionStatus.values.byName(map['status'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      syncedAt: map['syncedAt'] != null ? DateTime.parse(map['syncedAt'] as String) : null,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'category': category.id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  factory TimerSession.fromDbMap(Map<String, dynamic> map) {
    return TimerSession(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      category: HabitCategoryX.fromId(map['category'] as String),
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time'] as String) : null,
      durationMinutes: map['duration_minutes'] != null ? (map['duration_minutes'] as num).toInt() : null,
      status: TimerSessionStatus.values.byName(map['status'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      syncedAt: map['synced_at'] != null ? DateTime.parse(map['synced_at'] as String) : null,
      notes: map['notes'] as String?,
    );
  }
}
