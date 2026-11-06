import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/errors/error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/format/formato.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../../barberias/domain/barbershop_model.dart';
import '../../../barberias/presentation/providers/barbershops_provider.dart';
import '../../domain/models/cita_model.dart';
import '../booking_actions.dart';
import '../providers/citas_provider.dart';
import '../widgets/booking_scaffold.dart';

/// Tu cita: estado arriba, servicio, barbero, fecha, ubicación con «Cómo
/// llegar» y notas. Acciones al pie según el estado
/// (design/pantallas/app-movil/Cita-detalle y Cita-cancelar).
class DetalleCitaScreen extends ConsumerStatefulWidget {
  const DetalleCitaScreen({super.key, required this.citaId});

  final String citaId;

  @override
  ConsumerState<DetalleCitaScreen> createState() => _DetalleCitaScreenState();
}

class _DetalleCitaScreenState extends ConsumerState<DetalleCitaScreen> {
  bool _cancelando = false;
  bool _reprogramando = false;

  Future<void> _reprogramar(CitaModel cita) async {
    setState(() => _reprogramando = true);
    await iniciarReservaDesdeCita(context, ref, cita, reprogramar: true);
    if (mounted) setState(() => _reprogramando = false);
  }

  Future<void> _cancelar(CitaModel cita, DateTime inicio) async {
    final confirmado = await showBsmConfirm(
      context,
      title: '¿Cancelar esta cita?',
      body: 'Se liberará el horario del ${Formato.fechaLarga(inicio)} a las ${Formato.hora(inicio)} con ${cita.barbero.nombre}. '
          'Esta acción no se puede deshacer.',
      confirmLabel: 'Sí, cancelar cita',
    );
    if (!confirmado || !mounted) return;
    setState(() => _cancelando = true);
    try {
      await ref.read(citaRepositoryProvider).cancelarCita(cita.id);
      ref.invalidate(citaByIdProvider(widget.citaId));
      final barberiaId = ref.read(myBarbershopProvider).valueOrNull?.id;
      if (barberiaId != null) ref.invalidate(misCitasProvider(barberiaId));
      if (mounted) showBsmToast(context, 'Cita cancelada');
    } catch (e) {
      if (mounted) showBsmToast(context, mensajeDeError(e, 'No pudimos cancelar la cita. Inténtalo de nuevo.'), tone: BsmToastTone.danger);
    } finally {
      if (mounted) setState(() => _cancelando = false);
    }
  }

