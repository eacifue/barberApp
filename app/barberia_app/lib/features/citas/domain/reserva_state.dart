import 'package:freezed_annotation/freezed_annotation.dart';

import '../../barberos/domain/barbero_model.dart';
import '../../horarios/domain/slot_model.dart';
import '../../servicios/domain/servicio_model.dart';

part 'reserva_state.freezed.dart';

@freezed
class ReservaState with _$ReservaState {
  const factory ReservaState({
    ServicioModel? servicioSeleccionado,
    BarberoModel? barberoSeleccionado,
    DateTime? fechaSeleccionada,
    SlotModel? slotSeleccionado,
    String? tokenBloqueo,
  }) = _ReservaState;

  factory ReservaState.initial() => const ReservaState();
}
