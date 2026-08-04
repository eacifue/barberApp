import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../barberias/presentation/providers/barbershops_provider.dart';
import '../../../citas/presentation/providers/reserva_notifier.dart';
import '../../data/bloqueo_repository.dart';
import '../../domain/slot_model.dart';
import 'disponibilidad_provider.dart';
import 'disponibilidad_state.dart';

class DisponibilidadNotifier extends StateNotifier<DisponibilidadState> {
  DisponibilidadNotifier(this._ref)
    : _bloqueoRepository = _ref.read(bloqueoRepositoryProvider),
      super(
        DisponibilidadState(fechaSeleccionada: _soloFecha(DateTime.now())),
      ) {
    state = state.copyWith(
      fechaSeleccionada: _siguienteFechaHabil(state.fechaSeleccionada),
    );
  }

  final Ref _ref;
  final BloqueoRepository _bloqueoRepository;

  /// Whether the barbershop is open on [date]'s weekday. Falls back to
  /// "open" when the barbershop isn't resolved yet, so the calendar never
  /// blocks booking on a data-loading hiccup.
  bool _esDiaLaborable(DateTime date) {
    final barbershop = _ref.read(myBarbershopProvider).valueOrNull;
    if (barbershop == null) {
      return true;
    }

    return barbershop.esDiaLaborable(date);
  }

  Future<void> reiniciarParaNuevaSeleccion({
    required String barberoId,
    required String servicioId,
  }) async {
    await _liberarBloqueoYLimpiar(barberoId: barberoId);

    final fechaDefault = _siguienteFechaHabil(_soloFecha(DateTime.now()));
    state = state.copyWith(
      fechaSeleccionada: fechaDefault,
      clearSlotSeleccionado: true,
      clearTokenBloqueo: true,
      tiempoRestanteSegundos: 0,
    );

    _ref.read(reservaNotifierProvider.notifier).seleccionarFecha(fechaDefault);

    _ref.invalidate(
      disponibilidadProvider(
        barberoId: barberoId,
        servicioId: servicioId,
        fecha: fechaDefault,
      ),
    );
  }

  Future<void> seleccionarFecha({
    required DateTime fecha,
    required String barberoId,
    required String servicioId,
  }) async {
    await _liberarBloqueoYLimpiar(barberoId: barberoId);

    final nuevaFecha = _soloFecha(fecha);
    state = state.copyWith(
      fechaSeleccionada: nuevaFecha,
      clearSlotSeleccionado: true,
      clearTokenBloqueo: true,
      tiempoRestanteSegundos: 0,
    );

    _ref.read(reservaNotifierProvider.notifier).seleccionarFecha(nuevaFecha);

    _ref.invalidate(
      disponibilidadProvider(
        barberoId: barberoId,
        servicioId: servicioId,
        fecha: nuevaFecha,
      ),
    );
  }

  Future<String?> seleccionarSlot({
    required SlotModel slot,
    required String barberoId,
    required String servicioId,
  }) async {
    if (!slot.disponible || slot.bloqueadoPorRedis) {
      return 'Slot tomado, elige otro';
    }

    await _liberarBloqueoYLimpiar(barberoId: barberoId);

    state = state.copyWith(estaBloqueando: true);

    try {
      final result = await _bloqueoRepository.bloquearSlot(
        barberoId: barberoId,
        servicioId: servicioId,
        fecha: state.fechaSeleccionada,
        horaInicio: slot.horaInicio,
      );

      if (!result.exitoso || result.tokenBloqueo == null) {
        state = state.copyWith(estaBloqueando: false);
        return result.mensajeError ?? 'Slot tomado, elige otro';
      }

      final ttl = result.expiresInSeconds ?? 300;
      _iniciarTimerBloqueo(ttl, barberoId);

      state = state.copyWith(
        slotSeleccionado: slot,
        tokenBloqueo: result.tokenBloqueo,
        estaBloqueando: false,
        tiempoRestanteSegundos: ttl,
      );

      _ref
          .read(reservaNotifierProvider.notifier)
          .seleccionarSlot(slot, tokenBloqueo: result.tokenBloqueo);

      return null;
    } catch (_) {
      state = state.copyWith(
        estaBloqueando: false,
        clearSlotSeleccionado: true,
        clearTokenBloqueo: true,
      );
      return 'Slot tomado, elige otro';
    }
  }

  Future<void> salirPantalla({required String barberoId}) async {
    await _liberarBloqueoYLimpiar(barberoId: barberoId);
  }

  void _iniciarTimerBloqueo(int segundos, String barberoId) {
    state.timerBloqueo?.cancel();

    final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.tiempoRestanteSegundos <= 0) {
        timer.cancel();
        unawaited(_manejarExpiracion(barberoId));
      } else {
        state = state.copyWith(
          tiempoRestanteSegundos: state.tiempoRestanteSegundos - 1,
        );
      }
    });

    state = state.copyWith(
      timerBloqueo: timer,
      tiempoRestanteSegundos: segundos,
    );
  }

  Future<void> _manejarExpiracion(String barberoId) async {
    await _liberarBloqueoYLimpiar(barberoId: barberoId);
    state = state.copyWith(expiracionEventoId: state.expiracionEventoId + 1);
  }

  Future<void> _liberarBloqueoYLimpiar({required String barberoId}) async {
    final token = state.tokenBloqueo;
    final slot = state.slotSeleccionado;

    state.timerBloqueo?.cancel();

    if (token != null && slot != null) {
      try {
        await _bloqueoRepository.liberarSlot(
          tokenBloqueo: token,
          barberoId: barberoId,
          fecha: state.fechaSeleccionada,
          horaInicio: slot.horaInicio,
        );
      } catch (_) {
        // Best effort: si falla, limpiamos estado local para no dejar UI bloqueada.
      }
    }

    state = state.copyWith(
      clearSlotSeleccionado: true,
      clearTokenBloqueo: true,
      clearTimerBloqueo: true,
      tiempoRestanteSegundos: 0,
      estaBloqueando: false,
    );

    _ref.read(reservaNotifierProvider.notifier).limpiarSlotYToken();
  }

  DateTime _siguienteFechaHabil(DateTime date) {
    var candidate = _soloFecha(date);
    var intentos = 0;
    while (!_esDiaLaborable(candidate) && intentos < 7) {
      candidate = candidate.add(const Duration(days: 1));
      intentos++;
    }
    return candidate;
  }

  @override
  void dispose() {
    state.timerBloqueo?.cancel();
    super.dispose();
  }
}

DateTime _soloFecha(DateTime date) => DateTime(date.year, date.month, date.day);
