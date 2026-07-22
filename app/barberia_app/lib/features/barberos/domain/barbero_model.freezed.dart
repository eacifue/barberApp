// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'barbero_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BarberoModel _$BarberoModelFromJson(Map<String, dynamic> json) {
  return _BarberoModel.fromJson(json);
}

/// @nodoc
mixin _$BarberoModel {
  String get id => throw _privateConstructorUsedError;
  String get nombre => throw _privateConstructorUsedError;
  String get apellido => throw _privateConstructorUsedError;
  String get telefono => throw _privateConstructorUsedError;
  String get correo => throw _privateConstructorUsedError;
  String? get fotoUrl => throw _privateConstructorUsedError;
  String get biografia => throw _privateConstructorUsedError;
  int get aniosExperiencia => throw _privateConstructorUsedError;
  List<String> get especialidades => throw _privateConstructorUsedError;
  double get ratingPromedio => throw _privateConstructorUsedError;
  bool get disponible => throw _privateConstructorUsedError;
  bool get activo => throw _privateConstructorUsedError;
  List<ServicioModel> get servicios => throw _privateConstructorUsedError;

  /// Serializes this BarberoModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BarberoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BarberoModelCopyWith<BarberoModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BarberoModelCopyWith<$Res> {
  factory $BarberoModelCopyWith(
    BarberoModel value,
    $Res Function(BarberoModel) then,
  ) = _$BarberoModelCopyWithImpl<$Res, BarberoModel>;
  @useResult
  $Res call({
    String id,
    String nombre,
    String apellido,
    String telefono,
    String correo,
    String? fotoUrl,
    String biografia,
    int aniosExperiencia,
    List<String> especialidades,
    double ratingPromedio,
    bool disponible,
    bool activo,
    List<ServicioModel> servicios,
  });
}

/// @nodoc
class _$BarberoModelCopyWithImpl<$Res, $Val extends BarberoModel>
    implements $BarberoModelCopyWith<$Res> {
  _$BarberoModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BarberoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? apellido = null,
    Object? telefono = null,
    Object? correo = null,
    Object? fotoUrl = freezed,
    Object? biografia = null,
    Object? aniosExperiencia = null,
    Object? especialidades = null,
    Object? ratingPromedio = null,
    Object? disponible = null,
    Object? activo = null,
    Object? servicios = null,
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
            correo: null == correo
                ? _value.correo
                : correo // ignore: cast_nullable_to_non_nullable
                      as String,
            fotoUrl: freezed == fotoUrl
                ? _value.fotoUrl
                : fotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            biografia: null == biografia
                ? _value.biografia
                : biografia // ignore: cast_nullable_to_non_nullable
                      as String,
            aniosExperiencia: null == aniosExperiencia
                ? _value.aniosExperiencia
                : aniosExperiencia // ignore: cast_nullable_to_non_nullable
                      as int,
            especialidades: null == especialidades
                ? _value.especialidades
                : especialidades // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            ratingPromedio: null == ratingPromedio
                ? _value.ratingPromedio
                : ratingPromedio // ignore: cast_nullable_to_non_nullable
                      as double,
            disponible: null == disponible
                ? _value.disponible
                : disponible // ignore: cast_nullable_to_non_nullable
                      as bool,
            activo: null == activo
                ? _value.activo
                : activo // ignore: cast_nullable_to_non_nullable
                      as bool,
            servicios: null == servicios
                ? _value.servicios
                : servicios // ignore: cast_nullable_to_non_nullable
                      as List<ServicioModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BarberoModelImplCopyWith<$Res>
    implements $BarberoModelCopyWith<$Res> {
  factory _$$BarberoModelImplCopyWith(
    _$BarberoModelImpl value,
    $Res Function(_$BarberoModelImpl) then,
  ) = __$$BarberoModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String nombre,
    String apellido,
    String telefono,
    String correo,
    String? fotoUrl,
    String biografia,
    int aniosExperiencia,
    List<String> especialidades,
    double ratingPromedio,
    bool disponible,
    bool activo,
    List<ServicioModel> servicios,
  });
}

