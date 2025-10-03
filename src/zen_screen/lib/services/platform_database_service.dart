import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

/// Platform-specific database service that uses SharedPreferences for web
/// and SQLite for mobile platforms
class PlatformDatabaseService {
  static PlatformDatabaseService? _instance;
  static PlatformDatabaseService get instance {
    _instance ??= PlatformDatabaseService._();
    return _instance!;
  }

  PlatformDatabaseService._();

  Database? _database;
  late final SharedPreferences _prefs;

  bool get _isWeb => kIsWeb;

  static const _dbName = 'zen_screen.db';
  static const _dbVersion = 3;

  Future<void> initialize() async {
    if (!_isWeb) {
      await _initSqlite();
    } else {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  Future<void> _initSqlite() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, _dbName);
    _database = await openDatabase(
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

  Future<void> insert(String table, Map<String, dynamic> values) async {
    if (_isWeb) {
      await _insertWeb(table, values);
    } else {
      await _database!.insert(
        table,
        values,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    if (_isWeb) {
      return _queryWeb(table, where: where, whereArgs: whereArgs, orderBy: orderBy, limit: limit);
    } else {
      return _database!.query(
        table,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
      );
    }
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    if (_isWeb) {
      return _updateWeb(table, values, where: where, whereArgs: whereArgs);
    } else {
      return _database!.update(
        table,
        values,
        where: where,
        whereArgs: whereArgs,
      );
    }
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    if (_isWeb) {
      return _deleteWeb(table, where: where, whereArgs: whereArgs);
    } else {
      return _database!.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
    }
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

  // Web-specific methods using SharedPreferences
  Future<void> _insertWeb(String table, Map<String, dynamic> values) async {
    final key = '${table}_${values['id'] ?? DateTime.now().millisecondsSinceEpoch}';
    await _prefs.setString(key, jsonEncode(values));
    
    // Update table index
    final indexKey = '${table}_index';
    final existingIndex = _prefs.getStringList(indexKey) ?? [];
    existingIndex.add(key);
    await _prefs.setStringList(indexKey, existingIndex);
  }

  Future<List<Map<String, dynamic>>> _queryWeb(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final indexKey = '${table}_index';
    final keys = _prefs.getStringList(indexKey) ?? [];
    
    List<Map<String, dynamic>> results = [];
    
    for (final key in keys) {
      final jsonString = _prefs.getString(key);
      if (jsonString != null) {
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        
        // Simple where clause matching (for basic cases)
        bool matches = true;
        if (where != null && whereArgs != null) {
          // This is a simplified implementation
          // For production, you'd want more sophisticated query parsing
          for (int i = 0; i < whereArgs.length; i++) {
            final placeholder = '?';
            if (where.contains(placeholder)) {
              final field = where.split(' ')[0]; // Simplified field extraction
              if (data[field] != whereArgs[i]) {
                matches = false;
                break;
              }
            }
          }
        }
        
        if (matches) {
          results.add(data);
        }
      }
    }
    
    // Simple ordering (for basic cases)
    if (orderBy != null) {
      final field = orderBy.replaceAll(' DESC', '').replaceAll(' ASC', '');
      final isDesc = orderBy.contains(' DESC');
      
      results.sort((a, b) {
        final aVal = a[field];
        final bVal = b[field];
        
        if (aVal is String && bVal is String) {
          return isDesc ? bVal.compareTo(aVal) : aVal.compareTo(bVal);
        } else if (aVal is num && bVal is num) {
          return isDesc ? bVal.compareTo(aVal) : aVal.compareTo(bVal);
        }
        return 0;
      });
    }
    
    // Apply limit
    if (limit != null && results.length > limit) {
      results = results.take(limit).toList();
    }
    
    return results;
  }

  Future<int> _updateWeb(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    // Simplified update - in production you'd want more sophisticated matching
    int updated = 0;
    
    if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
      final field = where.split(' ')[0]; // Simplified field extraction
      final value = whereArgs[0];
      
      final indexKey = '${table}_index';
      final keys = _prefs.getStringList(indexKey) ?? [];
      
      for (final key in keys) {
        final jsonString = _prefs.getString(key);
        if (jsonString != null) {
          final data = jsonDecode(jsonString) as Map<String, dynamic>;
          
          if (data[field] == value) {
            // Update the record
            data.addAll(values);
            await _prefs.setString(key, jsonEncode(data));
            updated++;
          }
        }
      }
    }
    
    return updated;
  }

  Future<int> _deleteWeb(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    int deleted = 0;
    
    if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
      final field = where.split(' ')[0]; // Simplified field extraction
      final value = whereArgs[0];
      
      final indexKey = '${table}_index';
      final keys = _prefs.getStringList(indexKey) ?? [];
      final keysToRemove = <String>[];
      
      for (final key in keys) {
        final jsonString = _prefs.getString(key);
        if (jsonString != null) {
          final data = jsonDecode(jsonString) as Map<String, dynamic>;
          
          if (data[field] == value) {
            await _prefs.remove(key);
            keysToRemove.add(key);
            deleted++;
          }
        }
      }
      
      // Update index
      final updatedKeys = keys.where((k) => !keysToRemove.contains(k)).toList();
      await _prefs.setStringList(indexKey, updatedKeys);
    }
    
    return deleted;
  }
}
