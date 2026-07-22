import 'package:freezed_annotation/freezed_annotation.dart';

import '../../servicios/domain/servicio_model.dart';

part 'barbero_model.freezed.dart';
part 'barbero_model.g.dart';

@freezed
class BarberoModel with _$BarberoModel {
  const BarberoModel._();

  const factory BarberoModel({
    required String id,
    required String nombre,
    required String apellido,
    @Default('') String telefono,
    @Default('') String correo,
    String? fotoUrl,
    required String biografia,
    required int aniosExperiencia,
    required List<String> especialidades,
    required double ratingPromedio,
    required bool disponible,
    @Default(true) bool activo,
    required List<ServicioModel> servicios,
  }) = _BarberoModel;

  factory BarberoModel.fromJson(Map<String, dynamic> json) =>
      _$BarberoModelFromJson(json);

  String get nombreCompleto => ('$nombre $apellido').trim();
  String get ratingText => '${ratingPromedio.toStringAsFixed(1)} ★';
}
