import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zen_screen/models/user_profile.dart';
import 'package:zen_screen/models/habit_category.dart';
import 'package:zen_screen/services/database_service.dart';
import 'package:zen_screen/services/user_repository.dart';
import 'package:zen_screen/services/daily_habit_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature 3: Local Database & Data Models - Minimal Test', () {
    late DatabaseService databaseService;
    late UserRepository userRepository;
    late DailyHabitRepository habitRepository;

    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      databaseService = DatabaseService.instance;
      userRepository = UserRepository(databaseService: databaseService);
      habitRepository = DailyHabitRepository(databaseService: databaseService);
      await databaseService.database; // Trigger database initialization
    });

    test('TC021: User model creation and validation', () async {
      final profile = UserProfile(
        id: 'user-1',
        email: 'test@example.com',
        displayName: 'Test User',
        avatarUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await userRepository.upsert(profile);
      final fetched = await userRepository.getById('user-1');
      expect(fetched, isNotNull);
      expect(fetched!.email, 'test@example.com');
    });

    test('TC023: DailyHabitEntry CRUD operations', () async {
      const userId = 'user-2';
      await userRepository.upsert(UserProfile(
        id: userId,
        email: 'user2@example.com',
        displayName: 'User Two',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final entry = await habitRepository.upsertEntry(
        userId: userId,
        date: DateTime(2025, 1, 1),
        minutesByCategory: {
          HabitCategory.sleep: 480,
          HabitCategory.exercise: 45,
          HabitCategory.outdoor: 30,
          HabitCategory.productive: 120,
        },
        earnedScreenTime: 150,
        usedScreenTime: 30,
        powerModeUnlocked: true,
        algorithmVersion: '1.0.0',
      );

      final fetched = await habitRepository.getEntry(userId: userId, date: DateTime(2025, 1, 1));
      expect(fetched, isNotNull);
      expect(fetched!.earnedScreenTime, 150);
      expect(fetched.minutesByCategory[HabitCategory.exercise], 45);
    });

    test('TC026: Database creation', () async {
      final db = await databaseService.database;
      final tables = await db.rawQuery('SELECT name FROM sqlite_master WHERE type = "table"');
      final tableNames = tables.map((row) => row['name']).toSet();
      expect(tableNames.contains('users'), isTrue);
      expect(tableNames.contains('daily_habit_entries'), isTrue);
      expect(tableNames.contains('timer_sessions'), isTrue);
      expect(tableNames.contains('audit_events'), isTrue);
    });
  });
}
