// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$navigationIndexHash() => r'd414893e1ca6a80fb2253812d81d3fbffa99ea74';

/// Current navigation index for bottom navigation
///
/// Copied from [NavigationIndex].
@ProviderFor(NavigationIndex)
final navigationIndexProvider =
    AutoDisposeNotifierProvider<NavigationIndex, int>.internal(
  NavigationIndex.new,
  name: r'navigationIndexProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$navigationIndexHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NavigationIndex = AutoDisposeNotifier<int>;
String _$navigationHistoryHash() => r'b19bdae4d599984fbf4d9133d5b56b37318fb08d';

/// Navigation history for back button functionality
///
/// Copied from [NavigationHistory].
@ProviderFor(NavigationHistory)
final navigationHistoryProvider =
    AutoDisposeNotifierProvider<NavigationHistory, List<String>>.internal(
  NavigationHistory.new,
  name: r'navigationHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$navigationHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NavigationHistory = AutoDisposeNotifier<List<String>>;
String _$appLifecycleHash() => r'3e0e467c88d560c15f8381d6f7665d28f57c093e';

/// See also [AppLifecycle].
@ProviderFor(AppLifecycle)
final appLifecycleProvider =
    AutoDisposeNotifierProvider<AppLifecycle, AppLifecycleState>.internal(
  AppLifecycle.new,
  name: r'appLifecycleProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appLifecycleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppLifecycle = AutoDisposeNotifier<AppLifecycleState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
