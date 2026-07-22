// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barberos_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$barberosPorServicioHash() =>
    r'7e3f4d6a1c488e0865b8773bceba7f4d64f47471';

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

/// See also [barberosPorServicio].
@ProviderFor(barberosPorServicio)
const barberosPorServicioProvider = BarberosPorServicioFamily();

/// See also [barberosPorServicio].
class BarberosPorServicioFamily extends Family<AsyncValue<List<BarberoModel>>> {
  /// See also [barberosPorServicio].
  const BarberosPorServicioFamily();

  /// See also [barberosPorServicio].
  BarberosPorServicioProvider call(String servicioId) {
    return BarberosPorServicioProvider(servicioId);
  }

  @override
  BarberosPorServicioProvider getProviderOverride(
    covariant BarberosPorServicioProvider provider,
  ) {
    return call(provider.servicioId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'barberosPorServicioProvider';
}

/// See also [barberosPorServicio].
class BarberosPorServicioProvider
    extends AutoDisposeFutureProvider<List<BarberoModel>> {
  /// See also [barberosPorServicio].
  BarberosPorServicioProvider(String servicioId)
    : this._internal(
        (ref) => barberosPorServicio(ref as BarberosPorServicioRef, servicioId),
        from: barberosPorServicioProvider,
        name: r'barberosPorServicioProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$barberosPorServicioHash,
        dependencies: BarberosPorServicioFamily._dependencies,
        allTransitiveDependencies:
            BarberosPorServicioFamily._allTransitiveDependencies,
        servicioId: servicioId,
      );

  BarberosPorServicioProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.servicioId,
  }) : super.internal();

  final String servicioId;

  @override
  Override overrideWith(
    FutureOr<List<BarberoModel>> Function(BarberosPorServicioRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BarberosPorServicioProvider._internal(
        (ref) => create(ref as BarberosPorServicioRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        servicioId: servicioId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<BarberoModel>> createElement() {
    return _BarberosPorServicioProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BarberosPorServicioProvider &&
        other.servicioId == servicioId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, servicioId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BarberosPorServicioRef
    on AutoDisposeFutureProviderRef<List<BarberoModel>> {
  /// The parameter `servicioId` of this provider.
  String get servicioId;
}

class _BarberosPorServicioProviderElement
    extends AutoDisposeFutureProviderElement<List<BarberoModel>>
    with BarberosPorServicioRef {
  _BarberosPorServicioProviderElement(super.provider);

  @override
  String get servicioId => (origin as BarberosPorServicioProvider).servicioId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
