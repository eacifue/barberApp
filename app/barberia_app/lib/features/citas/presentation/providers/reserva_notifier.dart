import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../barberos/domain/barbero_model.dart';
import '../../../horarios/domain/slot_model.dart';
import '../../domain/reserva_state.dart';
import '../../../servicios/domain/servicio_model.dart';

final reservaNotifierProvider =
    StateNotifierProvider<ReservaNotifier, ReservaState>((ref) {
      return ReservaNotifier();
    });

class ReservaNotifier extends StateNotifier<ReservaState> {
  ReservaNotifier() : super(ReservaState.initial());

  void seleccionarServicio(ServicioModel servicio) {
    state = state.copyWith(
      servicioSeleccionado: servicio,
      barberoSeleccionado: null,
      fechaSeleccionada: null,
      slotSeleccionado: null,
      tokenBloqueo: null,
    );
  }

  void seleccionarBarbero(BarberoModel barbero) {
    state = state.copyWith(
      barberoSeleccionado: barbero,
      fechaSeleccionada: null,
      slotSeleccionado: null,
      tokenBloqueo: null,
    );
  }

  void seleccionarFecha(DateTime fecha) {
    state = state.copyWith(
      fechaSeleccionada: fecha,
      slotSeleccionado: null,
      tokenBloqueo: null,
    );
  }

  void seleccionarSlot(SlotModel slot, {String? tokenBloqueo}) {
    state = state.copyWith(slotSeleccionado: slot, tokenBloqueo: tokenBloqueo);
  }

  void limpiarSlotYToken() {
    state = state.copyWith(slotSeleccionado: null, tokenBloqueo: null);
  }

  void resetReserva() {
    state = ReservaState.initial();
  }
}
