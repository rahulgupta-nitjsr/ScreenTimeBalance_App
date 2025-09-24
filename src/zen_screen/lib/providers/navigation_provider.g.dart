// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$navigationIndexHash() => r'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

/// Current navigation index for bottom navigation
///
/// Copied from [NavigationIndex].
@ProviderFor(NavigationIndex)
final navigationIndexProvider = AutoDisposeNotifierProvider<NavigationIndex, int>.internal(
  NavigationIndex.new,
  name: r'navigationIndexProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$navigationIndexHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NavigationIndex = AutoDisposeNotifier<int>;

String _$navigationHistoryHash() => r'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

/// Navigation history for back button functionality
///
/// Copied from [NavigationHistory].
@ProviderFor(NavigationHistory)
final navigationHistoryProvider = AutoDisposeNotifierProvider<NavigationHistory, List<String>>.internal(
  NavigationHistory.new,
  name: r'navigationHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$navigationHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NavigationHistory = AutoDisposeNotifier<List<String>>;

String _$appLifecycleHash() => r'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

/// App lifecycle state for navigation persistence
///
/// Copied from [AppLifecycle].
@ProviderFor(AppLifecycle)
final appLifecycleProvider = AutoDisposeNotifierProvider<AppLifecycle, AppLifecycleState>.internal(
  AppLifecycle.new,
  name: r'appLifecycleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product') ? null : _$appLifecycleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppLifecycle = AutoDisposeNotifier<AppLifecycleState>;