/// @nodoc
class __$$BarberoModelImplCopyWithImpl<$Res>
    extends _$BarberoModelCopyWithImpl<$Res, _$BarberoModelImpl>
    implements _$$BarberoModelImplCopyWith<$Res> {
  __$$BarberoModelImplCopyWithImpl(
    _$BarberoModelImpl _value,
    $Res Function(_$BarberoModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BarberoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nombre = null,
    Object? apellido = null,
    Object? telefono = null,
    Object? correo = null,
    Object? fotoUrl = freezed,
    Object? biografia = null,
    Object? aniosExperiencia = null,
    Object? especialidades = null,
    Object? ratingPromedio = null,
    Object? disponible = null,
    Object? activo = null,
    Object? servicios = null,
  }) {
    return _then(
      _$BarberoModelImpl(
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
        correo: null == correo
            ? _value.correo
            : correo // ignore: cast_nullable_to_non_nullable
                  as String,
        fotoUrl: freezed == fotoUrl
            ? _value.fotoUrl
            : fotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        biografia: null == biografia
            ? _value.biografia
            : biografia // ignore: cast_nullable_to_non_nullable
                  as String,
        aniosExperiencia: null == aniosExperiencia
            ? _value.aniosExperiencia
            : aniosExperiencia // ignore: cast_nullable_to_non_nullable
                  as int,
        especialidades: null == especialidades
            ? _value._especialidades
            : especialidades // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        ratingPromedio: null == ratingPromedio
            ? _value.ratingPromedio
            : ratingPromedio // ignore: cast_nullable_to_non_nullable
                  as double,
        disponible: null == disponible
            ? _value.disponible
            : disponible // ignore: cast_nullable_to_non_nullable
                  as bool,
        activo: null == activo
            ? _value.activo
            : activo // ignore: cast_nullable_to_non_nullable
                  as bool,
        servicios: null == servicios
            ? _value._servicios
            : servicios // ignore: cast_nullable_to_non_nullable
                  as List<ServicioModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BarberoModelImpl extends _BarberoModel {
  const _$BarberoModelImpl({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.telefono = '',
    this.correo = '',
    this.fotoUrl,
    required this.biografia,
    required this.aniosExperiencia,
    required final List<String> especialidades,
    required this.ratingPromedio,
    required this.disponible,
    this.activo = true,
    required final List<ServicioModel> servicios,
  }) : _especialidades = especialidades,
       _servicios = servicios,
       super._();

  factory _$BarberoModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BarberoModelImplFromJson(json);

  @override
  final String id;
  @override
  final String nombre;
  @override
  final String apellido;
  @override
  @JsonKey()
  final String telefono;
  @override
  @JsonKey()
  final String correo;
  @override
  final String? fotoUrl;
  @override
  final String biografia;
  @override
  final int aniosExperiencia;
  final List<String> _especialidades;
  @override
  List<String> get especialidades {
    if (_especialidades is EqualUnmodifiableListView) return _especialidades;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_especialidades);
  }

  @override
  final double ratingPromedio;
  @override
  final bool disponible;
  @override
  @JsonKey()
  final bool activo;
  final List<ServicioModel> _servicios;
  @override
  List<ServicioModel> get servicios {
    if (_servicios is EqualUnmodifiableListView) return _servicios;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_servicios);
  }

  @override
  String toString() {
    return 'BarberoModel(id: $id, nombre: $nombre, apellido: $apellido, telefono: $telefono, correo: $correo, fotoUrl: $fotoUrl, biografia: $biografia, aniosExperiencia: $aniosExperiencia, especialidades: $especialidades, ratingPromedio: $ratingPromedio, disponible: $disponible, activo: $activo, servicios: $servicios)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BarberoModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nombre, nombre) || other.nombre == nombre) &&
            (identical(other.apellido, apellido) ||
                other.apellido == apellido) &&
            (identical(other.telefono, telefono) ||
                other.telefono == telefono) &&
            (identical(other.correo, correo) || other.correo == correo) &&
            (identical(other.fotoUrl, fotoUrl) || other.fotoUrl == fotoUrl) &&
            (identical(other.biografia, biografia) ||
                other.biografia == biografia) &&
            (identical(other.aniosExperiencia, aniosExperiencia) ||
                other.aniosExperiencia == aniosExperiencia) &&
            const DeepCollectionEquality().equals(
              other._especialidades,
              _especialidades,
            ) &&
            (identical(other.ratingPromedio, ratingPromedio) ||
                other.ratingPromedio == ratingPromedio) &&
            (identical(other.disponible, disponible) ||
                other.disponible == disponible) &&
            (identical(other.activo, activo) || other.activo == activo) &&
            const DeepCollectionEquality().equals(
              other._servicios,
              _servicios,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    nombre,
    apellido,
    telefono,
    correo,
    fotoUrl,
    biografia,
    aniosExperiencia,
    const DeepCollectionEquality().hash(_especialidades),
    ratingPromedio,
    disponible,
    activo,
    const DeepCollectionEquality().hash(_servicios),
  );

  /// Create a copy of BarberoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BarberoModelImplCopyWith<_$BarberoModelImpl> get copyWith =>
      __$$BarberoModelImplCopyWithImpl<_$BarberoModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BarberoModelImplToJson(this);
  }
}

abstract class _BarberoModel extends BarberoModel {
  const factory _BarberoModel({
    required final String id,
    required final String nombre,
    required final String apellido,
    final String telefono,
    final String correo,
    final String? fotoUrl,
    required final String biografia,
    required final int aniosExperiencia,
    required final List<String> especialidades,
    required final double ratingPromedio,
    required final bool disponible,
    final bool activo,
    required final List<ServicioModel> servicios,
  }) = _$BarberoModelImpl;
  const _BarberoModel._() : super._();

  factory _BarberoModel.fromJson(Map<String, dynamic> json) =
      _$BarberoModelImpl.fromJson;

  @override
  String get id;
  @override
  String get nombre;
  @override
  String get apellido;
  @override
  String get telefono;
  @override
  String get correo;
  @override
  String? get fotoUrl;
  @override
  String get biografia;
  @override
  int get aniosExperiencia;
  @override
  List<String> get especialidades;
  @override
  double get ratingPromedio;
  @override
  bool get disponible;
  @override
  bool get activo;
  @override
  List<ServicioModel> get servicios;

  /// Create a copy of BarberoModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BarberoModelImplCopyWith<_$BarberoModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
