import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/undo_service.dart';
import 'repository_providers.dart';
import 'algorithm_provider.dart';

/// Provider for undo service
/// 
/// **Product Learning:**
/// Undo is such a critical feature that it deserves its own provider.
/// This makes it easy to access from anywhere in the app and ensures
/// we're using a single instance.
final undoServiceProvider = Provider<UndoService>((ref) {
  final habitRepository = ref.watch(dailyHabitRepositoryProvider);
  final auditRepository = ref.watch(auditRepositoryProvider);
  final algorithmService = ref.watch(algorithmServiceProvider);

  return UndoService(
    habitRepository: habitRepository,
    auditRepository: auditRepository,
    algorithmService: algorithmService,
  );
});