  Future<void> _comoLlegar(BarbershopModel barbershop) async {
    final query = Uri.encodeComponent('${barbershop.nombre}, ${barbershop.direccionCompleta}');
    final apple = defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS;
    final uri = apple ? Uri.parse('https://maps.apple.com/?q=$query') : Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    final abierto = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!abierto && mounted) {
      showBsmToast(context, 'No pudimos abrir la aplicación de mapas.', tone: BsmToastTone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final citaAsync = ref.watch(citaByIdProvider(widget.citaId));
    final barbershop = ref.watch(myBarbershopProvider).valueOrNull;
    final cita = citaAsync.valueOrNull;
    final status = cita == null ? null : AppointmentStatus.fromBackend(cita.estado);

    Widget header() => Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.s2, AppSpace.s1, AppSpace.s4, AppSpace.s2),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Volver a Mis citas',
                onPressed: () => context.go('/appointments'),
                icon: const Icon(LucideIcons.arrowLeft, size: 24),
              ),
              const SizedBox(width: AppSpace.s1),
              Expanded(child: Semantics(header: true, child: Text('Tu cita', style: AppTextStyles.display.copyWith(color: p.ink)))),
              if (status != null) StatusBadge(status),
            ],
          ),
        );

    if (cita == null || status == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header(),
              Expanded(
                child: citaAsync.hasError
                    ? BsmEmptyState(
                        isError: true,
                        title: 'No pudimos cargar tu cita',
                        body: 'Revisa tu conexión e inténtalo de nuevo.',
                        actionLabel: 'Reintentar',
                        actionIcon: LucideIcons.refreshCw,
                        onAction: () => ref.invalidate(citaByIdProvider(widget.citaId)),
                      )
                    : const Padding(padding: EdgeInsets.all(AppSpace.s4), child: BsmSkeleton(variant: BsmSkeletonVariant.card, count: 2)),
              ),
            ],
          ),
        ),
      );
    }

    final inicio = fechaConHora(cita.fechaCita, cita.horaInicio);
    final fin = fechaConHora(cita.fechaCita, cita.horaFin);
    final barbero = '${cita.barbero.nombre} ${cita.barbero.apellido}'.trim();

    Widget fila({required Widget leading, required String title, required String subtitle, Widget? trailing}) => Row(
          children: [
            leading,
            const SizedBox(width: AppSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSm.copyWith(color: p.ink)),
                  Text(subtitle, style: AppTextStyles.body.copyWith(color: p.inkMuted)),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        );

    Widget? acciones;
    if (status.isUpcoming) {
      acciones = Row(
        children: [
          Expanded(
            child: BsmButton(
              label: 'Reprogramar',
              icon: LucideIcons.calendarClock,
              variant: BsmButtonVariant.secondary,
              size: BsmButtonSize.lg,
              block: true,
              loading: _reprogramando,
              onPressed: _cancelando ? null : () => _reprogramar(cita),
            ),
          ),
          const SizedBox(width: AppSpace.s2),
          Expanded(
            child: BsmButton(
              label: 'Cancelar cita',
              variant: BsmButtonVariant.dangerGhost,
              size: BsmButtonSize.lg,
              block: true,
              loading: _cancelando,
              onPressed: _reprogramando ? null : () => _cancelar(cita, inicio),
            ),
          ),
        ],
      );
    } else if (status == AppointmentStatus.completada && !cita.tieneReview) {
      acciones = BsmButton(
        label: 'Calificar servicio',
        icon: LucideIcons.star,
        size: BsmButtonSize.lg,
        block: true,
        onPressed: () => context.go('/appointments/${cita.id}/calificar'),
      );
    } else if (status == AppointmentStatus.cancelada || status == AppointmentStatus.noShow || status == AppointmentStatus.completada) {
      acciones = BsmButton(
        label: 'Reservar de nuevo',
        icon: LucideIcons.rotateCcw,
        variant: BsmButtonVariant.secondary,
        size: BsmButtonSize.lg,
        block: true,
        loading: _reprogramando,
        onPressed: () async {
          setState(() => _reprogramando = true);
          await iniciarReservaDesdeCita(context, ref, cita, reprogramar: false);
          if (mounted) setState(() => _reprogramando = false);
        },
      );
    }

    return Scaffold(
      bottomNavigationBar: acciones == null
          ? null
          : DecoratedBox(
              decoration: BoxDecoration(color: p.surface, border: Border(top: BorderSide(color: p.line))),
              child: SafeArea(top: false, child: Padding(padding: const EdgeInsets.all(AppSpace.s4), child: acciones)),
            ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpace.s6),
          children: [
            header(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SummaryCard(
                    children: [
                      fila(
                        leading: ServiceTypeBadge(tipo: cita.servicio.nombre),
                        title: cita.servicio.nombre,
                        subtitle: '${Formato.duracion(cita.servicio.duracionMinutos)} · ${Formato.dinero(cita.precioFinal)} · Pago en el local',
                      ),
                      fila(
                        leading: BsmAvatar(name: barbero, photoUrl: cita.barbero.fotoUrl),
                        title: barbero,
                        subtitle: 'Tu barbero',
                      ),
                      fila(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(color: p.surfaceSunken, borderRadius: BorderRadius.circular(AppRadius.sm)),
                          child: Icon(LucideIcons.calendarDays, size: 20, color: p.ink),
                        ),
                        title: capitalizar(Formato.fechaLarga(inicio)),
                        subtitle: status.isUpcoming ? '${Formato.rango(inicio, fin)} · Te avisaremos antes de tu cita' : Formato.rango(inicio, fin),
                      ),
                    ],
                  ),
                  if (barbershop != null) ...[
                    const SizedBox(height: AppSpace.s4),
                    Semantics(
                      label: 'Ubicación',
                      container: true,
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(color: p.surface, border: Border.all(color: p.line), borderRadius: BorderRadius.circular(AppRadius.md)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Marcador de posición hasta integrar el proveedor de mapas.
                            Semantics(
                              label: 'Mapa de la ubicación de la barbería',
                              image: true,
                              child: Container(
                                height: 120,
                                color: p.surfaceSunken,
                                alignment: Alignment.center,
                                child: Icon(LucideIcons.mapPin, size: 28, color: p.brassInk),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(AppSpace.s4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Overline('Ubicación'),
                                        const SizedBox(height: AppSpace.s1),
                                        Text(barbershop.nombre, style: AppTextStyles.label.copyWith(color: p.ink)),
                                        Text(barbershop.direccionCompleta, style: AppTextStyles.body.copyWith(color: p.inkMuted)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpace.s2),
                                  BsmButton(
                                    label: 'Cómo llegar',
                                    icon: LucideIcons.navigation,
                                    variant: BsmButtonVariant.secondary,
                                    onPressed: () => _comoLlegar(barbershop),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (cita.notas != null && cita.notas!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpace.s4),
                    SummaryCard(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Overline('Tu nota para el barbero'),
                            const SizedBox(height: AppSpace.s1),
                            Text(cita.notas!.trim(), style: AppTextStyles.bodyLg.copyWith(color: p.ink)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
