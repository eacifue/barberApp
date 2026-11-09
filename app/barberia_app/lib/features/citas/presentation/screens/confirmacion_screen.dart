import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/errors/error_message.dart';
import '../../../../core/services/permiso_notificaciones.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/horarios/presentation/providers/disponibilidad_provider.dart';
import '../../../../features/horarios/presentation/providers/disponibilidad_state.dart';
import '../../../../shared/format/formato.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../../barberias/presentation/providers/barbershops_provider.dart';
import '../../domain/models/cita_model.dart';
import '../providers/citas_provider.dart';
import '../providers/reprogramacion_provider.dart';
import '../providers/reserva_notifier.dart';
import '../widgets/booking_scaffold.dart';

/// Paso 4 · Confirma tu reserva: cuenta regresiva arriba, resumen, nota
/// opcional y «Reservar ahora» en la barra fija. En reprogramación, aviso
/// `info` y «Confirmar nuevo horario» (design/pantallas/app-movil/Reserva-4-Confirmar).
class ConfirmacionScreen extends ConsumerStatefulWidget {
  const ConfirmacionScreen({super.key});

  @override
  ConsumerState<ConfirmacionScreen> createState() => _ConfirmacionScreenState();
}

class _ConfirmacionScreenState extends ConsumerState<ConfirmacionScreen> {
  final _notas = TextEditingController();
  bool _enviando = false;
  late final ProviderSubscription<DisponibilidadState> _sub;

