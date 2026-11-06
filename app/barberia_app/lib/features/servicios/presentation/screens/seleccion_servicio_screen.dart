import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../features/citas/presentation/providers/reserva_notifier.dart';
import '../../../../features/citas/presentation/widgets/booking_scaffold.dart';
import '../../../../shared/format/formato.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../../barberias/presentation/providers/barbershops_provider.dart';
import '../providers/servicios_provider.dart';

/// Paso 1 · ¿Qué servicio deseas? Tocar una tarjeta la selecciona; la barra
/// fija muestra la elección y «Continuar» (design/pantallas/app-movil/Main).
class SeleccionServicioScreen extends ConsumerStatefulWidget {
  const SeleccionServicioScreen({super.key});

  @override
  ConsumerState<SeleccionServicioScreen> createState() => _SeleccionServicioScreenState();
}

class _SeleccionServicioScreenState extends ConsumerState<SeleccionServicioScreen> {
  static const _todos = 'Todos';
  String _filtro = _todos;

  @override
  Widget build(BuildContext context) {
    final barbershopAsync = ref.watch(myBarbershopProvider);
    final seleccionado = ref.watch(reservaNotifierProvider).servicioSeleccionado;

    final List<Widget> contenido = barbershopAsync.when(
      loading: () => const [BsmSkeleton(variant: BsmSkeletonVariant.card, count: 4)],
      error: (error, stackTrace) => [
        BsmEmptyState(
          isError: true,
          title: 'No pudimos cargar los servicios',
          body: 'Revisa tu conexión e inténtalo de nuevo.',
          actionLabel: 'Reintentar',
          actionIcon: LucideIcons.refreshCw,
          onAction: () => ref.invalidate(myBarbershopProvider),
        ),
      ],
      data: (barbershop) {
        if (barbershop == null) {
          return const [
            BsmEmptyState(
              icon: LucideIcons.store,
              title: 'La barbería aún no está configurada',
              body: 'Vuelve más tarde; estamos preparando las reservas.',
            ),
          ];
        }
        final serviciosAsync = ref.watch(serviciosProvider(barbershop.id));
        return serviciosAsync.when(
          loading: () => const [BsmSkeleton(variant: BsmSkeletonVariant.card, count: 4)],
          error: (error, stackTrace) => [
            BsmEmptyState(
              isError: true,
              title: 'No pudimos cargar los servicios',
              body: 'Revisa tu conexión e inténtalo de nuevo.',
              actionLabel: 'Reintentar',
              actionIcon: LucideIcons.refreshCw,
              onAction: () => ref.invalidate(serviciosProvider(barbershop.id)),
            ),
          ],
          data: (servicios) {
            final activos = servicios.where((s) => s.activo).toList();
            if (activos.isEmpty) {
              return const [BsmEmptyState(icon: LucideIcons.scissors, title: 'Aún no hay servicios disponibles', body: 'Vuelve pronto.')];
            }
            final tipos = <String>{for (final s in activos) s.tipo}.toList()..sort();
            final filtro = [_todos, ...tipos].contains(_filtro) ? _filtro : _todos;
            final visibles = filtro == _todos ? activos : activos.where((s) => s.tipo == filtro).toList();
            return [
              Semantics(
                label: 'Filtrar por tipo',
                container: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      for (final t in [_todos, ...tipos]) ...[
                        BsmFilterChip(label: t, selected: filtro == t, onSelected: (_) => setState(() => _filtro = t)),
                        const SizedBox(width: AppSpace.s2),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.s4),
              for (final s in visibles) ...[
                ServiceCard(
                  name: s.nombre,
                  type: s.tipo,
                  description: s.descripcion,
                  durationMinutes: s.duracionMinutos,
                  price: s.precio,
                  selected: seleccionado?.id == s.id,
                  onTap: () => ref.read(reservaNotifierProvider.notifier).seleccionarServicio(s),
                ),
                const SizedBox(height: AppSpace.s3),
              ],
            ];
          },
        );
      },
    );

    return BookingScaffold(
      step: 1,
      title: '¿Qué servicio deseas?',
      bottom: seleccionado == null
          ? null
          : BookingBottomBar(
              title: seleccionado.nombre,
              subtitle: '${Formato.duracion(seleccionado.duracionMinutos)} · ${Formato.dinero(seleccionado.precio)}',
              label: 'Continuar',
              onPressed: () => context.go('/reservar/barbero'),
            ),
      children: contenido,
    );
  }
}
