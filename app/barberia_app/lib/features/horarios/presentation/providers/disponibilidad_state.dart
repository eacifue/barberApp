import 'dart:async';

import '../../domain/slot_model.dart';

class DisponibilidadState {
  const DisponibilidadState({
    required this.fechaSeleccionada,
    this.slotSeleccionado,
    this.estaBloqueando = false,
    this.tokenBloqueo,
    this.timerBloqueo,
    this.tiempoRestanteSegundos = 0,
    this.expiracionEventoId = 0,
  });

  final DateTime fechaSeleccionada;
  final SlotModel? slotSeleccionado;
  final bool estaBloqueando;
  final String? tokenBloqueo;
  final Timer? timerBloqueo;
  final int tiempoRestanteSegundos;
  final int expiracionEventoId;

  String get tiempoRestanteTexto {
    final min = (tiempoRestanteSegundos ~/ 60).toString();
    final sec = (tiempoRestanteSegundos % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  DisponibilidadState copyWith({
    DateTime? fechaSeleccionada,
    SlotModel? slotSeleccionado,
    bool clearSlotSeleccionado = false,
    bool? estaBloqueando,
    String? tokenBloqueo,
    bool clearTokenBloqueo = false,
    Timer? timerBloqueo,
    bool clearTimerBloqueo = false,
    int? tiempoRestanteSegundos,
    int? expiracionEventoId,
  }) {
    return DisponibilidadState(
      fechaSeleccionada: fechaSeleccionada ?? this.fechaSeleccionada,
      slotSeleccionado: clearSlotSeleccionado
          ? null
          : slotSeleccionado ?? this.slotSeleccionado,
      estaBloqueando: estaBloqueando ?? this.estaBloqueando,
      tokenBloqueo: clearTokenBloqueo
          ? null
          : tokenBloqueo ?? this.tokenBloqueo,
      timerBloqueo: clearTimerBloqueo
          ? null
          : timerBloqueo ?? this.timerBloqueo,
      tiempoRestanteSegundos:
          tiempoRestanteSegundos ?? this.tiempoRestanteSegundos,
      expiracionEventoId: expiracionEventoId ?? this.expiracionEventoId,
    );
  }
}
