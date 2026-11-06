// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cita_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CitaModel _$CitaModelFromJson(Map<String, dynamic> json) {
  return _CitaModel.fromJson(json);
}

/// @nodoc
mixin _$CitaModel {
  String get id => throw _privateConstructorUsedError;
  String get estado => throw _privateConstructorUsedError;
  DateTime get fechaCita => throw _privateConstructorUsedError;
  String get horaInicio => throw _privateConstructorUsedError;
  String get horaFin => throw _privateConstructorUsedError;
  double get precioFinal => throw _privateConstructorUsedError;
  String? get notas => throw _privateConstructorUsedError;
  ClienteResumen get cliente => throw _privateConstructorUsedError;
  BarberoResumen get barbero => throw _privateConstructorUsedError;
  ServicioResumen get servicio => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get tieneReview => throw _privateConstructorUsedError;

  /// Serializes this CitaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CitaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CitaModelCopyWith<CitaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CitaModelCopyWith<$Res> {
  factory $CitaModelCopyWith(CitaModel value, $Res Function(CitaModel) then) =
      _$CitaModelCopyWithImpl<$Res, CitaModel>;
  @useResult
  $Res call({
    String id,
    String estado,
    DateTime fechaCita,
    String horaInicio,
    String horaFin,
    double precioFinal,
    String? notas,
    ClienteResumen cliente,
    BarberoResumen barbero,
    ServicioResumen servicio,
    DateTime createdAt,
    bool tieneReview,
  });

  $ClienteResumenCopyWith<$Res> get cliente;
  $BarberoResumenCopyWith<$Res> get barbero;
  $ServicioResumenCopyWith<$Res> get servicio;
}

