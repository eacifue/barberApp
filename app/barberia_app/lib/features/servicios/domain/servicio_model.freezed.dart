// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'servicio_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ServicioModel _$ServicioModelFromJson(Map<String, dynamic> json) {
  return _ServicioModel.fromJson(json);
}

/// @nodoc
mixin _$ServicioModel {
  String get id => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  String get descripcion => throw _privateConstructorUsedError;
  String get tipo => throw _privateConstructorUsedError;
  int get duracionMinutos => throw _privateConstructorUsedError;
  double get precio => throw _privateConstructorUsedError;
  String? get fotoUrl => throw _privateConstructorUsedError;
  bool get activo => throw _privateConstructorUsedError;

  /// Serializes this ServicioModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServicioModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServicioModelCopyWith<ServicioModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServicioModelCopyWith<$Res> {
  factory $ServicioModelCopyWith(
    ServicioModel value,
    $Res Function(ServicioModel) then,
  ) = _$ServicioModelCopyWithImpl<$Res, ServicioModel>;
  @useResult
  $Res call({
    String id,
    String nombre,
    String descripcion,
    String tipo,
    int duracionMinutos,
    double precio,
    String? fotoUrl,
    bool activo,
  });
}

/// @nodoc
class _$ServicioModelCopyWithImpl<$Res, $Val extends ServicioModel>
    implements $ServicioModelCopyWith<$Res> {
  _$ServicioModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServicioModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? descripcion = null,
    Object? tipo = null,
    Object? duracionMinutos = null,
    Object? precio = null,
    Object? fotoUrl = freezed,
    Object? activo = null,
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
            descripcion: null == descripcion
                ? _value.descripcion
                : descripcion // ignore: cast_nullable_to_non_nullable
                      as String,
            tipo: null == tipo
                ? _value.tipo
                : tipo // ignore: cast_nullable_to_non_nullable
                      as String,
            duracionMinutos: null == duracionMinutos
                ? _value.duracionMinutos
                : duracionMinutos // ignore: cast_nullable_to_non_nullable
                      as int,
            precio: null == precio
                ? _value.precio
                : precio // ignore: cast_nullable_to_non_nullable
                      as double,
            fotoUrl: freezed == fotoUrl
                ? _value.fotoUrl
                : fotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            activo: null == activo
                ? _value.activo
                : activo // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServicioModelImplCopyWith<$Res>
    implements $ServicioModelCopyWith<$Res> {
  factory _$$ServicioModelImplCopyWith(
    _$ServicioModelImpl value,
    $Res Function(_$ServicioModelImpl) then,
  ) = __$$ServicioModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String nombre,
    String descripcion,
    String tipo,
    int duracionMinutos,
    double precio,
    String? fotoUrl,
    bool activo,
  });
}

/// @nodoc
class __$$ServicioModelImplCopyWithImpl<$Res>
    extends _$ServicioModelCopyWithImpl<$Res, _$ServicioModelImpl>
    implements _$$ServicioModelImplCopyWith<$Res> {
  __$$ServicioModelImplCopyWithImpl(
    _$ServicioModelImpl _value,
    $Res Function(_$ServicioModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServicioModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? descripcion = null,
    Object? tipo = null,
    Object? duracionMinutos = null,
    Object? precio = null,
    Object? fotoUrl = freezed,
    Object? activo = null,
  }) {
    return _then(
      _$ServicioModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        nombre: null == nombre
            ? _value.nombre
            : nombre // ignore: cast_nullable_to_non_nullable
                  as String,
        descripcion: null == descripcion
            ? _value.descripcion
            : descripcion // ignore: cast_nullable_to_non_nullable
                  as String,
        tipo: null == tipo
            ? _value.tipo
            : tipo // ignore: cast_nullable_to_non_nullable
                  as String,
        duracionMinutos: null == duracionMinutos
            ? _value.duracionMinutos
            : duracionMinutos // ignore: cast_nullable_to_non_nullable
                  as int,
        precio: null == precio
            ? _value.precio
            : precio // ignore: cast_nullable_to_non_nullable
                  as double,
        fotoUrl: freezed == fotoUrl
            ? _value.fotoUrl
            : fotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        activo: null == activo
            ? _value.activo
            : activo // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ServicioModelImpl extends _ServicioModel {
  const _$ServicioModelImpl({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.tipo,
    required this.duracionMinutos,
    required this.precio,
    this.fotoUrl,
    required this.activo,
  }) : super._();

  factory _$ServicioModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServicioModelImplFromJson(json);

  @override
  final String id;
  @override
  final String nombre;
  @override
  final String descripcion;
  @override
  final String tipo;
  @override
  final int duracionMinutos;
  @override
  final double precio;
  @override
  final String? fotoUrl;
  @override
  final bool activo;

  @override
  String toString() {
    return 'ServicioModel(id: $id, nombre: $nombre, descripcion: $descripcion, tipo: $tipo, duracionMinutos: $duracionMinutos, precio: $precio, fotoUrl: $fotoUrl, activo: $activo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServicioModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.descripcion, descripcion) ||
                other.descripcion == descripcion) &&
            (identical(other.tipo, tipo) || other.tipo == tipo) &&
            (identical(other.duracionMinutos, duracionMinutos) ||
                other.duracionMinutos == duracionMinutos) &&
            (identical(other.precio, precio) || other.precio == precio) &&
            (identical(other.fotoUrl, fotoUrl) || other.fotoUrl == fotoUrl) &&
            (identical(other.activo, activo) || other.activo == activo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    nombre,
    descripcion,
    tipo,
    duracionMinutos,
    precio,
    fotoUrl,
    activo,
  );

  /// Create a copy of ServicioModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServicioModelImplCopyWith<_$ServicioModelImpl> get copyWith =>
      __$$ServicioModelImplCopyWithImpl<_$ServicioModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServicioModelImplToJson(this);
  }
}

abstract class _ServicioModel extends ServicioModel {
  const factory _ServicioModel({
    required final String id,
    required final String nombre,
    required final String descripcion,
    required final String tipo,
    required final int duracionMinutos,
    required final double precio,
    final String? fotoUrl,
    required final bool activo,
  }) = _$ServicioModelImpl;
  const _ServicioModel._() : super._();

  factory _ServicioModel.fromJson(Map<String, dynamic> json) =
      _$ServicioModelImpl.fromJson;

  @override
  String get id;
  @override
  String get nombre;
  @override
  String get descripcion;
  @override
  String get tipo;
  @override
  int get duracionMinutos;
  @override
  double get precio;
  @override
  String? get fotoUrl;
  @override
  bool get activo;

  /// Create a copy of ServicioModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServicioModelImplCopyWith<_$ServicioModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
