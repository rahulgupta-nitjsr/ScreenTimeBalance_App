import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/habit_edit_service.dart';
import 'repository_providers.dart';
import 'algorithm_provider.dart';

/// Provider for habit edit service
/// 
/// **Product Learning:**
/// Providers centralize dependencies. Instead of passing services through
/// multiple widget constructors, we make them available anywhere in the widget tree.
final habitEditServiceProvider = Provider<HabitEditService>((ref) {
  return HabitEditService(
    habitRepository: ref.watch(dailyHabitRepositoryProvider),
    auditRepository: ref.watch(auditRepositoryProvider),
    algorithmService: ref.watch(algorithmServiceProvider),
  );
});

