// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'servicio_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServicioModelImpl _$$ServicioModelImplFromJson(Map<String, dynamic> json) =>
    _$ServicioModelImpl(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      tipo: json['tipo'] as String,
      duracionMinutos: (json['duracionMinutos'] as num).toInt(),
      precio: (json['precio'] as num).toDouble(),
      fotoUrl: json['fotoUrl'] as String?,
      activo: json['activo'] as bool,
    );

Map<String, dynamic> _$$ServicioModelImplToJson(_$ServicioModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'descripcion': instance.descripcion,
      'tipo': instance.tipo,
      'duracionMinutos': instance.duracionMinutos,
      'precio': instance.precio,
      'fotoUrl': instance.fotoUrl,
      'activo': instance.activo,
    };
