import 'package:flutter_test/flutter_test.dart';
import 'package:zen_screen/models/user_profile.dart';
import 'package:zen_screen/models/habit_category.dart';
import 'package:zen_screen/models/daily_habit_entry.dart';
import 'package:zen_screen/models/timer_session.dart';
import 'package:zen_screen/models/audit_event.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature 3: Local Database & Data Models - Simple Validation', () {
    test('TC021: UserProfile model creation and validation', () {
      final profile = UserProfile(
        id: 'user-1',
        email: 'test@example.com',
        displayName: 'Test User',
        avatarUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(profile.id, 'user-1');
      expect(profile.email, 'test@example.com');
      expect(profile.displayName, 'Test User');
      expect(profile.avatarUrl, isNull);
      expect(profile.createdAt, isNotNull);
      expect(profile.updatedAt, isNotNull);
    });

    test('TC022: UserProfile copyWith functionality', () {
      final original = UserProfile(
        id: 'user-1',
        email: 'test@example.com',
        displayName: 'Test User',
        avatarUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = original.copyWith(
        displayName: 'Updated User',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      expect(updated.id, original.id);
      expect(updated.email, original.email);
      expect(updated.displayName, 'Updated User');
      expect(updated.avatarUrl, 'https://example.com/avatar.jpg');
      expect(updated.createdAt, original.createdAt);
    });

    test('TC023: DailyHabitEntry model creation', () {
      final entry = DailyHabitEntry(
        id: 'entry-1',
        userId: 'user-1',
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
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(entry.id, 'entry-1');
      expect(entry.userId, 'user-1');
      expect(entry.minutesByCategory[HabitCategory.sleep], 480);
      expect(entry.earnedScreenTime, 150);
      expect(entry.algorithmVersion, '1.0.0');
    });

    test('TC024: TimerSession model creation', () {
      final session = TimerSession(
        id: 'session-1',
        userId: 'user-1',
        category: HabitCategory.exercise,
        startTime: DateTime.now(),
        status: TimerSessionStatus.running,
        createdAt: DateTime.now(),
      );

      expect(session.id, 'session-1');
      expect(session.userId, 'user-1');
      expect(session.category, HabitCategory.exercise);
      expect(session.status, TimerSessionStatus.running);
      expect(session.startTime, isNotNull);
    });

    test('TC025: AuditEvent model creation', () {
      final event = AuditEvent(
        id: 'audit-1',
        userId: 'user-1',
        eventType: 'habit_edit',
        targetDate: DateTime(2025, 1, 1),
        category: HabitCategory.sleep.id,
        oldValue: 420,
        newValue: 480,
        reason: 'Correcting manual entry',
        createdAt: DateTime.now(),
        metadata: {'source': 'manual', 'editor': 'user'},
      );

      expect(event.id, 'audit-1');
      expect(event.userId, 'user-1');
      expect(event.eventType, 'habit_edit');
      expect(event.oldValue, 420);
      expect(event.newValue, 480);
      expect(event.metadata?['source'], 'manual');
    });

    test('TC026: Model serialization to database format', () {
      final profile = UserProfile(
        id: 'user-1',
        email: 'test@example.com',
        displayName: 'Test User',
        avatarUrl: null,
        createdAt: DateTime(2025, 1, 1, 10, 0),
        updatedAt: DateTime(2025, 1, 1, 10, 0),
      );

      final dbMap = profile.toDbMap();
      expect(dbMap['id'], 'user-1');
      expect(dbMap['email'], 'test@example.com');
      expect(dbMap['display_name'], 'Test User');
      expect(dbMap['avatar_url'], isNull);
      expect(dbMap['created_at'], isNotNull);
      expect(dbMap['updated_at'], isNotNull);
    });

    test('TC027: Model deserialization from database format', () {
      final dbMap = {
        'id': 'user-1',
        'email': 'test@example.com',
        'display_name': 'Test User',
        'avatar_url': null,
        'created_at': DateTime(2025, 1, 1, 10, 0).toIso8601String(),
        'updated_at': DateTime(2025, 1, 1, 10, 0).toIso8601String(),
      };

      final profile = UserProfile.fromDbMap(dbMap);
      expect(profile.id, 'user-1');
      expect(profile.email, 'test@example.com');
      expect(profile.displayName, 'Test User');
      expect(profile.avatarUrl, isNull);
    });

    test('TC028: HabitCategory enum values', () {
      expect(HabitCategory.sleep.id, 'sleep');
      expect(HabitCategory.exercise.id, 'exercise');
      expect(HabitCategory.outdoor.id, 'outdoor');
      expect(HabitCategory.productive.id, 'productive');
    });

    test('TC029: TimerSessionStatus enum values', () {
      expect(TimerSessionStatus.running.name, 'running');
      expect(TimerSessionStatus.completed.name, 'completed');
      expect(TimerSessionStatus.cancelled.name, 'cancelled');
    });

    test('TC030: Model validation rules', () {
      // Test that negative values are handled properly
      expect(() {
        DailyHabitEntry(
          id: 'entry-1',
          userId: 'user-1',
          date: DateTime(2025, 1, 1),
          minutesByCategory: {
            HabitCategory.sleep: -10, // This should be handled by validation
          },
          earnedScreenTime: 0,
          usedScreenTime: 0,
          powerModeUnlocked: false,
          algorithmVersion: '1.0.0',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }, returnsNormally); // The model should accept it, validation happens in repository
    });
  });
}
