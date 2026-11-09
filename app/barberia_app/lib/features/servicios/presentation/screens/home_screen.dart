import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/auth/auth_role_provider.dart';
import '../../../../core/auth/jwt_utils.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/format/formato.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../../barberias/domain/barbershop_model.dart';
import '../../../barberias/presentation/abrir_mapas.dart';
import '../../../barberias/presentation/providers/barbershops_provider.dart';
import '../../../barberos/presentation/providers/barberos_provider.dart';
import '../../../citas/domain/models/cita_model.dart';
import '../../../citas/presentation/providers/citas_provider.dart';
import '../../../citas/presentation/providers/reserva_notifier.dart';
import '../../../citas/presentation/widgets/booking_scaffold.dart';
import '../providers/servicios_provider.dart';

final _nombreUsuarioProvider = FutureProvider<String?>((ref) => ref.watch(secureStorageProvider).getNombre());

/// Inicio del cliente (design/pantallas/app-movil/Inicio e Inicio-sin-cita):
/// saludo, próxima cita, servicios, barberos y la barbería.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final nombre = ref.watch(_nombreUsuarioProvider).valueOrNull;
    final isAdmin = ref.watch(authRoleProvider).maybeWhen(data: JwtUtils.isAdminRole, orElse: () => false);
    final barbershopAsync = ref.watch(myBarbershopProvider);
    final barbershop = barbershopAsync.valueOrNull;

    Future<void> refrescar() async {
      ref.invalidate(myBarbershopProvider);
      if (barbershop != null) {
        ref.invalidate(misCitasProvider(barbershop.id));
        ref.invalidate(serviciosProvider(barbershop.id));
        ref.invalidate(barberosDeLaBarberiaProvider(barbershop.id));
      }
    }

    Widget seccion(String titulo, {Widget? accion}) => Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.s4, AppSpace.s8, AppSpace.s2, AppSpace.s3),
          child: Row(
            children: [
              Expanded(child: Semantics(header: true, child: Text(titulo, style: AppTextStyles.title.copyWith(color: p.ink)))),
              if (accion != null) accion,
            ],
          ),
        );

    final List<Widget> contenido;
    if (barbershopAsync.hasError) {
      contenido = [
        BsmEmptyState(
          isError: true,
          title: 'No pudimos cargar la barbería',
          body: 'Revisa tu conexión e inténtalo de nuevo.',
          actionLabel: 'Reintentar',
          actionIcon: LucideIcons.refreshCw,
          onAction: refrescar,
        ),
      ];
    } else if (barbershop == null) {
      contenido = barbershopAsync.isLoading
          ? const [Padding(padding: EdgeInsets.all(AppSpace.s4), child: BsmSkeleton(variant: BsmSkeletonVariant.card, count: 3))]
          : const [BsmEmptyState(icon: LucideIcons.store, title: 'La barbería aún no está configurada', body: 'Vuelve más tarde; estamos preparando las reservas.')];
    } else {
      contenido = [
        if (isAdmin)
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.s4, AppSpace.s4, AppSpace.s4, 0),
            child: BsmCardFrame(
              onTap: () => context.go('/admin'),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: p.brassSoft, borderRadius: BorderRadius.circular(AppRadius.sm)),
                    child: Icon(LucideIcons.store, color: p.brassInk),
                  ),
                  const SizedBox(width: AppSpace.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Administrar barbería', style: AppTextStyles.titleSm.copyWith(color: p.ink)),
                        Text('Barberos, servicios y clientes', style: AppTextStyles.body.copyWith(color: p.inkMuted)),
                      ],
                    ),
                  ),
                  Icon(LucideIcons.chevronRight, color: p.inkMuted),
                ],
              ),
            ),
          ),
        _ProximaCita(barbershop: barbershop),
        seccion('Nuestros servicios', accion: TextButton(onPressed: () => context.go('/reservar/servicio'), child: const Text('Ver todos'))),
        _Servicios(barberiaId: barbershop.id),
        seccion('Nuestros barberos'),
        _Barberos(barberiaId: barbershop.id),
        seccion('La barbería'),
        _LaBarberia(barbershop: barbershop),
        const SizedBox(height: AppSpace.s8),
      ];
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: refrescar,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.s4, AppSpace.s5, AppSpace.s4, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(nombre == null || nombre.isEmpty ? 'Hola' : 'Hola, $nombre', style: AppTextStyles.display.copyWith(color: p.ink)),
                    ),
                    const SizedBox(height: AppSpace.s1),
                    Text('¿Listo para tu próximo corte?', style: AppTextStyles.bodyLg.copyWith(color: p.inkMuted)),
                  ],
                ),
              ),
              ...contenido,
            ],
          ),
        ),
      ),
    );
  }
}

class _ProximaCita extends ConsumerWidget {
  const _ProximaCita({required this.barbershop});

