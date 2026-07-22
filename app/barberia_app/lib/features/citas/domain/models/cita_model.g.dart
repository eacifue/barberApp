// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cita_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CitaModelImpl _$$CitaModelImplFromJson(Map<String, dynamic> json) =>
    _$CitaModelImpl(
      id: json['id'] as String,
      estado: json['estado'] as String,
      fechaCita: DateTime.parse(json['fechaCita'] as String),
      horaInicio: json['horaInicio'] as String,
      horaFin: json['horaFin'] as String,
      precioFinal: (json['precioFinal'] as num).toDouble(),
      notas: json['notas'] as String?,
      cliente: ClienteResumen.fromJson(json['cliente'] as Map<String, dynamic>),
      barbero: BarberoResumen.fromJson(json['barbero'] as Map<String, dynamic>),
      servicio: ServicioResumen.fromJson(
        json['servicio'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CitaModelImplToJson(_$CitaModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'estado': instance.estado,
      'fechaCita': instance.fechaCita.toIso8601String(),
      'horaInicio': instance.horaInicio,
      'horaFin': instance.horaFin,
      'precioFinal': instance.precioFinal,
      'notas': instance.notas,
      'cliente': instance.cliente,
      'barbero': instance.barbero,
      'servicio': instance.servicio,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$ClienteResumenImpl _$$ClienteResumenImplFromJson(Map<String, dynamic> json) =>
    _$ClienteResumenImpl(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      telefono: json['telefono'] as String,
    );

Map<String, dynamic> _$$ClienteResumenImplToJson(
  _$ClienteResumenImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'nombre': instance.nombre,
  'apellido': instance.apellido,
  'telefono': instance.telefono,
};

_$BarberoResumenImpl _$$BarberoResumenImplFromJson(Map<String, dynamic> json) =>
    _$BarberoResumenImpl(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      fotoUrl: json['fotoUrl'] as String?,
    );

Map<String, dynamic> _$$BarberoResumenImplToJson(
  _$BarberoResumenImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'nombre': instance.nombre,
  'apellido': instance.apellido,
  'fotoUrl': instance.fotoUrl,
};

_$ServicioResumenImpl _$$ServicioResumenImplFromJson(
  Map<String, dynamic> json,
) => _$ServicioResumenImpl(
  id: json['id'] as String,
  nombre: json['nombre'] as String,
  duracionMinutos: (json['duracionMinutos'] as num).toInt(),
  precio: (json['precio'] as num).toDouble(),
);

Map<String, dynamic> _$$ServicioResumenImplToJson(
  _$ServicioResumenImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'nombre': instance.nombre,
  'duracionMinutos': instance.duracionMinutos,
  'precio': instance.precio,
};
