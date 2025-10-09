import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/algorithm_config.dart';
import '../services/algorithm_config_service.dart';
import '../services/algorithm_service.dart';
import 'minutes_provider.dart';

final algorithmConfigServiceProvider = Provider<AlgorithmConfigService>((ref) {
  final service = AlgorithmConfigService();
  ref.onDispose(service.dispose);
  
  // Enable hot reload in debug mode
  service.enableHotReload();
  
  return service;
});

final algorithmConfigProvider = FutureProvider<AlgorithmConfig>((ref) async {
  final service = ref.read(algorithmConfigServiceProvider);
  final config = await service.loadConfig();
  // Remove the infinite loop by not invalidating self
  // The config stream should be handled differently to avoid circular dependencies
  return config;
});

final algorithmServiceProvider = Provider<AlgorithmService>((ref) {
  final configAsync = ref.watch(algorithmConfigProvider);
  return configAsync.when(
    data: (config) => AlgorithmService(config: config),
    loading: () => AlgorithmService(config: _fallbackConfig()),
    error: (_, __) => AlgorithmService(config: _fallbackConfig()),
  );
});

final algorithmResultProvider = Provider<AlgorithmResult>((ref) {
  final service = ref.watch(algorithmServiceProvider);
  final minutesByCategory = ref.watch(minutesByCategoryProvider);
  return service.calculate(minutesByCategory: minutesByCategory);
});

AlgorithmConfig _fallbackConfig() {
  return _fallback;
}

final AlgorithmConfig _fallback = AlgorithmConfig(
  version: '0.0.0-loading',
  updatedAt: DateTime.now(),
  powerPlus: PowerPlusConfig(
    bonusMinutes: 30,
    requiredGoals: 3,
    goals: const {
      'sleep': 420,
      'exercise': 45,
      'outdoor': 30,
      'productive': 120,
    },
  ),
  categories: {
    'sleep': CategoryConfig(
      label: 'Sleep',
      minutesPerHour: 25,
      maxMinutes: 540,
    ),
    'exercise': CategoryConfig(
      label: 'Exercise',
      minutesPerHour: 20,
      maxMinutes: 120,
    ),
    'outdoor': CategoryConfig(
      label: 'Outdoor',
      minutesPerHour: 15,
      maxMinutes: 120,
    ),
    'productive': CategoryConfig(
      label: 'Productive',
      minutesPerHour: 10,
      maxMinutes: 240,
    ),
  },
  dailyCaps: DailyCaps(
    baseMinutes: 120,
    powerPlusMinutes: 150,
  ),
);
