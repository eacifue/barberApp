import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/auth/logout_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/format/formato.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../../barberias/presentation/providers/barbershops_provider.dart';
import '../../domain/models/cita_model.dart';
import '../booking_actions.dart';
import '../providers/citas_provider.dart';
import '../widgets/booking_scaffold.dart';

/// Mis citas: «Próximas (n)» / «Historial». En Próximas la tarjeta entera abre
/// el detalle (sin botones, para evitar cancelaciones por error); el historial
/// va por mes con «Calificar servicio» o «Reservar de nuevo»
/// (design/pantallas/app-movil/Mis-citas, Citas-historial, Citas-vacio).
class MisCitasScreen extends ConsumerWidget {
  const MisCitasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final barbershopAsync = ref.watch(myBarbershopProvider);
    final barberiaId = barbershopAsync.valueOrNull?.id;
    final citasAsync = barberiaId == null ? null : ref.watch(misCitasProvider(barberiaId));

    Widget cuerpo(Widget Function(List<CitaModel> proximas, List<CitaModel> historial) data) {
      if (barbershopAsync.hasError || (citasAsync?.hasError ?? false)) {
        return BsmEmptyState(
          isError: true,
          title: 'No pudimos cargar tus citas',
          body: 'Revisa tu conexión e inténtalo de nuevo.',
          actionLabel: 'Reintentar',
          actionIcon: LucideIcons.refreshCw,
          onAction: () => barberiaId == null ? ref.invalidate(myBarbershopProvider) : ref.invalidate(misCitasProvider(barberiaId)),
        );
      }
      final citas = citasAsync?.valueOrNull;
      if (citas == null) {
        return const Padding(padding: EdgeInsets.all(AppSpace.s4), child: BsmSkeleton(variant: BsmSkeletonVariant.card, count: 3));
      }
      return data(_proximas(citas), _historial(citas));
    }

    final proximasCount = citasAsync?.valueOrNull == null ? null : _proximas(citasAsync!.valueOrNull!).length;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.s4, AppSpace.s4, AppSpace.s2, AppSpace.s2),
                child: Row(
                  children: [
                    Expanded(child: Semantics(header: true, child: Text('Mis citas', style: AppTextStyles.display.copyWith(color: p.ink)))),
                    // Cerrar sesión vive aquí hasta que exista la pestaña Perfil.
                    const LogoutButton(),
                  ],
                ),
              ),
              TabBar(
                tabs: [
                  Tab(text: proximasCount == null || proximasCount == 0 ? 'Próximas' : 'Próximas ($proximasCount)'),
                  const Tab(text: 'Historial'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    cuerpo((proximas, _) {
                      if (proximas.isEmpty) {
                        return BsmEmptyState(
                          icon: LucideIcons.calendarDays,
                          title: 'Aún no tienes citas',
                          body: 'Reserva en menos de un minuto y te avisamos antes de tu turno.',
                          actionLabel: 'Reservar',
                          actionIcon: LucideIcons.calendarPlus,
                          onAction: () => context.go('/reservar/servicio'),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () => ref.refresh(misCitasProvider(barberiaId!).future),
                        child: ListView(
                          padding: const EdgeInsets.all(AppSpace.s4),
                          children: [
                            for (final c in proximas) ...[_tarjeta(context, c), const SizedBox(height: AppSpace.s3)],
                            const SizedBox(height: AppSpace.s1),
                            Text(
                              'Toca una cita para reprogramarla, cancelarla o ver cómo llegar.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body.copyWith(color: p.inkMuted),
                            ),
                          ],
                        ),
                      );
                    }),
                    cuerpo((_, historial) {
                      if (historial.isEmpty) {
                        return const BsmEmptyState(
                          icon: LucideIcons.history,
                          title: 'Aún no tienes historial',
                          body: 'Aquí verás tus citas pasadas para calificarlas o repetirlas.',
                        );
                      }
                      final porMes = <String, List<CitaModel>>{};
                      for (final c in historial) {
                        porMes.putIfAbsent(Formato.mesAnio(c.fechaCita), () => []).add(c);
                      }
                      return RefreshIndicator(
                        onRefresh: () => ref.refresh(misCitasProvider(barberiaId!).future),
                        child: ListView(
                          padding: const EdgeInsets.all(AppSpace.s4),
                          children: [
                            for (final mes in porMes.entries) ...[
                              Padding(padding: const EdgeInsets.only(bottom: AppSpace.s2, top: AppSpace.s2), child: Overline(mes.key)),
                              for (final c in mes.value) ...[_tarjeta(context, c, ref: ref), const SizedBox(height: AppSpace.s3)],
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tarjeta(BuildContext context, CitaModel c, {WidgetRef? ref}) {
    final status = AppointmentStatus.fromBackend(c.estado);
    final acciones = <Widget>[];
    if (ref != null && status == AppointmentStatus.completada && !c.tieneReview) {
      acciones.add(BsmButton(
        label: 'Calificar servicio',
        icon: LucideIcons.star,
        variant: BsmButtonVariant.ghost,
        size: BsmButtonSize.sm,
        onPressed: () => context.go('/appointments/${c.id}/calificar'),
      ));
    }
    if (ref != null && (status == AppointmentStatus.cancelada || status == AppointmentStatus.noShow)) {
      acciones.add(BsmButton(
        label: 'Reservar de nuevo',
        icon: LucideIcons.rotateCcw,
        variant: BsmButtonVariant.ghost,
        size: BsmButtonSize.sm,
        onPressed: () => iniciarReservaDesdeCita(context, ref, c, reprogramar: false),
      ));
    }
    return AppointmentCard(
      service: c.servicio.nombre,
      barber: '${c.barbero.nombre} ${c.barbero.apellido}'.trim(),
      barberPhotoUrl: c.barbero.fotoUrl,
      date: c.fechaCita,
      start: fechaConHora(c.fechaCita, c.horaInicio),
      end: fechaConHora(c.fechaCita, c.horaFin),
      status: status,
      price: status == AppointmentStatus.cancelada || status == AppointmentStatus.noShow ? null : c.precioFinal,
      onTap: () => context.go('/appointments/${c.id}'),
      actions: acciones,
    );
  }
}

List<CitaModel> _proximas(List<CitaModel> citas) {
  final lista = citas.where((c) => AppointmentStatus.fromBackend(c.estado).isUpcoming || AppointmentStatus.fromBackend(c.estado) == AppointmentStatus.enProgreso).toList()
    ..sort((a, b) {
      final f = a.fechaCita.compareTo(b.fechaCita);
      return f != 0 ? f : a.horaInicio.compareTo(b.horaInicio);
    });
  return lista;
}

List<CitaModel> _historial(List<CitaModel> citas) {
  final lista = citas.where((c) {
    final s = AppointmentStatus.fromBackend(c.estado);
    return s == AppointmentStatus.completada || s == AppointmentStatus.cancelada || s == AppointmentStatus.noShow;
  }).toList()
    ..sort((a, b) {
      final f = b.fechaCita.compareTo(a.fechaCita);
      return f != 0 ? f : b.horaInicio.compareTo(a.horaInicio);
    });
  return lista;
}
