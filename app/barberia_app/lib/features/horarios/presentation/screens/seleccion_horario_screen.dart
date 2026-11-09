import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/citas/presentation/providers/reprogramacion_provider.dart';
import '../../../../features/citas/presentation/providers/reserva_notifier.dart';
import '../../../../features/citas/presentation/widgets/booking_scaffold.dart';
import '../../../../shared/format/formato.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../../barberias/presentation/providers/barbershops_provider.dart';
import '../../domain/slot_model.dart';
import '../providers/disponibilidad_provider.dart';
import '../providers/disponibilidad_state.dart';

/// Paso 3 · Elige fecha y hora. Al tocar un horario se aparta 5 minutos en el
/// servidor; la cuenta regresiva vive pegada a la barra inferior
/// (design/pantallas/app-movil/Reserva-3-Horario y sus estados).
class SeleccionHorarioScreen extends ConsumerStatefulWidget {
  const SeleccionHorarioScreen({super.key});

  @override
  ConsumerState<SeleccionHorarioScreen> createState() => _SeleccionHorarioScreenState();
}

class _SeleccionHorarioScreenState extends ConsumerState<SeleccionHorarioScreen> {
  static const _diasVisibles = 60;

  late DateTime _mes;
  late final ProviderSubscription<DisponibilidadState> _sub;

