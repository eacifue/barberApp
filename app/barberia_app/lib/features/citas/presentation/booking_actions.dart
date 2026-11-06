import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/bsm/bsm.dart';
import '../../barberias/presentation/providers/barbershops_provider.dart';
import '../../barberos/presentation/providers/barberos_provider.dart';
import '../../horarios/presentation/providers/disponibilidad_provider.dart';
import '../../servicios/presentation/providers/servicios_provider.dart';
import '../domain/models/cita_model.dart';
import 'providers/reprogramacion_provider.dart';
import 'providers/reserva_notifier.dart';

/// Precarga servicio y barbero de [cita] y entra directo al paso 3.
/// Con [reprogramar], la cita anterior se cancela al confirmar la nueva;
/// sin él es «Reservar de nuevo». Devuelve `false` si no se pudo iniciar.
Future<bool> iniciarReservaDesdeCita(BuildContext context, WidgetRef ref, CitaModel cita, {required bool reprogramar}) async {
  void avisar(String mensaje) {
    if (context.mounted) showBsmToast(context, mensaje, tone: BsmToastTone.danger);
  }

  try {
    final barbershop = await ref.read(myBarbershopProvider.future);
    if (barbershop == null) {
      avisar('No pudimos cargar la barbería. Inténtalo de nuevo.');
      return false;
    }
    final servicios = await ref.read(serviciosProvider(barbershop.id).future);
    final servicio = servicios.where((s) => s.id == cita.servicio.id && s.activo).firstOrNull;
    if (servicio == null) {
      avisar('Este servicio ya no está disponible. Elige otro para reservar.');
      return false;
    }
    final barberos = await ref.read(barberosPorServicioProvider(servicio.id).future);
    final barbero = barberos.where((b) => b.id == cita.barbero.id).firstOrNull;
    if (barbero == null) {
      avisar('${cita.barbero.nombre} ya no atiende este servicio. Elige otro barbero.');
      return false;
    }

    ref.read(reservaNotifierProvider.notifier)
      ..resetReserva()
      ..seleccionarServicio(servicio)
      ..seleccionarBarbero(barbero);
    await ref.read(disponibilidadNotifierProvider.notifier).reiniciarParaNuevaSeleccion(barberoId: barbero.id, servicioId: servicio.id);
    ref.read(citaIdAReprogramarProvider.notifier).state = reprogramar ? cita.id : null;

    if (context.mounted) context.go('/reservar/horario');
    return true;
  } catch (_) {
    avisar(reprogramar ? 'No pudimos iniciar la reprogramación. Inténtalo de nuevo.' : 'No pudimos iniciar la reserva. Inténtalo de nuevo.');
    return false;
  }
}
