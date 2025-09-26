import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zen_screen/models/timer_session.dart';
import 'package:zen_screen/models/habit_category.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature 3: Simple Test', () {
    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    test('TC021: TimerSessionStatus enum works', () {
      expect(TimerSessionStatus.running, isA<TimerSessionStatus>());
      expect(TimerSessionStatus.completed, isA<TimerSessionStatus>());
      expect(TimerSessionStatus.cancelled, isA<TimerSessionStatus>());
    });

    test('TC022: TimerSession creation', () {
      final session = TimerSession(
        id: 'test-1',
        userId: 'user-1',
        category: HabitCategory.exercise,
        startTime: DateTime.now(),
        status: TimerSessionStatus.running,
        createdAt: DateTime.now(),
      );
      
      expect(session.id, 'test-1');
      expect(session.status, TimerSessionStatus.running);
      expect(session.category, HabitCategory.exercise);
    });
  });
}