  DateTime get _hoy {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    final fecha = ref.read(disponibilidadNotifierProvider).fechaSeleccionada;
    _mes = DateTime(fecha.year, fecha.month);
    _sub = ref.listenManual<DisponibilidadState>(disponibilidadNotifierProvider, (prev, next) {
      final antes = prev?.tiempoRestanteSegundos ?? 0;
      if (antes > 60 && next.tiempoRestanteSegundos <= 60 && next.tiempoRestanteSegundos > 0) {
        HapticFeedback.mediumImpact();
      }
      if (next.expiracionEventoId > (prev?.expiracionEventoId ?? 0) && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _avisarExpiracion());
      }
    });
  }

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }

  Future<void> _avisarExpiracion() async {
    if (!mounted) return;
    final elegirOtro = await showBsmConfirm(
      context,
      tone: BsmConfirmTone.info,
      icon: LucideIcons.timer,
      title: 'Tu horario se liberó',
      body: 'Pasaron 5 minutos sin confirmar. Elige de nuevo; puede que siga libre.',
      confirmLabel: 'Elegir horario',
      cancelLabel: 'Volver al inicio',
    );
    if (!mounted || elegirOtro) return;
    ref.read(reservaNotifierProvider.notifier).resetReserva();
    ref.read(citaIdAReprogramarProvider.notifier).state = null;
    context.go('/dashboard');
  }

  Future<void> _volver(String barberoId) async {
    final router = GoRouter.of(context);
    await ref.read(disponibilidadNotifierProvider.notifier).salirPantalla(barberoId: barberoId);
    router.go('/reservar/barbero');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final reserva = ref.watch(reservaNotifierProvider);
    final estado = ref.watch(disponibilidadNotifierProvider);
    final notifier = ref.read(disponibilidadNotifierProvider.notifier);
    final barbero = reserva.barberoSeleccionado;
    final servicio = reserva.servicioSeleccionado;

    if (barbero == null || servicio == null) {
      return BookingScaffold(
        step: 3,
        title: 'Elige fecha y hora',
        onBack: () => context.go('/reservar/servicio'),
        children: [
          BsmEmptyState(
            icon: LucideIcons.calendarClock,
            title: 'Primero elige servicio y barbero',
            body: 'Así te mostramos los horarios libres.',
            actionLabel: 'Elegir servicio',
            onAction: () => context.go('/reservar/servicio'),
          ),
        ],
      );
    }

    final barbershop = ref.watch(myBarbershopProvider).valueOrNull;
    final ultimoDia = _hoy.add(const Duration(days: _diasVisibles));
    bool deshabilitado(DateTime d) =>
        d.isBefore(_hoy) || d.isAfter(ultimoDia) || (barbershop != null && !barbershop.esDiaLaborable(d));

    final fecha = estado.fechaSeleccionada;
    final slotsAsync = ref.watch(disponibilidadProvider(barberoId: barbero.id, servicioId: servicio.id, fecha: fecha));
    final precio = barbero.servicios.where((s) => s.id == servicio.id).firstOrNull?.precio ?? servicio.precio;
    final slot = estado.slotSeleccionado;

    DateTime? proximoDiaHabil() {
      var d = fecha.add(const Duration(days: 1));
      while (!d.isAfter(ultimoDia)) {
        if (!deshabilitado(d)) return d;
        d = d.add(const Duration(days: 1));
      }
      return null;
    }

    Future<void> elegirFecha(DateTime d) async {
      setState(() => _mes = DateTime(d.year, d.month));
      await notifier.seleccionarFecha(fecha: d, barberoId: barbero.id, servicioId: servicio.id);
    }

    Future<void> elegirSlot(SlotItem item, List<SlotModel> slots) async {
      final elegido = slots.firstWhere((s) => s.horaInicioFormateada == item.key);
      final error = await notifier.seleccionarSlot(slot: elegido, barberoId: barbero.id, servicioId: servicio.id);
      if (!mounted || error == null) return;
      showBsmToast(context, 'Ese horario ya no está disponible. Elige otro.', tone: BsmToastTone.danger);
      ref.invalidate(disponibilidadProvider(barberoId: barbero.id, servicioId: servicio.id, fecha: fecha));
    }

    final List<Widget> horarios = slotsAsync.when(
      loading: () => const [BsmSkeleton(variant: BsmSkeletonVariant.slots), SizedBox(height: AppSpace.s4), BsmSkeleton(variant: BsmSkeletonVariant.slots)],
      error: (error, stackTrace) => [
        BsmBanner(
          tone: BsmBannerTone.danger,
          title: 'No pudimos cargar los horarios',
          body: 'Revisa tu conexión e inténtalo de nuevo.',
          actionLabel: 'Reintentar',
          onAction: () => ref.invalidate(disponibilidadProvider(barberoId: barbero.id, servicioId: servicio.id, fecha: fecha)),
        ),
      ],
      data: (data) {
        final libres = data.slots.where((s) => (s.disponible && !s.bloqueadoPorRedis) || s.horaInicioFormateada == slot?.horaInicioFormateada);
        if (libres.isEmpty) {
          final siguiente = proximoDiaHabil();
          return [
            BsmEmptyState(
              icon: LucideIcons.calendarX,
              title: 'No hay horarios este día',
              body: 'Prueba con otro día o con otro barbero.',
              actionLabel: siguiente == null ? null : 'Ver el ${Formato.fechaLarga(siguiente)}',
              actionIcon: LucideIcons.arrowRight,
              actionVariant: BsmButtonVariant.secondary,
              onAction: siguiente == null ? null : () => elegirFecha(siguiente),
            ),
          ];
        }
        return [
          SlotGrid(
            selected: slot?.horaInicioFormateada,
            onSelect: (item) => elegirSlot(item, data.slots),
            slots: [
              for (final s in data.slots)
                SlotItem(
                  hour: s.horaInicio.hour,
                  minute: s.horaInicio.minute,
                  available: (s.disponible && !s.bloqueadoPorRedis) || s.horaInicioFormateada == slot?.horaInicioFormateada,
                ),
            ],
          ),
        ];
      },
    );

    Widget? barra;
    if (slot != null) {
      final inicio = fechaConHora(fecha, slot.horaInicioFormateada);
      final fin = inicio.add(Duration(minutes: servicio.duracionMinutos));
      barra = BookingBottomBar(
        top: BsmCountdownView(seconds: estado.tiempoRestanteSegundos, compact: true),
        title: '${Formato.fechaResumen(fecha)} · ${Formato.hora(inicio)}',
        subtitle: '${Formato.duracion(servicio.duracionMinutos)}, termina ${Formato.hora(fin)}',
        label: 'Continuar',
        loading: estado.estaBloqueando,
        onPressed: () => context.go('/reservar/confirm'),
      );
    } else {
      barra = BookingBottomBar(
        hint: estado.estaBloqueando ? 'Apartando tu horario…' : 'Elige un horario para continuar',
        label: 'Continuar',
        loading: estado.estaBloqueando,
        onPressed: null,
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _volver(barbero.id);
      },
      child: BookingScaffold(
        step: 3,
        title: 'Elige fecha y hora',
        onBack: () => _volver(barbero.id),
        backLabel: 'Volver a barberos',
        onStep: (n) => n == 1 ? context.go('/reservar/servicio') : _volver(barbero.id),
        bottom: barra,
        children: [
          // Contexto: servicio + barbero, con «Cambiar».
          Container(
            padding: const EdgeInsets.fromLTRB(AppSpace.s3, AppSpace.s2, AppSpace.s1, AppSpace.s2),
            decoration: BoxDecoration(color: p.surface, border: Border.all(color: p.line), borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Row(
              children: [
                BsmAvatar(name: barbero.nombreCompleto, photoUrl: barbero.fotoUrl, size: 32),
                const SizedBox(width: AppSpace.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${servicio.nombre} · ${Formato.duracion(servicio.duracionMinutos)}', style: AppTextStyles.label.copyWith(color: p.ink)),
                      Text('con ${barbero.nombreCompleto} · ${Formato.dinero(precio)}', style: AppTextStyles.body.copyWith(color: p.inkMuted)),
                    ],
                  ),
                ),
                TextButton(onPressed: () => _volver(barbero.id), child: const Text('Cambiar')),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.s5),
          BsmCalendar(
            month: _mes,
            today: _hoy,
            selected: fecha,
            isDisabled: deshabilitado,
            legend: 'Los días en gris no tienen atención.',
            onSelect: elegirFecha,
            onPrevMonth: !DateTime(_mes.year, _mes.month).isAfter(DateTime(_hoy.year, _hoy.month))
                ? null
                : () => setState(() => _mes = DateTime(_mes.year, _mes.month - 1)),
            onNextMonth: !DateTime(_mes.year, _mes.month + 1).isAfter(ultimoDia)
                ? () => setState(() => _mes = DateTime(_mes.year, _mes.month + 1))
                : null,
          ),
          const SizedBox(height: AppSpace.s5),
          Semantics(
            header: true,
            child: Text('Horarios para el ${Formato.fechaLarga(fecha)}', style: AppTextStyles.title.copyWith(color: p.ink)),
          ),
          const SizedBox(height: AppSpace.s3),
          ...horarios,
        ],
      ),
    );
  }
}
