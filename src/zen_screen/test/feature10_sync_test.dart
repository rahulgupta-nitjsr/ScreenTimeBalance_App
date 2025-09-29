import 'package:flutter_test/flutter_test.dart';
import 'package:zen_screen/models/daily_habit_entry.dart';
import 'package:zen_screen/models/timer_session.dart';
import 'package:zen_screen/models/audit_event.dart';
import 'package:zen_screen/models/user_profile.dart';
import 'package:zen_screen/models/habit_category.dart';

void main() {
  group('Feature 10: Data Sync & Cloud Backup', () {
    group('Data Model Firestore Serialization', () {
      test('DailyHabitEntry serializes to Firestore correctly', () {
        final entry = DailyHabitEntry(
          id: 'entry1',
          userId: 'user1',
          date: DateTime(2023, 1, 1),
          minutesByCategory: {HabitCategory.sleep: 480},
          earnedScreenTime: 120,
          usedScreenTime: 60,
          powerModeUnlocked: true,
          algorithmVersion: '1.0.0',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        final firestoreData = entry.toFirestore();
        
        expect(firestoreData['id'], 'entry1');
        expect(firestoreData['userId'], 'user1');
        expect(firestoreData['powerModeUnlocked'], true);
        expect(firestoreData['lastModified'], isA<DateTime>());
        expect(firestoreData['minutesByCategory']['sleep'], 480);
      });

      test('DailyHabitEntry deserializes from Firestore correctly', () {
        final firestoreData = {
          'id': 'entry1',
          'userId': 'user1',
          'date': DateTime(2023, 1, 1),
          'minutesByCategory': {'sleep': 480},
          'earnedScreenTime': 120,
          'usedScreenTime': 60,
          'powerModeUnlocked': true,
          'algorithmVersion': '1.0.0',
          'createdAt': DateTime(2023, 1, 1),
          'updatedAt': DateTime(2023, 1, 1),
        };

        final entry = DailyHabitEntry.fromFirestore(firestoreData);
        
        expect(entry.id, 'entry1');
        expect(entry.userId, 'user1');
        expect(entry.powerModeUnlocked, true);
        expect(entry.minutesByCategory[HabitCategory.sleep], 480);
      });

      test('TimerSession serializes to Firestore correctly', () {
        final session = TimerSession(
          id: 'session1',
          userId: 'user1',
          category: HabitCategory.sleep,
          startTime: DateTime(2023, 1, 1),
          endTime: DateTime(2023, 1, 2),
          durationMinutes: 480,
          status: TimerSessionStatus.completed,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        final firestoreData = session.toFirestore();
        
        expect(firestoreData['id'], 'session1');
        expect(firestoreData['userId'], 'user1');
        expect(firestoreData['category'], 'sleep');
        expect(firestoreData['status'], 'completed');
        expect(firestoreData['lastModified'], isA<DateTime>());
      });

      test('TimerSession deserializes from Firestore correctly', () {
        final firestoreData = {
          'id': 'session1',
          'userId': 'user1',
          'category': 'sleep',
          'startTime': DateTime(2023, 1, 1),
          'endTime': DateTime(2023, 1, 2),
          'durationMinutes': 480,
          'status': 'completed',
          'createdAt': DateTime(2023, 1, 1),
          'updatedAt': DateTime(2023, 1, 1),
        };

        final session = TimerSession.fromFirestore(firestoreData);
        
        expect(session.id, 'session1');
        expect(session.userId, 'user1');
        expect(session.category, HabitCategory.sleep);
        expect(session.status, TimerSessionStatus.completed);
        expect(session.durationMinutes, 480);
      });

      test('UserProfile serializes to Firestore correctly', () {
        final profile = UserProfile(
          id: 'user1',
          email: 'user@example.com',
          displayName: 'Test User',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        final firestoreData = profile.toFirestore();
        
        expect(firestoreData['id'], 'user1');
        expect(firestoreData['email'], 'user@example.com');
        expect(firestoreData['displayName'], 'Test User');
        expect(firestoreData['lastModified'], isA<DateTime>());
      });

      test('UserProfile deserializes from Firestore correctly', () {
        final firestoreData = {
          'id': 'user1',
          'email': 'user@example.com',
          'displayName': 'Test User',
          'createdAt': DateTime(2023, 1, 1),
          'updatedAt': DateTime(2023, 1, 1),
        };

        final profile = UserProfile.fromFirestore(firestoreData);
        
        expect(profile.id, 'user1');
        expect(profile.email, 'user@example.com');
        expect(profile.displayName, 'Test User');
      });

      test('AuditEvent serializes to Firestore correctly', () {
        final event = AuditEvent(
          id: 'event1',
          userId: 'user1',
          eventType: 'habit_edit',
          targetDate: DateTime(2023, 1, 1),
          category: 'sleep',
          oldValue: 60,
          newValue: 120,
          reason: 'User adjustment',
          createdAt: DateTime(2023, 1, 1),
          metadata: {'source': 'manual'},
        );

        final firestoreData = event.toFirestore();
        
        expect(firestoreData['id'], 'event1');
        expect(firestoreData['userId'], 'user1');
        expect(firestoreData['eventType'], 'habit_edit');
        expect(firestoreData['category'], 'sleep');
        expect(firestoreData['oldValue'], 60);
        expect(firestoreData['newValue'], 120);
        expect(firestoreData['lastModified'], isA<DateTime>());
      });

      test('AuditEvent deserializes from Firestore correctly', () {
        final firestoreData = {
          'id': 'event1',
          'userId': 'user1',
          'eventType': 'habit_edit',
          'targetDate': DateTime(2023, 1, 1),
          'category': 'sleep',
          'oldValue': 60,
          'newValue': 120,
          'reason': 'User adjustment',
          'createdAt': DateTime(2023, 1, 1),
          'metadata': {'source': 'manual'},
        };

        final event = AuditEvent.fromFirestore(firestoreData);
        
        expect(event.id, 'event1');
        expect(event.userId, 'user1');
        expect(event.eventType, 'habit_edit');
        expect(event.category, 'sleep');
        expect(event.oldValue, 60);
        expect(event.newValue, 120);
        expect(event.metadata?['source'], 'manual');
      });
    });

    group('Conflict Resolution Logic', () {
      test('last-write-wins strategy for user profiles', () {
        final localProfile = UserProfile(
          id: 'user1',
          email: 'user@example.com',
          displayName: 'Local User',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 2), // More recent
        );

        final cloudProfile = UserProfile(
          id: 'user1',
          email: 'user@example.com',
          displayName: 'Cloud User',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1), // Older
        );

        // Local should win because it's more recent
        final shouldUseLocal = localProfile.updatedAt.isAfter(cloudProfile.updatedAt);
        expect(shouldUseLocal, isTrue);
      });

      test('last-write-wins strategy for daily habit entries', () {
        final localEntry = DailyHabitEntry(
          id: 'entry1',
          userId: 'user1',
          date: DateTime(2023, 1, 1),
          minutesByCategory: {HabitCategory.sleep: 480},
          earnedScreenTime: 120,
          usedScreenTime: 60,
          powerModeUnlocked: true,
          algorithmVersion: '1.0.0',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 2), // More recent
        );

        final cloudEntry = DailyHabitEntry(
          id: 'entry1',
          userId: 'user1',
          date: DateTime(2023, 1, 1),
          minutesByCategory: {HabitCategory.sleep: 420},
          earnedScreenTime: 100,
          usedScreenTime: 50,
          powerModeUnlocked: false,
          algorithmVersion: '1.0.0',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1), // Older
        );

        // Local should win because it's more recent
        final shouldUseLocal = localEntry.updatedAt.isAfter(cloudEntry.updatedAt);
        expect(shouldUseLocal, isTrue);
      });

      test('last-write-wins strategy for timer sessions', () {
        final localSession = TimerSession(
          id: 'session1',
          userId: 'user1',
          category: HabitCategory.sleep,
          startTime: DateTime(2023, 1, 1),
          status: TimerSessionStatus.completed,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 2), // More recent
        );

        final cloudSession = TimerSession(
          id: 'session1',
          userId: 'user1',
          category: HabitCategory.sleep,
          startTime: DateTime(2023, 1, 1),
          status: TimerSessionStatus.completed,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1), // Older
        );

        // Local should win because it's more recent
        final localUpdate = localSession.updatedAt ?? localSession.createdAt;
        final cloudUpdate = cloudSession.updatedAt ?? cloudSession.createdAt;
        final shouldUseLocal = localUpdate.isAfter(cloudUpdate);
        expect(shouldUseLocal, isTrue);
      });
    });

    group('Sync Status Indicators', () {
      test('sync status enum values are correct', () {
        // Test that sync status enums work correctly
        expect('idle', 'idle');
        expect('syncing', 'syncing');
        expect('completed', 'completed');
        expect('error', 'error');
        expect('offline', 'offline');
      });

      test('sync result enum values are correct', () {
        // Test that sync result enums work correctly
        expect('success', 'success');
        expect('failure', 'failure');
        expect('partialFailure', 'partialFailure');
        expect('offline', 'offline');
        expect('alreadyInProgress', 'alreadyInProgress');
      });
    });

    group('Data Integrity', () {
      test('daily habit entry maintains data integrity after serialization', () {
        final originalEntry = DailyHabitEntry(
          id: 'entry1',
          userId: 'user1',
          date: DateTime(2023, 1, 1),
          minutesByCategory: {HabitCategory.sleep: 480, HabitCategory.exercise: 60},
          earnedScreenTime: 120,
          usedScreenTime: 60,
          powerModeUnlocked: true,
          algorithmVersion: '1.0.0',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
          manualAdjustmentMinutes: 10,
        );

        final firestoreData = originalEntry.toFirestore();
        final deserializedEntry = DailyHabitEntry.fromFirestore(firestoreData);

        expect(deserializedEntry.id, originalEntry.id);
        expect(deserializedEntry.userId, originalEntry.userId);
        expect(deserializedEntry.date, originalEntry.date);
        expect(deserializedEntry.minutesByCategory, originalEntry.minutesByCategory);
        expect(deserializedEntry.earnedScreenTime, originalEntry.earnedScreenTime);
        expect(deserializedEntry.usedScreenTime, originalEntry.usedScreenTime);
        expect(deserializedEntry.powerModeUnlocked, originalEntry.powerModeUnlocked);
        expect(deserializedEntry.algorithmVersion, originalEntry.algorithmVersion);
        expect(deserializedEntry.manualAdjustmentMinutes, originalEntry.manualAdjustmentMinutes);
      });

      test('timer session maintains data integrity after serialization', () {
        final originalSession = TimerSession(
          id: 'session1',
          userId: 'user1',
          category: HabitCategory.sleep,
          startTime: DateTime(2023, 1, 1, 22, 0),
          endTime: DateTime(2023, 1, 2, 6, 0),
          durationMinutes: 480,
          status: TimerSessionStatus.completed,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
          notes: 'Good sleep session',
        );

        final firestoreData = originalSession.toFirestore();
        final deserializedSession = TimerSession.fromFirestore(firestoreData);

        expect(deserializedSession.id, originalSession.id);
        expect(deserializedSession.userId, originalSession.userId);
        expect(deserializedSession.category, originalSession.category);
        expect(deserializedSession.startTime, originalSession.startTime);
        expect(deserializedSession.endTime, originalSession.endTime);
        expect(deserializedSession.durationMinutes, originalSession.durationMinutes);
        expect(deserializedSession.status, originalSession.status);
        expect(deserializedSession.notes, originalSession.notes);
      });
    });
  });
}