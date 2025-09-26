import 'package:uuid/uuid.dart';

import '../models/audit_event.dart';
import 'database_service.dart';

class AuditRepository {
  AuditRepository({DatabaseService? databaseService})
      : _database = databaseService ?? DatabaseService.instance;

  final DatabaseService _database;
  final _uuid = const Uuid();

  static const _table = 'audit_events';

  Future<AuditEvent> logEvent(AuditEvent event) async {
    final stored = event.ensureId(() => _uuid.v4()).ensureTimestamp();
    await _database.insert(_table, stored.toDbMap());
    return stored;
  }

  Future<List<AuditEvent>> listEvents({
    required String userId,
    DateTime? start,
    DateTime? end,
  }) async {
    final whereClauses = ['user_id = ?'];
    final args = <Object?>[userId];

    if (start != null) {
      whereClauses.add('target_date >= ?');
      args.add(start.toIso8601String());
    }
    if (end != null) {
      whereClauses.add('target_date <= ?');
      args.add(end.toIso8601String());
    }

    final rows = await _database.query(
      _table,
      where: whereClauses.join(' AND '),
      whereArgs: args,
      orderBy: 'target_date DESC, created_at DESC',
    );

    return rows.map(AuditEvent.fromDbMap).toList();
  }
}