/// @nodoc
class _$CitaModelCopyWithImpl<$Res, $Val extends CitaModel>
    implements $CitaModelCopyWith<$Res> {
  _$CitaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CitaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? estado = null,
    Object? fechaCita = null,
    Object? horaInicio = null,
    Object? horaFin = null,
    Object? precioFinal = null,
    Object? notas = freezed,
    Object? cliente = null,
    Object? barbero = null,
    Object? servicio = null,
    Object? createdAt = null,
    Object? tieneReview = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            estado: null == estado
                ? _value.estado
                : estado // ignore: cast_nullable_to_non_nullable
                      as String,
            fechaCita: null == fechaCita
                ? _value.fechaCita
                : fechaCita // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            horaInicio: null == horaInicio
                ? _value.horaInicio
                : horaInicio // ignore: cast_nullable_to_non_nullable
                      as String,
            horaFin: null == horaFin
                ? _value.horaFin
                : horaFin // ignore: cast_nullable_to_non_nullable
                      as String,
            precioFinal: null == precioFinal
                ? _value.precioFinal
                : precioFinal // ignore: cast_nullable_to_non_nullable
                      as double,
            notas: freezed == notas
                ? _value.notas
                : notas // ignore: cast_nullable_to_non_nullable
                      as String?,
            cliente: null == cliente
                ? _value.cliente
                : cliente // ignore: cast_nullable_to_non_nullable
                      as ClienteResumen,
            barbero: null == barbero
                ? _value.barbero
                : barbero // ignore: cast_nullable_to_non_nullable
                      as BarberoResumen,
            servicio: null == servicio
                ? _value.servicio
                : servicio // ignore: cast_nullable_to_non_nullable
                      as ServicioResumen,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            tieneReview: null == tieneReview
                ? _value.tieneReview
                : tieneReview // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of CitaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ClienteResumenCopyWith<$Res> get cliente {
    return $ClienteResumenCopyWith<$Res>(_value.cliente, (value) {
      return _then(_value.copyWith(cliente: value) as $Val);
    });
  }

  /// Create a copy of CitaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BarberoResumenCopyWith<$Res> get barbero {
    return $BarberoResumenCopyWith<$Res>(_value.barbero, (value) {
      return _then(_value.copyWith(barbero: value) as $Val);
    });
  }

  /// Create a copy of CitaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ServicioResumenCopyWith<$Res> get servicio {
    return $ServicioResumenCopyWith<$Res>(_value.servicio, (value) {
      return _then(_value.copyWith(servicio: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CitaModelImplCopyWith<$Res>
    implements $CitaModelCopyWith<$Res> {
  factory _$$CitaModelImplCopyWith(
    _$CitaModelImpl value,
    $Res Function(_$CitaModelImpl) then,
  ) = __$$CitaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String estado,
    DateTime fechaCita,
    String horaInicio,
    String horaFin,
    double precioFinal,
    String? notas,
    ClienteResumen cliente,
    BarberoResumen barbero,
    ServicioResumen servicio,
    DateTime createdAt,
    bool tieneReview,
  });

  @override
  $ClienteResumenCopyWith<$Res> get cliente;
  @override
  $BarberoResumenCopyWith<$Res> get barbero;
  @override
  $ServicioResumenCopyWith<$Res> get servicio;
}

/// @nodoc
class __$$CitaModelImplCopyWithImpl<$Res>
    extends _$CitaModelCopyWithImpl<$Res, _$CitaModelImpl>
    implements _$$CitaModelImplCopyWith<$Res> {
  __$$CitaModelImplCopyWithImpl(
    _$CitaModelImpl _value,
    $Res Function(_$CitaModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CitaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? estado = null,
    Object? fechaCita = null,
    Object? horaInicio = null,
    Object? horaFin = null,
    Object? precioFinal = null,
    Object? notas = freezed,
    Object? cliente = null,
    Object? barbero = null,
    Object? servicio = null,
    Object? createdAt = null,
    Object? tieneReview = null,
  }) {
    return _then(
      _$CitaModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        estado: null == estado
            ? _value.estado
            : estado // ignore: cast_nullable_to_non_nullable
                  as String,
        fechaCita: null == fechaCita
            ? _value.fechaCita
            : fechaCita // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        horaInicio: null == horaInicio
            ? _value.horaInicio
            : horaInicio // ignore: cast_nullable_to_non_nullable
                  as String,
        horaFin: null == horaFin
            ? _value.horaFin
            : horaFin // ignore: cast_nullable_to_non_nullable
                  as String,
        precioFinal: null == precioFinal
            ? _value.precioFinal
            : precioFinal // ignore: cast_nullable_to_non_nullable
                  as double,
        notas: freezed == notas
            ? _value.notas
            : notas // ignore: cast_nullable_to_non_nullable
                  as String?,
        cliente: null == cliente
            ? _value.cliente
            : cliente // ignore: cast_nullable_to_non_nullable
                  as ClienteResumen,
        barbero: null == barbero
            ? _value.barbero
            : barbero // ignore: cast_nullable_to_non_nullable
                  as BarberoResumen,
        servicio: null == servicio
            ? _value.servicio
            : servicio // ignore: cast_nullable_to_non_nullable
                  as ServicioResumen,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        tieneReview: null == tieneReview
            ? _value.tieneReview
            : tieneReview // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CitaModelImpl extends _CitaModel {
  const _$CitaModelImpl({
    required this.id,
    required this.estado,
    required this.fechaCita,
    required this.horaInicio,
    required this.horaFin,
    required this.precioFinal,
    this.notas,
    required this.cliente,
    required this.barbero,
    required this.servicio,
    required this.createdAt,
    this.tieneReview = false,
  }) : super._();

  factory _$CitaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CitaModelImplFromJson(json);

  @override
  final String id;
  @override
  final String estado;
  @override
  final DateTime fechaCita;
  @override
  final String horaInicio;
  @override
  final String horaFin;
  @override
  final double precioFinal;
  @override
  final String? notas;
  @override
  final ClienteResumen cliente;
  @override
  final BarberoResumen barbero;
  @override
  final ServicioResumen servicio;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool tieneReview;

  @override
  String toString() {
    return 'CitaModel(id: $id, estado: $estado, fechaCita: $fechaCita, horaInicio: $horaInicio, horaFin: $horaFin, precioFinal: $precioFinal, notas: $notas, cliente: $cliente, barbero: $barbero, servicio: $servicio, createdAt: $createdAt, tieneReview: $tieneReview)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CitaModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.estado, estado) || other.estado == estado) &&
            (identical(other.fechaCita, fechaCita) ||
                other.fechaCita == fechaCita) &&
            (identical(other.horaInicio, horaInicio) ||
                other.horaInicio == horaInicio) &&
            (identical(other.horaFin, horaFin) || other.horaFin == horaFin) &&
            (identical(other.precioFinal, precioFinal) ||
                other.precioFinal == precioFinal) &&
            (identical(other.notas, notas) || other.notas == notas) &&
            (identical(other.cliente, cliente) || other.cliente == cliente) &&
            (identical(other.barbero, barbero) || other.barbero == barbero) &&
            (identical(other.servicio, servicio) ||
                other.servicio == servicio) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.tieneReview, tieneReview) ||
                other.tieneReview == tieneReview));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    estado,
    fechaCita,
    horaInicio,
    horaFin,
    precioFinal,
    notas,
    cliente,
    barbero,
    servicio,
    createdAt,
    tieneReview,
  );

  /// Create a copy of CitaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CitaModelImplCopyWith<_$CitaModelImpl> get copyWith =>
      __$$CitaModelImplCopyWithImpl<_$CitaModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CitaModelImplToJson(this);
  }
}