  final BarbershopModel barbershop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final citasAsync = ref.watch(misCitasProvider(barbershop.id));
    final proxima = (citasAsync.valueOrNull ?? <CitaModel>[])
        .where((c) {
          final s = AppointmentStatus.fromBackend(c.estado);
          return s.isUpcoming || s == AppointmentStatus.enProgreso;
        })
        .toList()
      ..sort((a, b) {
        final f = a.fechaCita.compareTo(b.fechaCita);
        return f != 0 ? f : a.horaInicio.compareTo(b.horaInicio);
      });

    Widget cuerpo;
    if (citasAsync.isLoading && !citasAsync.hasValue) {
      cuerpo = const BsmSkeleton(variant: BsmSkeletonVariant.card);
    } else if (proxima.isEmpty) {
      cuerpo = Container(
        padding: const EdgeInsets.all(AppSpace.s5),
        decoration: BoxDecoration(color: p.surface, border: Border.all(color: p.line), borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: p.brassSoft, shape: BoxShape.circle),
              child: Icon(LucideIcons.calendarPlus, size: 28, color: p.brassInk),
            ),
            const SizedBox(height: AppSpace.s3),
            Semantics(header: true, child: Text('No tienes citas próximas', style: AppTextStyles.titleSm.copyWith(color: p.ink))),
            const SizedBox(height: AppSpace.s1),
            Text(
              'Reserva en menos de un minuto y te avisamos antes de tu turno.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: p.inkMuted),
            ),
            const SizedBox(height: AppSpace.s4),
            BsmButton(label: 'Reservar una cita', size: BsmButtonSize.lg, block: true, onPressed: () => context.go('/reservar/servicio')),
          ],
        ),
      );
    } else {
      final c = proxima.first;
      cuerpo = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppointmentCard(
            service: c.servicio.nombre,
            barber: '${c.barbero.nombre} ${c.barbero.apellido}'.trim(),
            barberPhotoUrl: c.barbero.fotoUrl,
            date: c.fechaCita,
            start: fechaConHora(c.fechaCita, c.horaInicio),
            end: fechaConHora(c.fechaCita, c.horaFin),
            status: AppointmentStatus.fromBackend(c.estado),
            price: c.precioFinal,
            onTap: () => context.go('/appointments/${c.id}'),
            actions: [
              BsmButton(
                label: 'Cómo llegar',
                icon: LucideIcons.navigation,
                variant: BsmButtonVariant.secondary,
                size: BsmButtonSize.sm,
                onPressed: () async {
                  final ok = await abrirMapas(barbershop);
                  if (!ok && context.mounted) showBsmToast(context, 'No pudimos abrir la aplicación de mapas.', tone: BsmToastTone.danger);
                },
              ),
              BsmButton(label: 'Ver detalle', variant: BsmButtonVariant.ghost, size: BsmButtonSize.sm, onPressed: () => context.go('/appointments/${c.id}')),
            ],
          ),
          const SizedBox(height: AppSpace.s3),
          BsmButton(
            label: 'Reservar otra cita',
            icon: LucideIcons.calendarPlus,
            variant: BsmButtonVariant.secondary,
            size: BsmButtonSize.lg,
            block: true,
            onPressed: () => context.go('/reservar/servicio'),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.s4, AppSpace.s6, AppSpace.s4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (proxima.isNotEmpty) ...[
            Semantics(header: true, child: Text('Tu próxima cita', style: AppTextStyles.title.copyWith(color: p.ink))),
            const SizedBox(height: AppSpace.s3),
          ],
          cuerpo,
        ],
      ),
    );
  }
}

class _Servicios extends ConsumerWidget {
  const _Servicios({required this.barberiaId});

  final String barberiaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final serviciosAsync = ref.watch(serviciosProvider(barberiaId));
    final servicios = (serviciosAsync.valueOrNull ?? []).where((s) => s.activo).take(6).toList();
    if (serviciosAsync.isLoading && servicios.isEmpty) {
      return const Padding(padding: EdgeInsets.symmetric(horizontal: AppSpace.s4), child: BsmSkeleton(variant: BsmSkeletonVariant.card));
    }
    if (servicios.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
        child: Text(serviciosAsync.hasError ? 'No pudimos cargar los servicios.' : 'Aún no hay servicios disponibles.', style: AppTextStyles.body.copyWith(color: p.inkMuted)),
      );
    }
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
        itemCount: servicios.length,
        separatorBuilder: (_, i) => const SizedBox(width: AppSpace.s3),
        itemBuilder: (context, i) {
          final s = servicios[i];
          return SizedBox(
            width: 290,
            child: ServiceCard(
              name: s.nombre,
              type: s.tipo,
              description: s.descripcion,
              durationMinutes: s.duracionMinutos,
              price: s.precio,
              onTap: () {
                ref.read(reservaNotifierProvider.notifier)
                  ..resetReserva()
                  ..seleccionarServicio(s);
                context.go('/reservar/barbero');
              },
            ),
          );
        },
      ),
    );
  }
}

class _Barberos extends ConsumerWidget {
  const _Barberos({required this.barberiaId});

