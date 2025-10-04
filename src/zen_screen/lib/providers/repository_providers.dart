import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/daily_habit_repository.dart';
import '../services/timer_repository.dart';
import '../services/audit_repository.dart';
import '../services/user_repository.dart';
import '../services/settings_repository.dart';
import '../services/sync_service.dart';
import '../services/firestore_service.dart';
import '../services/platform_database_service.dart';
import '../services/image_picker_service.dart';
import '../services/storage_service.dart';
import '../services/data_export_service.dart';
import 'auth_provider.dart';

final platformDatabaseProvider = Provider<PlatformDatabaseService>((ref) {
  return PlatformDatabaseService.instance;
});

final currentUserIdProvider = Provider<String>((ref) {
  final authState = ref.watch(authControllerProvider);
  if (authState is Authenticated) {
    return authState.user.id;
  }
  throw StateError('User not authenticated');
});

final dailyHabitRepositoryProvider = Provider<DailyHabitRepository>((ref) {
  return DailyHabitRepository();
});

final timerRepositoryProvider = Provider<TimerRepository>((ref) {
  return TimerRepository();
});

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final dataExportServiceProvider = Provider<DataExportService>((ref) {
  return DataExportService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return SyncService(
    firestoreService: ref.read(firestoreServiceProvider),
    dailyHabitRepository: ref.read(dailyHabitRepositoryProvider),
    timerRepository: ref.read(timerRepositoryProvider),
    auditRepository: ref.read(auditRepositoryProvider),
    userRepository: ref.read(userRepositoryProvider),
    userId: userId,
  );
});
