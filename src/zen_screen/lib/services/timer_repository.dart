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
    final session = TimerSession(
      id: _uuid.v4(),
      userId: userId,
      category: category,
      startTime: startTime ?? DateTime.now(),
      status: TimerSessionStatus.running,
      createdAt: DateTime.now(),
    );
    await _database.insert(_table, session.toDbMap());
    return session;
  }

  Future<TimerSession?> getActiveSession(String userId) async {
    _validateUser(userId);
    final rows = await _database.query(
      _table,
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, TimerSessionStatus.running.name],
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
    final updated = session.copyWith(
      status: status,
      endTime: endTime ?? DateTime.now(),
      durationMinutes: durationMinutes,
      notes: notes,
    );
    await _database.insert(_table, updated.toDbMap());
    return updated;
  }

  TimerSession _fromDbMap(Map<String, dynamic> map) => TimerSession.fromDbMap(map);

  void _validateUser(String userId) {
    if (userId.isEmpty) {
      throw ArgumentError('userId is required');
    }
  }
}
