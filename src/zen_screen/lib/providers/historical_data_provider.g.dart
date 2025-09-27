// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historical_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$yesterdaySleepMinutesHash() =>
    r'cc763000bc4dcabaa6078d348e740674e2bb89de';

/// Provider to get yesterday's sleep data for "same as last night" functionality
///
/// Copied from [yesterdaySleepMinutes].
@ProviderFor(yesterdaySleepMinutes)
final yesterdaySleepMinutesProvider = AutoDisposeFutureProvider<int>.internal(
  yesterdaySleepMinutes,
  name: r'yesterdaySleepMinutesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$yesterdaySleepMinutesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef YesterdaySleepMinutesRef = AutoDisposeFutureProviderRef<int>;
String _$lastSleepMinutesHash() => r'40bca85eb124edd9e9daa5ea6ff0e8eefcf9e96a';

/// Provider to get the most recent sleep data (yesterday or today)
///
/// Copied from [lastSleepMinutes].
@ProviderFor(lastSleepMinutes)
final lastSleepMinutesProvider = AutoDisposeFutureProvider<int>.internal(
  lastSleepMinutes,
  name: r'lastSleepMinutesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lastSleepMinutesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LastSleepMinutesRef = AutoDisposeFutureProviderRef<int>;
String _$lastCategoryMinutesHash() =>
    r'd5feede6e711f55602fca7715cd157d98881e596';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider to get historical data for any category
///
/// Copied from [lastCategoryMinutes].
@ProviderFor(lastCategoryMinutes)
const lastCategoryMinutesProvider = LastCategoryMinutesFamily();

/// Provider to get historical data for any category
///
/// Copied from [lastCategoryMinutes].
class LastCategoryMinutesFamily
    extends Family<AsyncValue<Map<HabitCategory, int>>> {
  /// Provider to get historical data for any category
  ///
  /// Copied from [lastCategoryMinutes].
  const LastCategoryMinutesFamily();

  /// Provider to get historical data for any category
  ///
  /// Copied from [lastCategoryMinutes].
  LastCategoryMinutesProvider call(
    HabitCategory category,
  ) {
    return LastCategoryMinutesProvider(
      category,
    );
  }

  @override
  LastCategoryMinutesProvider getProviderOverride(
    covariant LastCategoryMinutesProvider provider,
  ) {
    return call(
      provider.category,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'lastCategoryMinutesProvider';
}

/// Provider to get historical data for any category
///
/// Copied from [lastCategoryMinutes].
class LastCategoryMinutesProvider
    extends AutoDisposeFutureProvider<Map<HabitCategory, int>> {
  /// Provider to get historical data for any category
  ///
  /// Copied from [lastCategoryMinutes].
  LastCategoryMinutesProvider(
    HabitCategory category,
  ) : this._internal(
          (ref) => lastCategoryMinutes(
            ref as LastCategoryMinutesRef,
            category,
          ),
          from: lastCategoryMinutesProvider,
          name: r'lastCategoryMinutesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$lastCategoryMinutesHash,
          dependencies: LastCategoryMinutesFamily._dependencies,
          allTransitiveDependencies:
              LastCategoryMinutesFamily._allTransitiveDependencies,
          category: category,
        );

  LastCategoryMinutesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
  }) : super.internal();

  final HabitCategory category;

  @override
  Override overrideWith(
    FutureOr<Map<HabitCategory, int>> Function(LastCategoryMinutesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LastCategoryMinutesProvider._internal(
        (ref) => create(ref as LastCategoryMinutesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<HabitCategory, int>> createElement() {
    return _LastCategoryMinutesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LastCategoryMinutesProvider && other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LastCategoryMinutesRef
    on AutoDisposeFutureProviderRef<Map<HabitCategory, int>> {
  /// The parameter `category` of this provider.
  HabitCategory get category;
}

class _LastCategoryMinutesProviderElement
    extends AutoDisposeFutureProviderElement<Map<HabitCategory, int>>
    with LastCategoryMinutesRef {
  _LastCategoryMinutesProviderElement(super.provider);

  @override
  HabitCategory get category =>
      (origin as LastCategoryMinutesProvider).category;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
