import 'dart:async';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Database? _database;
  static const _dbName = 'zen_screen.db';
  static const _dbVersion = 3;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, _dbName);
    return openDatabase(
      dbPath,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _migrate(db, oldVersion, newVersion);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        display_name TEXT NOT NULL,
        avatar_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_users_email ON users(email)
    ''');

    await db.execute('''
      CREATE TABLE daily_habit_entries (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        entry_date TEXT NOT NULL,
        minutes_sleep INTEGER NOT NULL,
        minutes_exercise INTEGER NOT NULL,
        minutes_outdoor INTEGER NOT NULL,
        minutes_productive INTEGER NOT NULL,
        earned_screen_time INTEGER NOT NULL,
        used_screen_time INTEGER NOT NULL,
        manual_adjustment_minutes INTEGER NOT NULL DEFAULT 0,
        power_mode_unlocked INTEGER NOT NULL,
        algorithm_version TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_daily_entry_date ON daily_habit_entries(entry_date)
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX idx_daily_user_unique ON daily_habit_entries(user_id, entry_date)
    ''');

    await db.execute('''
      CREATE INDEX idx_daily_user_date ON daily_habit_entries(user_id, entry_date)
    ''');

    await db.execute('''
      CREATE TABLE timer_sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        category TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT,
        duration_minutes INTEGER,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        synced_at TEXT,
        notes TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE audit_events (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        event_type TEXT NOT NULL,
        target_date TEXT NOT NULL,
        category TEXT,
        old_value INTEGER,
        new_value INTEGER,
        reason TEXT,
        created_at TEXT,
        metadata TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _migrate(Database db, int oldVersion, int newVersion) async {
    var version = oldVersion;

    while (version < newVersion) {
      switch (version) {
        case 1:
          await db.execute('''
            CREATE TABLE IF NOT EXISTS users (
              id TEXT PRIMARY KEY,
              email TEXT NOT NULL UNIQUE,
              display_name TEXT NOT NULL,
              avatar_url TEXT,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)
          ''');
          await db.execute('''
            CREATE INDEX IF NOT EXISTS idx_daily_user_date ON daily_habit_entries(user_id, entry_date)
          ''');
          await db.execute('''
            CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_user_unique ON daily_habit_entries(user_id, entry_date)
          ''');
          break;
        case 2:
          await db.execute('''
            ALTER TABLE timer_sessions ADD COLUMN updated_at TEXT
          ''');
          await db.execute('''
            ALTER TABLE daily_habit_entries ADD COLUMN manual_adjustment_minutes INTEGER NOT NULL DEFAULT 0
          ''');
          break;
      }
      version++;
    }
  }

  Future<void> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    await db.insert(
      table,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }
}
