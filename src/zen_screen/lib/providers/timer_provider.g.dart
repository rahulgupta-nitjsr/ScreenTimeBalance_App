// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$canEditManuallyHash() => r'5ef0e794b770eb830efa57d9a32a9d5c4375df0b';

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

/// Provider to check if manual entry is allowed for a category
///
/// Copied from [canEditManually].
@ProviderFor(canEditManually)
const canEditManuallyProvider = CanEditManuallyFamily();

/// Provider to check if manual entry is allowed for a category
///
/// Copied from [canEditManually].
class CanEditManuallyFamily extends Family<bool> {
  /// Provider to check if manual entry is allowed for a category
  ///
  /// Copied from [canEditManually].
  const CanEditManuallyFamily();

  /// Provider to check if manual entry is allowed for a category
  ///
  /// Copied from [canEditManually].
  CanEditManuallyProvider call(
    HabitCategory category,
  ) {
    return CanEditManuallyProvider(
      category,
    );
  }

  @override
  CanEditManuallyProvider getProviderOverride(
    covariant CanEditManuallyProvider provider,
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
  String? get name => r'canEditManuallyProvider';
}

/// Provider to check if manual entry is allowed for a category
///
/// Copied from [canEditManually].
class CanEditManuallyProvider extends AutoDisposeProvider<bool> {
  /// Provider to check if manual entry is allowed for a category
  ///
  /// Copied from [canEditManually].
  CanEditManuallyProvider(
    HabitCategory category,
  ) : this._internal(
          (ref) => canEditManually(
            ref as CanEditManuallyRef,
            category,
          ),
          from: canEditManuallyProvider,
          name: r'canEditManuallyProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$canEditManuallyHash,
          dependencies: CanEditManuallyFamily._dependencies,
          allTransitiveDependencies:
              CanEditManuallyFamily._allTransitiveDependencies,
          category: category,
        );

  CanEditManuallyProvider._internal(
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
    bool Function(CanEditManuallyRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CanEditManuallyProvider._internal(
        (ref) => create(ref as CanEditManuallyRef),
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
  AutoDisposeProviderElement<bool> createElement() {
    return _CanEditManuallyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CanEditManuallyProvider && other.category == category;
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
mixin CanEditManuallyRef on AutoDisposeProviderRef<bool> {
  /// The parameter `category` of this provider.
  HabitCategory get category;
}

class _CanEditManuallyProviderElement extends AutoDisposeProviderElement<bool>
    with CanEditManuallyRef {
  _CanEditManuallyProviderElement(super.provider);

  @override
  HabitCategory get category => (origin as CanEditManuallyProvider).category;
}

String _$activeTimerCategoryHash() =>
    r'640c54e34956422312e043c4547f815e211424f9';

/// Provider to get the active timer category
///
/// Copied from [activeTimerCategory].
@ProviderFor(activeTimerCategory)
final activeTimerCategoryProvider =
    AutoDisposeProvider<HabitCategory?>.internal(
  activeTimerCategory,
  name: r'activeTimerCategoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeTimerCategoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveTimerCategoryRef = AutoDisposeProviderRef<HabitCategory?>;
String _$timerManagerHash() => r'48cf4623b851cfbd3b31bdf44c426769681ef772';

/// Timer provider for managing active timers
///
/// Copied from [TimerManager].
@ProviderFor(TimerManager)
final timerManagerProvider =
    AutoDisposeNotifierProvider<TimerManager, TimerState>.internal(
  TimerManager.new,
  name: r'timerManagerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$timerManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TimerManager = AutoDisposeNotifier<TimerState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
