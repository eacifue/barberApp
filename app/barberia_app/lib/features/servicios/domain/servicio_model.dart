import 'package:freezed_annotation/freezed_annotation.dart';

part 'servicio_model.freezed.dart';
part 'servicio_model.g.dart';

@freezed
class ServicioModel with _$ServicioModel {
  const ServicioModel._();

  const factory ServicioModel({
    required String id,
    required String nombre,
    required String descripcion,
    required String tipo,
    required int duracionMinutos,
    required double precio,
    String? fotoUrl,
    required bool activo,
  }) = _ServicioModel;

  factory ServicioModel.fromJson(Map<String, dynamic> json) =>
      _$ServicioModelFromJson(json);

  String get precioFormateado => '\$${precio.toStringAsFixed(0)}';
  String get duracionFormateada => '$duracionMinutos min';
}
