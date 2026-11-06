import 'package:freezed_annotation/freezed_annotation.dart';

part 'cita_model.freezed.dart';
part 'cita_model.g.dart';

@freezed
class CitaModel with _$CitaModel {
  const CitaModel._();

  const factory CitaModel({
    required String id,
    required String estado,
    required DateTime fechaCita,
    required String horaInicio,
    required String horaFin,
    required double precioFinal,
    String? notas,
    required ClienteResumen cliente,
    required BarberoResumen barbero,
    required ServicioResumen servicio,
    required DateTime createdAt,
    @Default(false) bool tieneReview,
  }) = _CitaModel;

  factory CitaModel.fromJson(Map<String, dynamic> json) =>
      _$CitaModelFromJson(json);
}

@freezed
class ClienteResumen with _$ClienteResumen {
  const factory ClienteResumen({
    required String id,
    required String nombre,
    required String apellido,
    required String telefono,
  }) = _ClienteResumen;

  factory ClienteResumen.fromJson(Map<String, dynamic> json) =>
      _$ClienteResumenFromJson(json);
}

@freezed
class BarberoResumen with _$BarberoResumen {
  const factory BarberoResumen({
    required String id,
    required String nombre,
    required String apellido,
    String? fotoUrl,
  }) = _BarberoResumen;

  factory BarberoResumen.fromJson(Map<String, dynamic> json) =>
      _$BarberoResumenFromJson(json);
}

@freezed
class ServicioResumen with _$ServicioResumen {
  const factory ServicioResumen({
    required String id,
    required String nombre,
    required int duracionMinutos,
    required double precio,
  }) = _ServicioResumen;

  factory ServicioResumen.fromJson(Map<String, dynamic> json) =>
      _$ServicioResumenFromJson(json);
}

class CrearCitaRequestModel {
  const CrearCitaRequestModel({
    required this.barberoId,
    required this.servicioId,
    required this.fechaCita,
    required this.horaInicio,
    required this.tokenRedisBloqueo,
    this.notas,
  });

  final String barberoId;
  final String servicioId;
  final DateTime fechaCita;
  final String horaInicio;
  final String tokenRedisBloqueo;
  final String? notas;
}
