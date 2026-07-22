import 'package:flutter/material.dart';

class SlotModel {
  const SlotModel({
    required this.horaInicio,
    required this.horaFin,
    required this.disponible,
    required this.bloqueadoPorRedis,
    this.minutosRestantesBloqueo,
  });

  final TimeOfDay horaInicio;
  final TimeOfDay horaFin;
  final bool disponible;
  final bool bloqueadoPorRedis;
  final int? minutosRestantesBloqueo;

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      horaInicio: _timeFrom(json['horaInicio']),
      horaFin: _timeFrom(json['horaFin']),
      disponible: json['disponible'] as bool? ?? false,
      bloqueadoPorRedis: json['bloqueadoPorRedis'] as bool? ?? false,
      minutosRestantesBloqueo: (json['minutosRestantesBloqueo'] as num?)
          ?.toInt(),
    );
  }

  String get horaInicioFormateada =>
      '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}';

  String get horaFinFormateada =>
      '${horaFin.hour.toString().padLeft(2, '0')}:${horaFin.minute.toString().padLeft(2, '0')}';
}

TimeOfDay _timeFrom(Object? value) {
  if (value is String && value.contains(':')) {
    final parts = value.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  return const TimeOfDay(hour: 0, minute: 0);
}
