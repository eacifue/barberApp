// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reserva_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ReservaState {
  ServicioModel? get servicioSeleccionado => throw _privateConstructorUsedError;
  BarberoModel? get barberoSeleccionado => throw _privateConstructorUsedError;
  DateTime? get fechaSeleccionada => throw _privateConstructorUsedError;
  SlotModel? get slotSeleccionado => throw _privateConstructorUsedError;
  String? get tokenBloqueo => throw _privateConstructorUsedError;

  /// Create a copy of ReservaState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReservaStateCopyWith<ReservaState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReservaStateCopyWith<$Res> {
  factory $ReservaStateCopyWith(
    ReservaState value,
    $Res Function(ReservaState) then,
  ) = _$ReservaStateCopyWithImpl<$Res, ReservaState>;
  @useResult
  $Res call({
    ServicioModel? servicioSeleccionado,
    BarberoModel? barberoSeleccionado,
    DateTime? fechaSeleccionada,
    SlotModel? slotSeleccionado,
    String? tokenBloqueo,
  });

  $ServicioModelCopyWith<$Res>? get servicioSeleccionado;
  $BarberoModelCopyWith<$Res>? get barberoSeleccionado;
}

/// @nodoc
class _$ReservaStateCopyWithImpl<$Res, $Val extends ReservaState>
    implements $ReservaStateCopyWith<$Res> {
  _$ReservaStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReservaState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? servicioSeleccionado = freezed,
    Object? barberoSeleccionado = freezed,
    Object? fechaSeleccionada = freezed,
    Object? slotSeleccionado = freezed,
    Object? tokenBloqueo = freezed,
  }) {
    return _then(
      _value.copyWith(
            servicioSeleccionado: freezed == servicioSeleccionado
                ? _value.servicioSeleccionado
                : servicioSeleccionado // ignore: cast_nullable_to_non_nullable
                      as ServicioModel?,
            barberoSeleccionado: freezed == barberoSeleccionado
                ? _value.barberoSeleccionado
                : barberoSeleccionado // ignore: cast_nullable_to_non_nullable
                      as BarberoModel?,
            fechaSeleccionada: freezed == fechaSeleccionada
                ? _value.fechaSeleccionada
                : fechaSeleccionada // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            slotSeleccionado: freezed == slotSeleccionado
                ? _value.slotSeleccionado
                : slotSeleccionado // ignore: cast_nullable_to_non_nullable
                      as SlotModel?,
            tokenBloqueo: freezed == tokenBloqueo
                ? _value.tokenBloqueo
                : tokenBloqueo // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of ReservaState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ServicioModelCopyWith<$Res>? get servicioSeleccionado {
    if (_value.servicioSeleccionado == null) {
      return null;
    }

    return $ServicioModelCopyWith<$Res>(_value.servicioSeleccionado!, (value) {
      return _then(_value.copyWith(servicioSeleccionado: value) as $Val);
    });
  }

  /// Create a copy of ReservaState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BarberoModelCopyWith<$Res>? get barberoSeleccionado {
    if (_value.barberoSeleccionado == null) {
      return null;
    }

    return $BarberoModelCopyWith<$Res>(_value.barberoSeleccionado!, (value) {
      return _then(_value.copyWith(barberoSeleccionado: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReservaStateImplCopyWith<$Res>
    implements $ReservaStateCopyWith<$Res> {
  factory _$$ReservaStateImplCopyWith(
    _$ReservaStateImpl value,
    $Res Function(_$ReservaStateImpl) then,
  ) = __$$ReservaStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ServicioModel? servicioSeleccionado,
    BarberoModel? barberoSeleccionado,
    DateTime? fechaSeleccionada,
    SlotModel? slotSeleccionado,
    String? tokenBloqueo,
  });

  @override
  $ServicioModelCopyWith<$Res>? get servicioSeleccionado;
  @override
  $BarberoModelCopyWith<$Res>? get barberoSeleccionado;
}

/// @nodoc
class __$$ReservaStateImplCopyWithImpl<$Res>
    extends _$ReservaStateCopyWithImpl<$Res, _$ReservaStateImpl>
    implements _$$ReservaStateImplCopyWith<$Res> {
  __$$ReservaStateImplCopyWithImpl(
    _$ReservaStateImpl _value,
    $Res Function(_$ReservaStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReservaState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? servicioSeleccionado = freezed,
    Object? barberoSeleccionado = freezed,
    Object? fechaSeleccionada = freezed,
    Object? slotSeleccionado = freezed,
    Object? tokenBloqueo = freezed,
  }) {
    return _then(
      _$ReservaStateImpl(
        servicioSeleccionado: freezed == servicioSeleccionado
            ? _value.servicioSeleccionado
            : servicioSeleccionado // ignore: cast_nullable_to_non_nullable
                  as ServicioModel?,
        barberoSeleccionado: freezed == barberoSeleccionado
            ? _value.barberoSeleccionado
            : barberoSeleccionado // ignore: cast_nullable_to_non_nullable
                  as BarberoModel?,
        fechaSeleccionada: freezed == fechaSeleccionada
            ? _value.fechaSeleccionada
            : fechaSeleccionada // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        slotSeleccionado: freezed == slotSeleccionado
            ? _value.slotSeleccionado
            : slotSeleccionado // ignore: cast_nullable_to_non_nullable
                  as SlotModel?,
        tokenBloqueo: freezed == tokenBloqueo
            ? _value.tokenBloqueo
            : tokenBloqueo // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ReservaStateImpl implements _ReservaState {
  const _$ReservaStateImpl({
    this.servicioSeleccionado,
    this.barberoSeleccionado,
    this.fechaSeleccionada,
    this.slotSeleccionado,
    this.tokenBloqueo,
  });

  @override
  final ServicioModel? servicioSeleccionado;
  @override
  final BarberoModel? barberoSeleccionado;
  @override
  final DateTime? fechaSeleccionada;
  @override
  final SlotModel? slotSeleccionado;
  @override
  final String? tokenBloqueo;

  @override
  String toString() {
    return 'ReservaState(servicioSeleccionado: $servicioSeleccionado, barberoSeleccionado: $barberoSeleccionado, fechaSeleccionada: $fechaSeleccionada, slotSeleccionado: $slotSeleccionado, tokenBloqueo: $tokenBloqueo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReservaStateImpl &&
            (identical(other.servicioSeleccionado, servicioSeleccionado) ||
                other.servicioSeleccionado == servicioSeleccionado) &&
            (identical(other.barberoSeleccionado, barberoSeleccionado) ||
                other.barberoSeleccionado == barberoSeleccionado) &&
            (identical(other.fechaSeleccionada, fechaSeleccionada) ||
                other.fechaSeleccionada == fechaSeleccionada) &&
            (identical(other.slotSeleccionado, slotSeleccionado) ||
                other.slotSeleccionado == slotSeleccionado) &&
            (identical(other.tokenBloqueo, tokenBloqueo) ||
                other.tokenBloqueo == tokenBloqueo));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    servicioSeleccionado,
    barberoSeleccionado,
    fechaSeleccionada,
    slotSeleccionado,
    tokenBloqueo,
  );

  /// Create a copy of ReservaState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReservaStateImplCopyWith<_$ReservaStateImpl> get copyWith =>
      __$$ReservaStateImplCopyWithImpl<_$ReservaStateImpl>(this, _$identity);
}

abstract class _ReservaState implements ReservaState {
  const factory _ReservaState({
    final ServicioModel? servicioSeleccionado,
    final BarberoModel? barberoSeleccionado,
    final DateTime? fechaSeleccionada,
    final SlotModel? slotSeleccionado,
    final String? tokenBloqueo,
  }) = _$ReservaStateImpl;

  @override
  ServicioModel? get servicioSeleccionado;
  @override
  BarberoModel? get barberoSeleccionado;
  @override
  DateTime? get fechaSeleccionada;
  @override
  SlotModel? get slotSeleccionado;
  @override
  String? get tokenBloqueo;

  /// Create a copy of ReservaState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReservaStateImplCopyWith<_$ReservaStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
