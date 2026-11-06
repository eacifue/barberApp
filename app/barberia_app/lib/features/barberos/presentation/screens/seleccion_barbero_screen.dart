import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../features/citas/presentation/providers/reserva_notifier.dart';
import '../../../../features/citas/presentation/widgets/booking_scaffold.dart';
import '../../../../features/horarios/presentation/providers/disponibilidad_provider.dart';
import '../../../../shared/format/formato.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../domain/barbero_model.dart';
import '../providers/barberos_provider.dart';

/// Paso 2 · Elige tu barbero. Banner de contexto con «Cambiar», disponibles
/// primero, no disponibles al final (design/pantallas/app-movil/Reserva-2-Barbero).
class SeleccionBarberoScreen extends ConsumerStatefulWidget {
  const SeleccionBarberoScreen({super.key});

  @override
  ConsumerState<SeleccionBarberoScreen> createState() => _SeleccionBarberoScreenState();
}

class _SeleccionBarberoScreenState extends ConsumerState<SeleccionBarberoScreen> {
  bool _avanzando = false;

  Future<void> _continuar(BarberoModel barbero, String servicioId) async {
    setState(() => _avanzando = true);
    try {
      await ref.read(disponibilidadNotifierProvider.notifier).reiniciarParaNuevaSeleccion(barberoId: barbero.id, servicioId: servicioId);
      if (mounted) context.go('/reservar/horario');
    } finally {
      if (mounted) setState(() => _avanzando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reserva = ref.watch(reservaNotifierProvider);
    final servicio = reserva.servicioSeleccionado;
    final seleccionado = reserva.barberoSeleccionado;

    if (servicio == null) {
      return BookingScaffold(
        step: 2,
        title: 'Elige tu barbero',
        onBack: () => context.go('/reservar/servicio'),
        backLabel: 'Volver a servicios',
        children: [
          BsmEmptyState(
            icon: LucideIcons.scissors,
            title: 'Primero elige un servicio',
            body: 'Así te mostramos los barberos que lo hacen.',
            actionLabel: 'Elegir servicio',
            onAction: () => context.go('/reservar/servicio'),
          ),
        ],
      );
    }

    final barberosAsync = ref.watch(barberosPorServicioProvider(servicio.id));

    num precioPara(BarberoModel b) => b.servicios.where((s) => s.id == servicio.id).firstOrNull?.precio ?? servicio.precio;

    final List<Widget> lista = barberosAsync.when(
      loading: () => const [BsmSkeleton(variant: BsmSkeletonVariant.card, count: 3)],
      error: (error, stackTrace) => [
        BsmEmptyState(
          isError: true,
          title: 'No pudimos cargar los barberos',
          body: 'Revisa tu conexión e inténtalo de nuevo.',
          actionLabel: 'Reintentar',
          actionIcon: LucideIcons.refreshCw,
          onAction: () => ref.invalidate(barberosPorServicioProvider(servicio.id)),
        ),
      ],
      data: (barberos) {
        if (barberos.isEmpty) {
          return [
            BsmEmptyState(
              icon: LucideIcons.users,
              title: 'No hay barberos para este servicio',
              body: 'Prueba con otro servicio.',
              actionLabel: 'Elegir otro servicio',
              actionVariant: BsmButtonVariant.secondary,
              onAction: () => context.go('/reservar/servicio'),
            ),
          ];
        }
        final ordenados = [...barberos]..sort((a, b) => (b.disponible ? 1 : 0) - (a.disponible ? 1 : 0));
        return [
          for (final b in ordenados) ...[
            BarberCard(
              name: b.nombreCompleto,
              photoUrl: b.fotoUrl,
              years: b.aniosExperiencia,
              rating: b.ratingPromedio > 0 ? b.ratingPromedio : null,
              specialties: b.especialidades,
              available: b.disponible,
              specialPrice: precioPara(b) != servicio.precio ? precioPara(b) : null,
              selected: seleccionado?.id == b.id,
              onTap: () => ref.read(reservaNotifierProvider.notifier).seleccionarBarbero(b),
            ),
            const SizedBox(height: AppSpace.s3),
          ],
        ];
      },
    );

    return BookingScaffold(
      step: 2,
      title: 'Elige tu barbero',
      onBack: () => context.go('/reservar/servicio'),
      backLabel: 'Volver a servicios',
      onStep: (n) => context.go('/reservar/servicio'),
      bottom: seleccionado == null
          ? null
          : BookingBottomBar(
              title: seleccionado.nombreCompleto,
              subtitle: '${servicio.nombre} · ${Formato.dinero(precioPara(seleccionado))}',
              label: 'Continuar',
              loading: _avanzando,
              onPressed: () => _continuar(seleccionado, servicio.id),
            ),
      children: [
        BsmBanner(
          tone: BsmBannerTone.brass,
          icon: LucideIcons.layers,
          title: servicio.nombre,
          body: '${Formato.duracion(servicio.duracionMinutos)} · ${Formato.dinero(servicio.precio)}',
          actionLabel: 'Cambiar',
          onAction: () => context.go('/reservar/servicio'),
        ),
        const SizedBox(height: AppSpace.s4),
        Semantics(label: 'Barberos', container: true, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: lista)),
      ],
    );
  }
}
