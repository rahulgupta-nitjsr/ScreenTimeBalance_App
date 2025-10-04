import '../models/user_settings.dart';
import 'platform_database_service.dart';

/// Settings Repository
/// 
/// Manages CRUD operations for user settings.
/// 
/// **Product Learning Note:**
/// Settings should persist locally first (fast), then sync to cloud (reliable).
/// This gives immediate feedback while ensuring data isn't lost.
class SettingsRepository {
  SettingsRepository({PlatformDatabaseService? databaseService})
      : _database = databaseService ?? PlatformDatabaseService.instance;

  final PlatformDatabaseService _database;
  static const _table = 'user_settings';

  /// Get settings for a user (creates default if doesn't exist)
  Future<UserSettings> getSettings(String userId) async {
    final rows = await _database.query(
      _table,
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (rows.isEmpty) {
      // Create default settings
      final defaultSettings = UserSettings(userId: userId);
      await upsert(defaultSettings);
      return defaultSettings;
    }

    return UserSettings.fromDbMap(rows.first);
  }

  /// Save or update settings
  Future<void> upsert(UserSettings settings) async {
    await _database.insert(_table, settings.toDbMap());
  }

  /// Update a specific setting
  Future<void> updateSetting(
    String userId,
    String settingKey,
    bool value,
  ) async {
    final current = await getSettings(userId);
    final updated = _updateSettingByKey(current, settingKey, value);
    await upsert(updated);
  }

  /// Helper to update setting by key
  UserSettings _updateSettingByKey(
    UserSettings settings,
    String key,
    bool value,
  ) {
    switch (key) {
      case 'dailyReminders':
        return settings.copyWith(dailyReminders: value);
      case 'powerModeAlerts':
        return settings.copyWith(powerModeAlerts: value);
      case 'dailyStreakReminders':
        return settings.copyWith(dailyStreakReminders: value);
      case 'weeklyReports':
        return settings.copyWith(weeklyReports: value);
      default:
        return settings;
    }
  }

  /// Delete settings for a user
  Future<int> delete(String userId) {
    return _database.delete(
      _table,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Check if settings exist for a user
  Future<bool> exists(String userId) async {
    final rows = await _database.query(
      _table,
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}

