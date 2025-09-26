import '../models/user_profile.dart';
import 'database_service.dart';

class UserRepository {
  UserRepository({DatabaseService? databaseService})
      : _database = databaseService ?? DatabaseService.instance;

  final DatabaseService _database;
  static const _table = 'users';

  Future<void> upsert(UserProfile profile) async {
    await _database.insert(_table, profile.toDbMap());
  }

  Future<UserProfile?> getById(String id) async {
    final rows = await _database.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserProfile.fromDbMap(rows.first);
  }

  Future<UserProfile?> getByEmail(String email) async {
    final rows = await _database.query(
      _table,
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserProfile.fromDbMap(rows.first);
  }

  Future<List<UserProfile>> listAll() async {
    final rows = await _database.query(_table, orderBy: 'created_at DESC');
    return rows.map(UserProfile.fromDbMap).toList();
  }

  Future<int> delete(String id) {
    return _database.delete(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}