  @override
  void initState() {
    super.initState();
    _sub = ref.listenManual<DisponibilidadState>(disponibilidadNotifierProvider, (prev, next) {
      if (next.expiracionEventoId > (prev?.expiracionEventoId ?? 0) && mounted && !_enviando) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _avisarExpiracion());
      }
    });
  }

  @override
  void dispose() {
    _sub.close();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _avisarExpiracion() async {
    if (!mounted) return;
    await showBsmConfirm(
      context,
      tone: BsmConfirmTone.info,
      icon: LucideIcons.timer,
      title: 'Tu horario se liberó',
      body: 'Pasaron 5 minutos sin confirmar. Elige de nuevo; puede que siga libre.',
      confirmLabel: 'Elegir horario',
      cancelLabel: 'Cerrar',
    );
    if (mounted) context.go('/reservar/horario');
  }

  Future<void> _salirSinReservar(String barberoId, DateTime inicio) async {
    final salir = await showBsmConfirm(
      context,
      icon: LucideIcons.timer,
      title: '¿Salir sin reservar?',
      body: 'Tu horario apartado del ${Formato.fechaLarga(inicio)} a las ${Formato.hora(inicio)} se liberará y otra persona podrá tomarlo.',
      confirmLabel: 'Salir',
      cancelLabel: 'Seguir reservando',
    );
    if (!salir || !mounted) return;
    final router = GoRouter.of(context);
    await ref.read(disponibilidadNotifierProvider.notifier).salirPantalla(barberoId: barberoId);
    ref.read(reservaNotifierProvider.notifier).resetReserva();
    ref.read(citaIdAReprogramarProvider.notifier).state = null;
    router.go('/dashboard');
  }

  Future<void> _reservar({
    required String barberiaId,
    required String barberoId,
    required String servicioId,
    required DateTime fecha,
    required String hora,
    required String token,
    required String? citaAnterior,
  }) async {
    setState(() => _enviando = true);
    final router = GoRouter.of(context);
    final repo = ref.read(citaRepositoryProvider);
    try {
      final notas = _notas.text.trim();
      final cita = await repo.crearCita(
        CrearCitaRequestModel(
          barberoId: barberoId,
          servicioId: servicioId,
          fechaCita: fecha,
          horaInicio: hora,
          tokenRedisBloqueo: token,
          notas: notas.isEmpty ? null : notas,
        ),
      );

      ref.invalidate(misCitasProvider(barberiaId));
      await ref.read(disponibilidadNotifierProvider.notifier).salirPantalla(barberoId: barberoId);
      ref.read(reservaNotifierProvider.notifier).resetReserva();

      if (citaAnterior != null) {
        try {
          await repo.cancelarCita(citaAnterior, motivo: 'Reprogramada por el cliente');
          ref.invalidate(citaByIdProvider(citaAnterior));
        } catch (_) {
          if (mounted) {
            showBsmToast(
              context,
              'Tu nueva cita quedó confirmada, pero no pudimos cancelar la anterior. Cancélala desde Mis citas.',
              tone: BsmToastTone.warning,
            );
          }
        } finally {
          ref.read(citaIdAReprogramarProvider.notifier).state = null;
        }
      }

      // Si en el onboarding eligió «Ahora no», este es el momento de ofrecer los recordatorios.
      unawaited(ref.read(permisoNotificacionesProvider).pedirSiPospuesto());
      router.go('/reservar/exito', extra: cita);
    } catch (e) {
      if (!mounted) return;
      if (esErrorDeValidacion(e)) {
        // En este paso, la validación casi siempre es «otro cliente tomó el horario».
        showBsmToast(context, 'Ese horario ya no está disponible. Elige otro.', tone: BsmToastTone.danger);
        router.go('/reservar/horario');
      } else {
        showBsmToast(context, mensajeDeError(e, 'No pudimos confirmar tu reserva. Inténtalo de nuevo.'), tone: BsmToastTone.danger);
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final reserva = ref.watch(reservaNotifierProvider);
    final estado = ref.watch(disponibilidadNotifierProvider);
    final barbershopAsync = ref.watch(myBarbershopProvider);
    final citaAnteriorId = ref.watch(citaIdAReprogramarProvider);
    final citaAnterior = citaAnteriorId == null ? null : ref.watch(citaByIdProvider(citaAnteriorId)).valueOrNull;

    final servicio = reserva.servicioSeleccionado;
    final barbero = reserva.barberoSeleccionado;
    final slot = reserva.slotSeleccionado;
    final fecha = reserva.fechaSeleccionada;
    final token = reserva.tokenBloqueo;

    if (servicio == null || barbero == null || slot == null || fecha == null || token == null) {
      return BookingScaffold(
        step: 4,
        title: 'Confirma tu reserva',
        onBack: () => context.go('/reservar/horario'),
        children: [
          BsmEmptyState(
            icon: LucideIcons.calendarClock,
            title: 'Tu reserva no está completa',
            body: 'Elige servicio, barbero y horario para confirmar.',
            actionLabel: 'Elegir servicio',
            onAction: () => context.go('/reservar/servicio'),
          ),
        ],
      );
    }

    final barbershop = barbershopAsync.valueOrNull;
    final precio = barbero.servicios.where((s) => s.id == servicio.id).firstOrNull?.precio ?? servicio.precio;
    final inicio = fechaConHora(fecha, slot.horaInicioFormateada);
    final fin = inicio.add(Duration(minutes: servicio.duracionMinutos));
    final reprogramando = citaAnteriorId != null;

    final resumen = SummaryCard(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Overline('Servicio'),
            const SizedBox(height: AppSpace.s1),
            Row(
              children: [
                Expanded(child: Text(servicio.nombre, style: AppTextStyles.titleSm.copyWith(color: p.ink))),
                Text(Formato.duracion(servicio.duracionMinutos), style: AppTextStyles.body.copyWith(color: p.inkMuted)),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Overline('Barbero'),
            const SizedBox(height: AppSpace.s2),
            Row(
              children: [
                BsmAvatar(name: barbero.nombreCompleto, photoUrl: barbero.fotoUrl, size: 32),
                const SizedBox(width: AppSpace.s3),
                Expanded(child: Text(barbero.nombreCompleto, style: AppTextStyles.label.copyWith(color: p.ink))),
                BsmRating(value: barbero.ratingPromedio > 0 ? barbero.ratingPromedio : null, compact: true),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Overline('Fecha y hora'),
            const SizedBox(height: AppSpace.s1),
            Text(capitalizar(Formato.fechaLarga(inicio)), style: AppTextStyles.titleSm.copyWith(color: p.ink)),
            Text(Formato.rango(inicio, fin), style: AppTextStyles.body.copyWith(color: p.inkMuted)),
          ],
        ),
        if (barbershop != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Overline('Lugar'),
              const SizedBox(height: AppSpace.s1),
              Text('${barbershop.nombre} · ${barbershop.direccionCompleta}', style: AppTextStyles.body.copyWith(color: p.ink)),
            ],
          ),
        Row(
          children: [
            Icon(LucideIcons.banknote, size: 20, color: p.inkMuted),
            const SizedBox(width: AppSpace.s2),
            Expanded(child: Text('Pago en el local', style: AppTextStyles.body.copyWith(color: p.inkMuted))),
            Text(Formato.dinero(precio), style: AppTextStyles.title.copyWith(color: p.ink, fontFeatures: const [FontFeature.tabularFigures()])),
          ],
        ),
      ],
    );

    String? cuerpoReprogramacion() {
      if (citaAnterior == null) return 'Al confirmar, la anterior se cancela automáticamente.';
      final anterior = fechaConHora(citaAnterior.fechaCita, citaAnterior.horaInicio);
      return 'Al confirmar, tu cita del ${Formato.fechaLarga(anterior)} a las ${Formato.hora(anterior)} se cancela automáticamente.';
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_enviando) context.go('/reservar/horario');
      },
      child: BookingScaffold(
        step: 4,
        title: 'Confirma tu reserva',
        onBack: _enviando ? null : () => context.go('/reservar/horario'),
        backLabel: 'Volver a fecha y hora',
        bottom: BookingBottomBar(
          label: _enviando ? 'Reservando…' : (reprogramando ? 'Confirmar nuevo horario' : 'Reservar ahora'),
          loading: _enviando,
          onPressed: () => _reservar(
            barberiaId: barbershop?.id ?? '',
            barberoId: barbero.id,
            servicioId: servicio.id,
            fecha: fecha,
            hora: slot.horaInicioFormateada,
            token: token,
            citaAnterior: citaAnteriorId,
          ),
        ),
        children: [
          BsmCountdownView(seconds: estado.tiempoRestanteSegundos, compact: true, label: 'Completa tu reserva en'),
          if (reprogramando) ...[
            const SizedBox(height: AppSpace.s4),
            BsmBanner(icon: LucideIcons.calendarClock, title: 'Estás reprogramando tu cita', body: cuerpoReprogramacion()),
          ],
          const SizedBox(height: AppSpace.s4),
          Semantics(label: 'Resumen de la reserva', container: true, child: resumen),
          const SizedBox(height: AppSpace.s5),
          BsmTextField(
            controller: _notas,
            label: 'Alguna nota para el barbero',
            optional: true,
            maxLines: 3,
            placeholder: 'Ej.: degradado bajo, no tocar la barba',
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: AppSpace.s4),
          Align(
            alignment: Alignment.centerLeft,
            child: BsmButton(
              label: 'Cancelar reserva',
              variant: BsmButtonVariant.dangerGhost,
              onPressed: _enviando ? null : () => _salirSinReservar(barbero.id, inicio),
            ),
          ),
        ],
      ),
    );
  }
}
