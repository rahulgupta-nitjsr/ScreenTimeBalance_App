// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userSettingsHash() => r'387b6f2d7954f869daaac0c0dbea7aa7fb88533c';

/// Settings Provider
///
/// Manages user settings state with automatic persistence.
///
/// **Product Learning Note:**
/// Settings should be reactive - when user toggles a switch,
/// the change should save immediately and reflect across the app.
/// Stream provider for current user's settings
///
/// Copied from [userSettings].
@ProviderFor(userSettings)
final userSettingsProvider = AutoDisposeStreamProvider<UserSettings>.internal(
  userSettings,
  name: r'userSettingsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserSettingsRef = AutoDisposeStreamProviderRef<UserSettings>;
String _$settingsControllerHash() =>
    r'ad4dad732cfe6fdf203acdf254902c93e0147ad7';

/// Notifier for managing settings updates
///
/// Copied from [SettingsController].
@ProviderFor(SettingsController)
final settingsControllerProvider = AutoDisposeAsyncNotifierProvider<
    SettingsController, UserSettings?>.internal(
  SettingsController.new,
  name: r'settingsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SettingsController = AutoDisposeAsyncNotifier<UserSettings?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
