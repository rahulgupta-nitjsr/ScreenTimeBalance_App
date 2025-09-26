import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zen_screen/models/audit_event.dart';
import 'package:zen_screen/models/habit_category.dart';
import 'package:zen_screen/models/timer_session.dart';
import 'package:zen_screen/models/user_profile.dart';
import 'package:zen_screen/services/audit_repository.dart';
import 'package:zen_screen/services/daily_habit_repository.dart';
import 'package:zen_screen/services/database_service.dart';
import 'package:zen_screen/services/timer_repository.dart';
import 'package:zen_screen/services/user_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature 3: Local Database & Data Models', () {
    late DatabaseService databaseService;
    late UserRepository userRepository;
    late DailyHabitRepository habitRepository;
    late TimerRepository timerRepository;
    late AuditRepository auditRepository;
    late String dbPath;

    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      final databasesPath = await databaseFactory.getDatabasesPath();
      dbPath = p.join(databasesPath, 'zen_screen_test.db');
      
      // Clean up any existing test database
      try {
        await databaseFactory.deleteDatabase(dbPath);
      } catch (e) {
        // Database might not exist, that's fine
      }

      databaseService = DatabaseService.instance;
      userRepository = UserRepository(databaseService: databaseService);
      habitRepository = DailyHabitRepository(databaseService: databaseService);
      timerRepository = TimerRepository(databaseService: databaseService);
      auditRepository = AuditRepository(databaseService: databaseService);

      // Initialize database with a fresh connection
      await databaseService.database;
    });

    tearDown(() async {
      try {
        final db = await databaseService.database;
        await db.close();
      } catch (e) {
        // Database might already be closed
      }
      try {
        await databaseFactory.deleteDatabase(dbPath);
      } catch (e) {
        // Database might not exist
      }
    });

    test('TC021 & TC022: User model creation and validation', () async {
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

      final duplicate = profile.copyWith(displayName: 'Duplicate User');
      await userRepository.upsert(duplicate);
      final byEmail = await userRepository.getByEmail('test@example.com');
      expect(byEmail, isNotNull);
      expect(byEmail!.displayName, 'Duplicate User');
    });

    test('TC023 & TC027-029: DailyHabitEntry CRUD operations', () async {
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

      final updated = await habitRepository.upsertEntry(
        userId: userId,
        date: DateTime(2025, 1, 1),
        minutesByCategory: {
          HabitCategory.sleep: 500,
          HabitCategory.exercise: 60,
          HabitCategory.outdoor: 45,
          HabitCategory.productive: 90,
        },
        earnedScreenTime: 160,
        usedScreenTime: 40,
        powerModeUnlocked: true,
        algorithmVersion: '1.0.1',
      );
      expect(updated.id, entry.id);
      expect(updated.minutesByCategory[HabitCategory.sleep], 500);

      final range = await habitRepository.getEntriesWithinRange(
        userId: userId,
        start: DateTime(2024, 12, 31),
        end: DateTime(2025, 1, 2),
      );
      expect(range, isNotEmpty);

      final deleted = await habitRepository.deleteEntry(id: entry.id);
      expect(deleted, 1);
      final afterDelete = await habitRepository.getEntry(userId: userId, date: DateTime(2025, 1, 1));
      expect(afterDelete, isNull);
    });

    test('TC024 & TC027-029: TimerSession CRUD operations', () async {
      const userId = 'user-3';
      await userRepository.upsert(UserProfile(
        id: userId,
        email: 'user3@example.com',
        displayName: 'User Three',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final session = await timerRepository.startSession(
        userId: userId,
        category: HabitCategory.exercise,
        startTime: DateTime(2025, 1, 2, 8, 0),
      );
      expect(session.status, TimerSessionStatus.running);

      final active = await timerRepository.getActiveSession(userId);
      expect(active, isNotNull);
      expect(active!.id, session.id);

      final ended = await timerRepository.endSession(
        session: session,
        status: TimerSessionStatus.completed,
        endTime: DateTime(2025, 1, 2, 8, 45),
        durationMinutes: 45,
        notes: 'Morning workout',
      );
      expect(ended.status, TimerSessionStatus.completed);
      expect(ended.durationMinutes, 45);
    });

    test('TC025: AuditEvent logging', () async {
      const userId = 'user-4';
      await userRepository.upsert(UserProfile(
        id: userId,
        email: 'user4@example.com',
        displayName: 'User Four',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final event = AuditEvent(
        id: '',
        userId: userId,
        eventType: 'habit_edit',
        targetDate: DateTime(2025, 1, 3),
        category: HabitCategory.sleep.id,
        oldValue: 420,
        newValue: 480,
        reason: 'Correcting manual entry',
        createdAt: null,
        metadata: {'source': 'manual', 'editor': 'user'},
      );

      final logged = await auditRepository.logEvent(event);
      expect(logged.id, isNotEmpty);
      expect(logged.createdAt, isNotNull);

      final events = await auditRepository.listEvents(userId: userId);
      expect(events, hasLength(1));
      expect(events.first.metadata?['source'], 'manual');
    });

    test('TC026 & TC030: Database creation and migration', () async {
      final db = await databaseService.database;
      final tables = await db.rawQuery('SELECT name FROM sqlite_master WHERE type = "table"');
      final tableNames = tables.map((row) => row['name']).toSet();
      expect(tableNames.contains('users'), isTrue);
      expect(tableNames.contains('daily_habit_entries'), isTrue);
      expect(tableNames.contains('timer_sessions'), isTrue);
      expect(tableNames.contains('audit_events'), isTrue);

      await db.close();

      final migratedDb = await openDatabase(dbPath, version: 3, onUpgrade: (db, oldVersion, newVersion) async {
        expect(oldVersion <= newVersion, isTrue);
      });
      await migratedDb.close();
    });

    test('TC033 & TC039: Validation rules', () async {
      const userId = 'user-5';
      await userRepository.upsert(UserProfile(
        id: userId,
        email: 'user5@example.com',
        displayName: 'User Five',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      expect(
        () => habitRepository.upsertEntry(
          userId: userId,
          date: DateTime.now(),
          minutesByCategory: {
            HabitCategory.sleep: -10,
          },
          earnedScreenTime: 0,
          usedScreenTime: 0,
          powerModeUnlocked: false,
          algorithmVersion: '1.0.0',
        ),
        throwsArgumentError,
      );

      final session = await timerRepository.startSession(
        userId: userId,
        category: HabitCategory.productive,
      );

      expect(
        () => timerRepository.endSession(
          session: session,
          status: TimerSessionStatus.completed,
          durationMinutes: -5,
        ),
        throwsArgumentError,
      );
    });
  });
}