abstract class _CitaModel extends CitaModel {
  const factory _CitaModel({
    required final String id,
    required final String estado,
    required final DateTime fechaCita,
    required final String horaInicio,
    required final String horaFin,
    required final double precioFinal,
    final String? notas,
    required final ClienteResumen cliente,
    required final BarberoResumen barbero,
    required final ServicioResumen servicio,
    required final DateTime createdAt,
    final bool tieneReview,
  }) = _$CitaModelImpl;
  const _CitaModel._() : super._();

  factory _CitaModel.fromJson(Map<String, dynamic> json) =
      _$CitaModelImpl.fromJson;

  @override
  String get id;
  @override
  String get estado;
  @override
  DateTime get fechaCita;
  @override
  String get horaInicio;
  @override
  String get horaFin;
  @override
  double get precioFinal;
  @override
  String? get notas;
  @override
  ClienteResumen get cliente;
  @override
  BarberoResumen get barbero;
  @override
  ServicioResumen get servicio;
  @override
  DateTime get createdAt;
  @override
  bool get tieneReview;

  /// Create a copy of CitaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CitaModelImplCopyWith<_$CitaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClienteResumen _$ClienteResumenFromJson(Map<String, dynamic> json) {
  return _ClienteResumen.fromJson(json);
}

/// @nodoc
mixin _$ClienteResumen {
  String get id => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  String get apellido => throw _privateConstructorUsedError;
  String get telefono => throw _privateConstructorUsedError;

  /// Serializes this ClienteResumen to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClienteResumen
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClienteResumenCopyWith<ClienteResumen> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClienteResumenCopyWith<$Res> {
  factory $ClienteResumenCopyWith(
    ClienteResumen value,
    $Res Function(ClienteResumen) then,
  ) = _$ClienteResumenCopyWithImpl<$Res, ClienteResumen>;
  @useResult
  $Res call({String id, String nombre, String apellido, String telefono});
}

/// @nodoc
class _$ClienteResumenCopyWithImpl<$Res, $Val extends ClienteResumen>
    implements $ClienteResumenCopyWith<$Res> {
  _$ClienteResumenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClienteResumen
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? apellido = null,
    Object? telefono = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            nombre: null == nombre
                ? _value.nombre
                : nombre // ignore: cast_nullable_to_non_nullable
                      as String,
            apellido: null == apellido
                ? _value.apellido
                : apellido // ignore: cast_nullable_to_non_nullable
                      as String,
            telefono: null == telefono
                ? _value.telefono
                : telefono // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClienteResumenImplCopyWith<$Res>
    implements $ClienteResumenCopyWith<$Res> {
  factory _$$ClienteResumenImplCopyWith(
    _$ClienteResumenImpl value,
    $Res Function(_$ClienteResumenImpl) then,
  ) = __$$ClienteResumenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String nombre, String apellido, String telefono});
}

