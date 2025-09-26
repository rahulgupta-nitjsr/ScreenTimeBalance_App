import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/daily_habit_repository.dart';
import '../services/timer_repository.dart';

final currentUserIdProvider = Provider<String>((ref) => 'local-user');

final dailyHabitRepositoryProvider = Provider<DailyHabitRepository>((ref) {
  return DailyHabitRepository();
});

final timerRepositoryProvider = Provider<TimerRepository>((ref) {
  return TimerRepository();
});
