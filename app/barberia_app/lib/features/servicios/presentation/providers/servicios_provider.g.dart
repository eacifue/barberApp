// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'servicios_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$serviciosHash() => r'413d4a405a983d45dd966d270fd44bc3f6dc6346';

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

/// See also [servicios].
@ProviderFor(servicios)
const serviciosProvider = ServiciosFamily();

/// See also [servicios].
class ServiciosFamily extends Family<AsyncValue<List<ServicioModel>>> {
  /// See also [servicios].
  const ServiciosFamily();

  /// See also [servicios].
  ServiciosProvider call(String barberiaId) {
    return ServiciosProvider(barberiaId);
  }

  @override
  ServiciosProvider getProviderOverride(covariant ServiciosProvider provider) {
    return call(provider.barberiaId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'serviciosProvider';
}

/// See also [servicios].
class ServiciosProvider extends AutoDisposeFutureProvider<List<ServicioModel>> {
  /// See also [servicios].
  ServiciosProvider(String barberiaId)
    : this._internal(
        (ref) => servicios(ref as ServiciosRef, barberiaId),
        from: serviciosProvider,
        name: r'serviciosProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$serviciosHash,
        dependencies: ServiciosFamily._dependencies,
        allTransitiveDependencies: ServiciosFamily._allTransitiveDependencies,
        barberiaId: barberiaId,
      );

  ServiciosProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.barberiaId,
  }) : super.internal();

  final String barberiaId;

  @override
  Override overrideWith(
    FutureOr<List<ServicioModel>> Function(ServiciosRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ServiciosProvider._internal(
        (ref) => create(ref as ServiciosRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        barberiaId: barberiaId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ServicioModel>> createElement() {
    return _ServiciosProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ServiciosProvider && other.barberiaId == barberiaId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, barberiaId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ServiciosRef on AutoDisposeFutureProviderRef<List<ServicioModel>> {
  /// The parameter `barberiaId` of this provider.
  String get barberiaId;
}

class _ServiciosProviderElement
    extends AutoDisposeFutureProviderElement<List<ServicioModel>>
    with ServiciosRef {
  _ServiciosProviderElement(super.provider);

  @override
  String get barberiaId => (origin as ServiciosProvider).barberiaId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