/// @nodoc
class __$$ClienteResumenImplCopyWithImpl<$Res>
    extends _$ClienteResumenCopyWithImpl<$Res, _$ClienteResumenImpl>
    implements _$$ClienteResumenImplCopyWith<$Res> {
  __$$ClienteResumenImplCopyWithImpl(
    _$ClienteResumenImpl _value,
    $Res Function(_$ClienteResumenImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ClienteResumen
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? apellido = null,
    Object? telefono = null,
  }) {
    return _then(
      _$ClienteResumenImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        nombre: null == nombre
            ? _value.nombre
            : nombre // ignore: cast_nullable_to_non_nullable
                  as String,
        apellido: null == apellido
            ? _value.apellido
            : apellido // ignore: cast_nullable_to_non_nullable
                  as String,
        telefono: null == telefono
            ? _value.telefono
            : telefono // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClienteResumenImpl implements _ClienteResumen {
  const _$ClienteResumenImpl({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.telefono,
  });

  factory _$ClienteResumenImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClienteResumenImplFromJson(json);

  @override
  final String id;
  @override
  final String nombre;
  @override
  final String apellido;
  @override
  final String telefono;

  @override
  String toString() {
    return 'ClienteResumen(id: $id, nombre: $nombre, apellido: $apellido, telefono: $telefono)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClienteResumenImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.apellido, apellido) ||
                other.apellido == apellido) &&
            (identical(other.telefono, telefono) ||
                other.telefono == telefono));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nombre, apellido, telefono);

  /// Create a copy of ClienteResumen
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClienteResumenImplCopyWith<_$ClienteResumenImpl> get copyWith =>
      __$$ClienteResumenImplCopyWithImpl<_$ClienteResumenImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ClienteResumenImplToJson(this);
  }
}

abstract class _ClienteResumen implements ClienteResumen {
  const factory _ClienteResumen({
    required final String id,
    required final String nombre,
    required final String apellido,
    required final String telefono,
  }) = _$ClienteResumenImpl;

  factory _ClienteResumen.fromJson(Map<String, dynamic> json) =
      _$ClienteResumenImpl.fromJson;

  @override
  String get id;
  @override
  String get nombre;
  @override
  String get apellido;
  @override
  String get telefono;

