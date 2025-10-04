import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_settings.dart';
import '../services/settings_repository.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

part 'settings_provider.g.dart';

/// Settings Provider
/// 
/// Manages user settings state with automatic persistence.
/// 
/// **Product Learning Note:**
/// Settings should be reactive - when user toggles a switch,
/// the change should save immediately and reflect across the app.

/// Stream provider for current user's settings
@riverpod
Stream<UserSettings> userSettings(UserSettingsRef ref) async* {
  final authState = ref.watch(authControllerProvider);
  
  if (authState is! Authenticated) {
    // Return default settings for unauthenticated users
    yield UserSettings(userId: 'guest');
    return;
  }
  
  final repository = ref.watch(settingsRepositoryProvider);
  final settings = await repository.getSettings(authState.user.id);
  
  yield settings;
}

/// Notifier for managing settings updates
@riverpod
class SettingsController extends _$SettingsController {
  @override
  FutureOr<UserSettings?> build() async {
    final authState = ref.watch(authControllerProvider);
    
    if (authState is! Authenticated) {
      return null;
    }
    
    final repository = ref.watch(settingsRepositoryProvider);
    return await repository.getSettings(authState.user.id);
  }

  /// Update a specific setting
  Future<void> updateSetting(String key, bool value) async {
    final authState = ref.read(authControllerProvider);
    
    if (authState is! Authenticated) return;
    
    final repository = ref.read(settingsRepositoryProvider);
    
    // Update in database
    await repository.updateSetting(authState.user.id, key, value);
    
    // Refresh state
    ref.invalidateSelf();
  }

  /// Update multiple settings at once
  Future<void> updateSettings(UserSettings settings) async {
    final authState = ref.read(authControllerProvider);
    
    if (authState is! Authenticated) return;
    
    final repository = ref.read(settingsRepositoryProvider);
    
    // Save to database
    await repository.upsert(settings);
    
    // Refresh state
    ref.invalidateSelf();
  }

  /// Reset settings to defaults
  Future<void> resetToDefaults() async {
    final authState = ref.read(authControllerProvider);
    
    if (authState is! Authenticated) return;
    
    final defaultSettings = UserSettings(userId: authState.user.id);
    await updateSettings(defaultSettings);
  }
}