  final String barberiaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final barberosAsync = ref.watch(barberosDeLaBarberiaProvider(barberiaId));
    final barberos = barberosAsync.valueOrNull ?? [];
    if (barberos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
        child: barberosAsync.isLoading
            ? const BsmSkeleton()
            : Text(barberosAsync.hasError ? 'No pudimos cargar el equipo.' : 'Pronto conocerás a nuestro equipo.', style: AppTextStyles.body.copyWith(color: p.inkMuted)),
      );
    }
    return SizedBox(
      height: 124,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
        itemCount: barberos.length,
        separatorBuilder: (_, i) => const SizedBox(width: AppSpace.s4),
        itemBuilder: (context, i) {
          final b = barberos[i];
          return Semantics(
            container: true,
            label: '${b.nombreCompleto}${b.ratingPromedio > 0 ? ', calificación ${Formato.decimal(b.ratingPromedio)} de 5' : ''}',
            excludeSemantics: true,
            child: SizedBox(
              width: 76,
              child: Column(
                children: [
                  BsmAvatar(name: b.nombreCompleto, photoUrl: b.fotoUrl, size: 64, available: b.disponible ? null : false),
                  const SizedBox(height: AppSpace.s2),
                  Text(b.nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.labelSm.copyWith(color: p.ink)),
                  const SizedBox(height: 2),
                  BsmRating(value: b.ratingPromedio > 0 ? b.ratingPromedio : null, compact: true, size: 14),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LaBarberia extends StatelessWidget {
  const _LaBarberia({required this.barbershop});

  final BarbershopModel barbershop;

  (int, int) _hm(String v) {
    final parts = v.split(':');
    return (int.tryParse(parts[0]) ?? 0, parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0);
  }

  /// «Abierto hasta las 6:00 p. m.» · «Abre hoy a las 9:00 a. m.» · «Cerrado · abre el lunes 9:00 a. m.»
  (String, bool) _estadoHoy(DateTime now) {
    final (ah, am) = _hm(barbershop.horaApertura);
    final (ch, cm) = _hm(barbershop.horaCierre);
    final apertura = Formato.horaDe(ah, am);
    final abre = DateTime(now.year, now.month, now.day, ah, am);
    final cierra = DateTime(now.year, now.month, now.day, ch, cm);
    if (barbershop.esDiaLaborable(now)) {
      if (now.isBefore(abre)) return ('Abre hoy a las $apertura', false);
      if (now.isBefore(cierra)) return ('Abierto hasta las ${Formato.horaDe(ch, cm)}', true);
    }
    for (var i = 1; i <= 7; i++) {
      final d = now.add(Duration(days: i));
      if (barbershop.esDiaLaborable(d)) {
        return ('Cerrado · abre ${i == 1 ? 'mañana' : 'el ${Formato.diaSemana(d)}'} a las $apertura', false);
      }
    }
    return ('Cerrado por ahora', false);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (estado, abierto) = _estadoHoy(DateTime.now());
    final (ah, am) = _hm(barbershop.horaApertura);
    final (ch, cm) = _hm(barbershop.horaCierre);
    final descanso = barbershop.diasDescanso.map((d) => d.toLowerCase().replaceAll('miercoles', 'miércoles').replaceAll('sabado', 'sábado')).join(', ');

    Widget fila(IconData icon, Widget principal, String secundaria) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: p.surfaceSunken, borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Icon(icon, size: 20, color: p.ink),
            ),
            const SizedBox(width: AppSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [principal, Text(secundaria, style: AppTextStyles.body.copyWith(color: p.inkMuted))],
              ),
            ),
          ],
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
      child: Container(
        padding: const EdgeInsets.all(AppSpace.s4),
        decoration: BoxDecoration(color: p.surface, border: Border.all(color: p.line), borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(barbershop.nombre, style: AppTextStyles.titleLg.copyWith(color: p.ink)),
            const SizedBox(height: AppSpace.s4),
            fila(
              LucideIcons.clock,
              Wrap(
                spacing: AppSpace.s2,
                runSpacing: AppSpace.s1,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(estado, style: AppTextStyles.label.copyWith(color: p.ink)),
                  BsmBadge(abierto ? 'Abierto' : 'Cerrado', tone: abierto ? BsmTone.success : BsmTone.neutral, icon: abierto ? LucideIcons.circleCheck : LucideIcons.circleX),
                ],
              ),
              '${Formato.horaDe(ah, am)} – ${Formato.horaDe(ch, cm)}${descanso.isEmpty ? '' : ' · Descansa: $descanso'}',
            ),
            const SizedBox(height: AppSpace.s4),
            fila(
              LucideIcons.mapPin,
              Text(barbershop.direccion.isEmpty ? barbershop.nombre : barbershop.direccion, style: AppTextStyles.label.copyWith(color: p.ink)),
              barbershop.ubicacion,
            ),
            const SizedBox(height: AppSpace.s5),
            BsmButton(
              label: 'Cómo llegar',
              icon: LucideIcons.navigation,
              block: true,
              onPressed: () async {
                final ok = await abrirMapas(barbershop);
                if (!ok && context.mounted) showBsmToast(context, 'No pudimos abrir la aplicación de mapas.', tone: BsmToastTone.danger);
              },
            ),
          ],
        ),
      ),
    );
  }
}
