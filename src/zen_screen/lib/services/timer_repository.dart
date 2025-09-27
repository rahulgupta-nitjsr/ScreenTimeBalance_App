import 'package:uuid/uuid.dart';

import '../models/habit_category.dart';
import '../models/timer_session.dart';
import 'database_service.dart';

class TimerRepository {
  TimerRepository({DatabaseService? databaseService})
      : _database = databaseService ?? DatabaseService.instance;

  final DatabaseService _database;
  final _uuid = const Uuid();

  static const _table = 'timer_sessions';

  Future<TimerSession> startSession({
    required String userId,
    required HabitCategory category,
    DateTime? startTime,
  }) async {
    _validateUser(userId);
    final now = DateTime.now();
    final session = TimerSession(
      id: _uuid.v4(),
      userId: userId,
      category: category,
      startTime: startTime ?? now,
      status: TimerSessionStatus.running,
      createdAt: now,
      updatedAt: now,
    );
    await _database.insert(_table, session.toDbMap());
    return session;
  }

  Future<TimerSession?> getActiveSession(String userId) async {
    _validateUser(userId);
    final rows = await _database.query(
      _table,
      where: 'user_id = ? AND status IN (?, ?)',
      whereArgs: [
        userId,
        TimerSessionStatus.running.name,
        TimerSessionStatus.paused.name,
      ],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromDbMap(rows.first);
  }

  Future<TimerSession> endSession({
    required TimerSession session,
    required TimerSessionStatus status,
    DateTime? endTime,
    int? durationMinutes,
    String? notes,
  }) async {
    if (durationMinutes != null && durationMinutes < 0) {
      throw ArgumentError('durationMinutes cannot be negative');
    }
    final now = DateTime.now();
    final updated = session.copyWith(
      status: status,
      endTime: endTime ?? DateTime.now(),
      durationMinutes: durationMinutes,
      updatedAt: now,
      notes: notes,
    );
    await _database.insert(_table, updated.toDbMap());
    return updated;
  }

  Future<void> updateStatus({
    required String sessionId,
    required TimerSessionStatus status,
    DateTime? timestamp,
    int? durationMinutes,
    String? notes,
  }) async {
    final now = timestamp ?? DateTime.now();
    final values = <String, Object?>{
      'status': status.name,
      'updated_at': now.toIso8601String(),
    };

    if (durationMinutes != null) {
      if (durationMinutes < 0) {
        throw ArgumentError('durationMinutes cannot be negative');
      }
      values['duration_minutes'] = durationMinutes;
    }

    if (notes != null) {
      values['notes'] = notes;
    }

    await _database.update(
      _table,
      values,
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  TimerSession _fromDbMap(Map<String, dynamic> map) => TimerSession.fromDbMap(map);

  void _validateUser(String userId) {
    if (userId.isEmpty) {
      throw ArgumentError('userId is required');
    }
  }
}
