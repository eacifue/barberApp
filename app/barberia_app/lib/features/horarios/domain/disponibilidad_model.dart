import 'slot_model.dart';

class DisponibilidadModel {
  const DisponibilidadModel({
    required this.barberoId,
    required this.barberoNombre,
    required this.servicioId,
    required this.duracionServicioMin,
    required this.fecha,
    required this.slots,
  });

  final String barberoId;
  final String barberoNombre;
  final String servicioId;
  final int duracionServicioMin;
  final DateTime fecha;
  final List<SlotModel> slots;

  factory DisponibilidadModel.fromJson(Map<String, dynamic> json) {
    return DisponibilidadModel(
      barberoId: (json['barberoId'] ?? '').toString(),
      barberoNombre: (json['barberoNombre'] ?? '').toString(),
      servicioId: (json['servicioId'] ?? '').toString(),
      duracionServicioMin: (json['duracionServicioMin'] as num?)?.toInt() ?? 0,
      fecha:
          DateTime.tryParse((json['fecha'] ?? '').toString()) ?? DateTime.now(),
      slots: (json['slots'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SlotModel.fromJson)
          .toList(),
    );
  }
}
