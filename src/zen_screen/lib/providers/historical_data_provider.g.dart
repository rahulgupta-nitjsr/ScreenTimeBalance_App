// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historical_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$yesterdaySleepMinutesHash() =>
    r'264b96ae0072c2f23c99a2c9c697ec9385283b58';

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
String _$lastSleepMinutesHash() => r'88eb4199c2f948bbb30572e0c83fdb348844a235';

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
    r'6a295c4da6d28d6a5cab143505cc55cee35bc473';

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

String _$historicalData7DaysHash() =>
    r'e2028bedcfa08bd9281d3e73c9eb35b1baf345e9';

/// Provider to get 7-day historical data for sparklines
///
/// Copied from [historicalData7Days].
@ProviderFor(historicalData7Days)
const historicalData7DaysProvider = HistoricalData7DaysFamily();

/// Provider to get 7-day historical data for sparklines
///
/// Copied from [historicalData7Days].
class HistoricalData7DaysFamily extends Family<AsyncValue<List<int>>> {
  /// Provider to get 7-day historical data for sparklines
  ///
  /// Copied from [historicalData7Days].
  const HistoricalData7DaysFamily();

  /// Provider to get 7-day historical data for sparklines
  ///
  /// Copied from [historicalData7Days].
  HistoricalData7DaysProvider call(
    HabitCategory category,
  ) {
    return HistoricalData7DaysProvider(
      category,
    );
  }

  @override
  HistoricalData7DaysProvider getProviderOverride(
    covariant HistoricalData7DaysProvider provider,
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
  String? get name => r'historicalData7DaysProvider';
}

/// Provider to get 7-day historical data for sparklines
///
/// Copied from [historicalData7Days].
class HistoricalData7DaysProvider extends AutoDisposeFutureProvider<List<int>> {
  /// Provider to get 7-day historical data for sparklines
  ///
  /// Copied from [historicalData7Days].
  HistoricalData7DaysProvider(
    HabitCategory category,
  ) : this._internal(
          (ref) => historicalData7Days(
            ref as HistoricalData7DaysRef,
            category,
          ),
          from: historicalData7DaysProvider,
          name: r'historicalData7DaysProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$historicalData7DaysHash,
          dependencies: HistoricalData7DaysFamily._dependencies,
          allTransitiveDependencies:
              HistoricalData7DaysFamily._allTransitiveDependencies,
          category: category,
        );

  HistoricalData7DaysProvider._internal(
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
    FutureOr<List<int>> Function(HistoricalData7DaysRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HistoricalData7DaysProvider._internal(
        (ref) => create(ref as HistoricalData7DaysRef),
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
  AutoDisposeFutureProviderElement<List<int>> createElement() {
    return _HistoricalData7DaysProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HistoricalData7DaysProvider && other.category == category;
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
mixin HistoricalData7DaysRef on AutoDisposeFutureProviderRef<List<int>> {
  /// The parameter `category` of this provider.
  HabitCategory get category;
}

class _HistoricalData7DaysProviderElement
    extends AutoDisposeFutureProviderElement<List<int>>
    with HistoricalData7DaysRef {
  _HistoricalData7DaysProviderElement(super.provider);

  @override
  HabitCategory get category =>
      (origin as HistoricalData7DaysProvider).category;
}

String _$powerModeAchievedOnDateHash() =>
    r'59fd34f65fe1d6766ffc0ae1b330eca3927474ee';

/// Provider to check if POWER+ Mode was achieved on a specific date
///
/// Copied from [powerModeAchievedOnDate].
@ProviderFor(powerModeAchievedOnDate)
const powerModeAchievedOnDateProvider = PowerModeAchievedOnDateFamily();

/// Provider to check if POWER+ Mode was achieved on a specific date
///
/// Copied from [powerModeAchievedOnDate].
class PowerModeAchievedOnDateFamily extends Family<AsyncValue<bool>> {
  /// Provider to check if POWER+ Mode was achieved on a specific date
  ///
  /// Copied from [powerModeAchievedOnDate].
  const PowerModeAchievedOnDateFamily();

  /// Provider to check if POWER+ Mode was achieved on a specific date
  ///
  /// Copied from [powerModeAchievedOnDate].
  PowerModeAchievedOnDateProvider call(
    DateTime date,
  ) {
    return PowerModeAchievedOnDateProvider(
      date,
    );
  }

  @override
  PowerModeAchievedOnDateProvider getProviderOverride(
    covariant PowerModeAchievedOnDateProvider provider,
  ) {
    return call(
      provider.date,
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
  String? get name => r'powerModeAchievedOnDateProvider';
}

/// Provider to check if POWER+ Mode was achieved on a specific date
///
/// Copied from [powerModeAchievedOnDate].
class PowerModeAchievedOnDateProvider extends AutoDisposeFutureProvider<bool> {
  /// Provider to check if POWER+ Mode was achieved on a specific date
  ///
  /// Copied from [powerModeAchievedOnDate].
  PowerModeAchievedOnDateProvider(
    DateTime date,
  ) : this._internal(
          (ref) => powerModeAchievedOnDate(
            ref as PowerModeAchievedOnDateRef,
            date,
          ),
          from: powerModeAchievedOnDateProvider,
          name: r'powerModeAchievedOnDateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$powerModeAchievedOnDateHash,
          dependencies: PowerModeAchievedOnDateFamily._dependencies,
          allTransitiveDependencies:
              PowerModeAchievedOnDateFamily._allTransitiveDependencies,
          date: date,
        );

  PowerModeAchievedOnDateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    FutureOr<bool> Function(PowerModeAchievedOnDateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PowerModeAchievedOnDateProvider._internal(
        (ref) => create(ref as PowerModeAchievedOnDateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _PowerModeAchievedOnDateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PowerModeAchievedOnDateProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PowerModeAchievedOnDateRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _PowerModeAchievedOnDateProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with PowerModeAchievedOnDateRef {
  _PowerModeAchievedOnDateProviderElement(super.provider);

  @override
  DateTime get date => (origin as PowerModeAchievedOnDateProvider).date;
}

String _$powerModeStreakHash() => r'9a2314443b434ca4a2e74503a1f0d34e7037e928';

/// Provider to get POWER+ Mode achievement streak
///
/// Copied from [powerModeStreak].
@ProviderFor(powerModeStreak)
final powerModeStreakProvider = AutoDisposeFutureProvider<int>.internal(
  powerModeStreak,
  name: r'powerModeStreakProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$powerModeStreakHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PowerModeStreakRef = AutoDisposeFutureProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
