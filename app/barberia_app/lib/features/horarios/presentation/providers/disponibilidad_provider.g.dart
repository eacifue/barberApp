// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'disponibilidad_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$disponibilidadHash() => r'f3e5218cf5da3b5d1ae2b02de54ad938da7ab910';

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

/// See also [disponibilidad].
@ProviderFor(disponibilidad)
const disponibilidadProvider = DisponibilidadFamily();

/// See also [disponibilidad].
class DisponibilidadFamily extends Family<AsyncValue<DisponibilidadModel>> {
  /// See also [disponibilidad].
  const DisponibilidadFamily();

  /// See also [disponibilidad].
  DisponibilidadProvider call({
    required String barberoId,
    required String servicioId,
    required DateTime fecha,
  }) {
    return DisponibilidadProvider(
      barberoId: barberoId,
      servicioId: servicioId,
      fecha: fecha,
    );
  }

  @override
  DisponibilidadProvider getProviderOverride(
    covariant DisponibilidadProvider provider,
  ) {
    return call(
      barberoId: provider.barberoId,
      servicioId: provider.servicioId,
      fecha: provider.fecha,
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
  String? get name => r'disponibilidadProvider';
}

/// See also [disponibilidad].
class DisponibilidadProvider
    extends AutoDisposeFutureProvider<DisponibilidadModel> {
  /// See also [disponibilidad].
  DisponibilidadProvider({
    required String barberoId,
    required String servicioId,
    required DateTime fecha,
  }) : this._internal(
         (ref) => disponibilidad(
           ref as DisponibilidadRef,
           barberoId: barberoId,
           servicioId: servicioId,
           fecha: fecha,
         ),
         from: disponibilidadProvider,
         name: r'disponibilidadProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$disponibilidadHash,
         dependencies: DisponibilidadFamily._dependencies,
         allTransitiveDependencies:
             DisponibilidadFamily._allTransitiveDependencies,
         barberoId: barberoId,
         servicioId: servicioId,
         fecha: fecha,
       );

  DisponibilidadProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.barberoId,
    required this.servicioId,
    required this.fecha,
  }) : super.internal();

  final String barberoId;
  final String servicioId;
  final DateTime fecha;

  @override
  Override overrideWith(
    FutureOr<DisponibilidadModel> Function(DisponibilidadRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DisponibilidadProvider._internal(
        (ref) => create(ref as DisponibilidadRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        barberoId: barberoId,
        servicioId: servicioId,
        fecha: fecha,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DisponibilidadModel> createElement() {
    return _DisponibilidadProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DisponibilidadProvider &&
        other.barberoId == barberoId &&
        other.servicioId == servicioId &&
        other.fecha == fecha;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, barberoId.hashCode);
    hash = _SystemHash.combine(hash, servicioId.hashCode);
    hash = _SystemHash.combine(hash, fecha.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DisponibilidadRef on AutoDisposeFutureProviderRef<DisponibilidadModel> {
  /// The parameter `barberoId` of this provider.
  String get barberoId;

  /// The parameter `servicioId` of this provider.
  String get servicioId;

  /// The parameter `fecha` of this provider.
  DateTime get fecha;
}

class _DisponibilidadProviderElement
    extends AutoDisposeFutureProviderElement<DisponibilidadModel>
    with DisponibilidadRef {
  _DisponibilidadProviderElement(super.provider);

  @override
  String get barberoId => (origin as DisponibilidadProvider).barberoId;
  @override
  String get servicioId => (origin as DisponibilidadProvider).servicioId;
  @override
  DateTime get fecha => (origin as DisponibilidadProvider).fecha;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
