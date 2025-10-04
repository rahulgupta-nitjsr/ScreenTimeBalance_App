// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_reset_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailyResetCheckHash() => r'0d22d67125222e552d71c96e4b253f575042b210';

/// Provider that automatically checks for daily reset when accessed
///
/// Copied from [dailyResetCheck].
@ProviderFor(dailyResetCheck)
final dailyResetCheckProvider = AutoDisposeProvider<bool>.internal(
  dailyResetCheck,
  name: r'dailyResetCheckProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dailyResetCheckHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyResetCheckRef = AutoDisposeProviderRef<bool>;
String _$currentDayHash() => r'940d8e4f7003aed254a63aecb0d5fe92386fbb55';

/// Provider to track the current day for daily reset logic
///
/// Copied from [CurrentDay].
@ProviderFor(CurrentDay)
final currentDayProvider =
    AutoDisposeNotifierProvider<CurrentDay, DateTime>.internal(
  CurrentDay.new,
  name: r'currentDayProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentDayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentDay = AutoDisposeNotifier<DateTime>;
String _$powerModeAchievedTodayHash() =>
    r'36b70d76c68791bf8724e7b4fba574f5f37dd175';

/// Provider to track if POWER+ Mode has been achieved today
///
/// Copied from [PowerModeAchievedToday].
@ProviderFor(PowerModeAchievedToday)
final powerModeAchievedTodayProvider =
    AutoDisposeNotifierProvider<PowerModeAchievedToday, bool>.internal(
  PowerModeAchievedToday.new,
  name: r'powerModeAchievedTodayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$powerModeAchievedTodayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PowerModeAchievedToday = AutoDisposeNotifier<bool>;
String _$dailyCelebrationShownHash() =>
    r'31c30a70b6dbabf0ed71f065556a8557b7855863';

/// Provider to track daily celebration shown status
///
/// Copied from [DailyCelebrationShown].
@ProviderFor(DailyCelebrationShown)
final dailyCelebrationShownProvider =
    AutoDisposeNotifierProvider<DailyCelebrationShown, bool>.internal(
  DailyCelebrationShown.new,
  name: r'dailyCelebrationShownProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dailyCelebrationShownHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DailyCelebrationShown = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