  /// Create a copy of ClienteResumen
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClienteResumenImplCopyWith<_$ClienteResumenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BarberoResumen _$BarberoResumenFromJson(Map<String, dynamic> json) {
  return _BarberoResumen.fromJson(json);
}

/// @nodoc
mixin _$BarberoResumen {
  String get id => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  String get apellido => throw _privateConstructorUsedError;
  String? get fotoUrl => throw _privateConstructorUsedError;

  /// Serializes this BarberoResumen to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BarberoResumen
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BarberoResumenCopyWith<BarberoResumen> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BarberoResumenCopyWith<$Res> {
  factory $BarberoResumenCopyWith(
    BarberoResumen value,
    $Res Function(BarberoResumen) then,
  ) = _$BarberoResumenCopyWithImpl<$Res, BarberoResumen>;
  @useResult
  $Res call({String id, String nombre, String apellido, String? fotoUrl});
}

/// @nodoc
class _$BarberoResumenCopyWithImpl<$Res, $Val extends BarberoResumen>
    implements $BarberoResumenCopyWith<$Res> {
  _$BarberoResumenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BarberoResumen
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? apellido = null,
    Object? fotoUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            nombre: null == nombre
                ? _value.nombre
                : nombre // ignore: cast_nullable_to_non_nullable
                      as String,
            apellido: null == apellido
                ? _value.apellido
                : apellido // ignore: cast_nullable_to_non_nullable
                      as String,
            fotoUrl: freezed == fotoUrl
                ? _value.fotoUrl
                : fotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BarberoResumenImplCopyWith<$Res>
    implements $BarberoResumenCopyWith<$Res> {
  factory _$$BarberoResumenImplCopyWith(
    _$BarberoResumenImpl value,
    $Res Function(_$BarberoResumenImpl) then,
  ) = __$$BarberoResumenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String nombre, String apellido, String? fotoUrl});
}

/// @nodoc
class __$$BarberoResumenImplCopyWithImpl<$Res>
    extends _$BarberoResumenCopyWithImpl<$Res, _$BarberoResumenImpl>
    implements _$$BarberoResumenImplCopyWith<$Res> {
  __$$BarberoResumenImplCopyWithImpl(
    _$BarberoResumenImpl _value,
    $Res Function(_$BarberoResumenImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BarberoResumen
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? apellido = null,
    Object? fotoUrl = freezed,
  }) {
    return _then(
      _$BarberoResumenImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        nombre: null == nombre
            ? _value.nombre
            : nombre // ignore: cast_nullable_to_non_nullable
                  as String,
        apellido: null == apellido
            ? _value.apellido
            : apellido // ignore: cast_nullable_to_non_nullable
                  as String,
        fotoUrl: freezed == fotoUrl
            ? _value.fotoUrl
            : fotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BarberoResumenImpl implements _BarberoResumen {
  const _$BarberoResumenImpl({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.fotoUrl,
  });

  factory _$BarberoResumenImpl.fromJson(Map<String, dynamic> json) =>
      _$$BarberoResumenImplFromJson(json);

  @override
  final String id;
  @override
  final String nombre;
  @override
  final String apellido;
  @override
  final String? fotoUrl;

  @override
  String toString() {
    return 'BarberoResumen(id: $id, nombre: $nombre, apellido: $apellido, fotoUrl: $fotoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BarberoResumenImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.apellido, apellido) ||
                other.apellido == apellido) &&
            (identical(other.fotoUrl, fotoUrl) || other.fotoUrl == fotoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nombre, apellido, fotoUrl);

  /// Create a copy of BarberoResumen
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BarberoResumenImplCopyWith<_$BarberoResumenImpl> get copyWith =>
      __$$BarberoResumenImplCopyWithImpl<_$BarberoResumenImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BarberoResumenImplToJson(this);
  }
}

abstract class _BarberoResumen implements BarberoResumen {
  const factory _BarberoResumen({
    required final String id,
    required final String nombre,
    required final String apellido,
    final String? fotoUrl,
  }) = _$BarberoResumenImpl;

  factory _BarberoResumen.fromJson(Map<String, dynamic> json) =
      _$BarberoResumenImpl.fromJson;

  @override
  String get id;
  @override
  String get nombre;
  @override
  String get apellido;
  @override
  String? get fotoUrl;

  /// Create a copy of BarberoResumen
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BarberoResumenImplCopyWith<_$BarberoResumenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ServicioResumen _$ServicioResumenFromJson(Map<String, dynamic> json) {
  return _ServicioResumen.fromJson(json);
}

/// @nodoc
mixin _$ServicioResumen {
  String get id => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  int get duracionMinutos => throw _privateConstructorUsedError;
  double get precio => throw _privateConstructorUsedError;

  /// Serializes this ServicioResumen to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServicioResumen
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServicioResumenCopyWith<ServicioResumen> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServicioResumenCopyWith<$Res> {
  factory $ServicioResumenCopyWith(
    ServicioResumen value,
    $Res Function(ServicioResumen) then,
  ) = _$ServicioResumenCopyWithImpl<$Res, ServicioResumen>;
  @useResult
  $Res call({String id, String nombre, int duracionMinutos, double precio});
}

/// @nodoc
class _$ServicioResumenCopyWithImpl<$Res, $Val extends ServicioResumen>
    implements $ServicioResumenCopyWith<$Res> {
  _$ServicioResumenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServicioResumen
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? duracionMinutos = null,
    Object? precio = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            nombre: null == nombre
                ? _value.nombre
                : nombre // ignore: cast_nullable_to_non_nullable
                      as String,
            duracionMinutos: null == duracionMinutos
                ? _value.duracionMinutos
                : duracionMinutos // ignore: cast_nullable_to_non_nullable
                      as int,
            precio: null == precio
                ? _value.precio
                : precio // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServicioResumenImplCopyWith<$Res>
    implements $ServicioResumenCopyWith<$Res> {
  factory _$$ServicioResumenImplCopyWith(
    _$ServicioResumenImpl value,
    $Res Function(_$ServicioResumenImpl) then,
  ) = __$$ServicioResumenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String nombre, int duracionMinutos, double precio});
}

/// @nodoc
class __$$ServicioResumenImplCopyWithImpl<$Res>
    extends _$ServicioResumenCopyWithImpl<$Res, _$ServicioResumenImpl>
    implements _$$ServicioResumenImplCopyWith<$Res> {
  __$$ServicioResumenImplCopyWithImpl(
    _$ServicioResumenImpl _value,
    $Res Function(_$ServicioResumenImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServicioResumen
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? duracionMinutos = null,
    Object? precio = null,
  }) {
    return _then(
      _$ServicioResumenImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        nombre: null == nombre
            ? _value.nombre
            : nombre // ignore: cast_nullable_to_non_nullable
                  as String,
        duracionMinutos: null == duracionMinutos
            ? _value.duracionMinutos
            : duracionMinutos // ignore: cast_nullable_to_non_nullable
                  as int,
        precio: null == precio
            ? _value.precio
            : precio // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ServicioResumenImpl implements _ServicioResumen {
  const _$ServicioResumenImpl({
    required this.id,
    required this.nombre,
    required this.duracionMinutos,
    required this.precio,
  });

  factory _$ServicioResumenImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServicioResumenImplFromJson(json);

  @override
  final String id;
  @override
  final String nombre;
  @override
  final int duracionMinutos;
  @override
  final double precio;

  @override
  String toString() {
    return 'ServicioResumen(id: $id, nombre: $nombre, duracionMinutos: $duracionMinutos, precio: $precio)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServicioResumenImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.duracionMinutos, duracionMinutos) ||
                other.duracionMinutos == duracionMinutos) &&
            (identical(other.precio, precio) || other.precio == precio));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, nombre, duracionMinutos, precio);

  /// Create a copy of ServicioResumen
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServicioResumenImplCopyWith<_$ServicioResumenImpl> get copyWith =>
      __$$ServicioResumenImplCopyWithImpl<_$ServicioResumenImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ServicioResumenImplToJson(this);
  }
}

abstract class _ServicioResumen implements ServicioResumen {
  const factory _ServicioResumen({
    required final String id,
    required final String nombre,
    required final int duracionMinutos,
    required final double precio,
  }) = _$ServicioResumenImpl;

  factory _ServicioResumen.fromJson(Map<String, dynamic> json) =
      _$ServicioResumenImpl.fromJson;

  @override
  String get id;
  @override
  String get nombre;
  @override
  int get duracionMinutos;
  @override
  double get precio;

  /// Create a copy of ServicioResumen
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServicioResumenImplCopyWith<_$ServicioResumenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
