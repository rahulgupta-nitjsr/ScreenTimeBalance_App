/// User Settings Model
/// 
/// Stores user preferences for notifications and app behavior.
/// 
/// **Product Learning Note:**
/// Settings should be simple, predictable, and persistent.
/// Each setting should have a clear purpose and default value.
class UserSettings {
  UserSettings({
    required this.userId,
    this.dailyReminders = true,
    this.powerModeAlerts = true,
    this.dailyStreakReminders = false,
    this.weeklyReports = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String userId;
  final bool dailyReminders;
  final bool powerModeAlerts;
  final bool dailyStreakReminders;
  final bool weeklyReports;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Create a copy with updated values
  UserSettings copyWith({
    bool? dailyReminders,
    bool? powerModeAlerts,
    bool? dailyStreakReminders,
    bool? weeklyReports,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      userId: userId,
      dailyReminders: dailyReminders ?? this.dailyReminders,
      powerModeAlerts: powerModeAlerts ?? this.powerModeAlerts,
      dailyStreakReminders: dailyStreakReminders ?? this.dailyStreakReminders,
      weeklyReports: weeklyReports ?? this.weeklyReports,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toDbMap() {
    return {
      'user_id': userId,
      'daily_reminders': dailyReminders ? 1 : 0,
      'power_mode_alerts': powerModeAlerts ? 1 : 0,
      'daily_streak_reminders': dailyStreakReminders ? 1 : 0,
      'weekly_reports': weeklyReports ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from database map
  factory UserSettings.fromDbMap(Map<String, dynamic> map) {
    return UserSettings(
      userId: map['user_id'] as String,
      dailyReminders: (map['daily_reminders'] as int) == 1,
      powerModeAlerts: (map['power_mode_alerts'] as int) == 1,
      dailyStreakReminders: (map['daily_streak_reminders'] as int) == 1,
      weeklyReports: (map['weekly_reports'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'dailyReminders': dailyReminders,
      'powerModeAlerts': powerModeAlerts,
      'dailyStreakReminders': dailyStreakReminders,
      'weeklyReports': weeklyReports,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Create from Firestore document
  factory UserSettings.fromFirestore(Map<String, dynamic> data) {
    return UserSettings(
      userId: data['userId'] as String,
      dailyReminders: data['dailyReminders'] as bool? ?? true,
      powerModeAlerts: data['powerModeAlerts'] as bool? ?? true,
      dailyStreakReminders: data['dailyStreakReminders'] as bool? ?? false,
      weeklyReports: data['weeklyReports'] as bool? ?? false,
      createdAt: _convertTimestamp(data['createdAt']),
      updatedAt: _convertTimestamp(data['updatedAt']),
    );
  }

  static DateTime _convertTimestamp(dynamic timestamp) {
    if (timestamp is DateTime) {
      return timestamp;
    } else if (timestamp != null) {
      // Handle Firestore Timestamp
      return timestamp.toDate();
    } else {
      return DateTime.now();
    }
  }
}

