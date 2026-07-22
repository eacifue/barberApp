// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barbero_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BarberoModelImpl _$$BarberoModelImplFromJson(Map<String, dynamic> json) =>
    _$BarberoModelImpl(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      telefono: json['telefono'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      fotoUrl: json['fotoUrl'] as String?,
      biografia: json['biografia'] as String,
      aniosExperiencia: (json['aniosExperiencia'] as num).toInt(),
      especialidades: (json['especialidades'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      ratingPromedio: (json['ratingPromedio'] as num).toDouble(),
      disponible: json['disponible'] as bool,
      activo: json['activo'] as bool? ?? true,
      servicios: (json['servicios'] as List<dynamic>)
          .map((e) => ServicioModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$BarberoModelImplToJson(_$BarberoModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'apellido': instance.apellido,
      'telefono': instance.telefono,
      'correo': instance.correo,
      'fotoUrl': instance.fotoUrl,
      'biografia': instance.biografia,
      'aniosExperiencia': instance.aniosExperiencia,
      'especialidades': instance.especialidades,
      'ratingPromedio': instance.ratingPromedio,
      'disponible': instance.disponible,
      'activo': instance.activo,
      'servicios': instance.servicios,
    };
