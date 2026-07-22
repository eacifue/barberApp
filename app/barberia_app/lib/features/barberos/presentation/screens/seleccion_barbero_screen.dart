import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/citas/presentation/providers/reserva_notifier.dart';
import '../../../../features/horarios/presentation/providers/disponibilidad_provider.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../servicios/domain/servicio_model.dart';
import '../providers/barberos_provider.dart';
import '../widgets/barbero_card.dart';

class SeleccionBarberoScreen extends ConsumerWidget {
  const SeleccionBarberoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservaState = ref.watch(reservaNotifierProvider);
    final servicio = reservaState.servicioSeleccionado;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final columns = screenWidth < 600
        ? 1
        : screenWidth < 1024
        ? 2
        : 3;

    if (servicio == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Elige tu barbero'),
          leading: IconButton(
            onPressed: () => context.go('/reservar/servicio'),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 44,
                ),
                const SizedBox(height: 12),
                Text(
                  'Primero selecciona un servicio para ver barberos disponibles.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () => context.go('/reservar/servicio'),
                  child: const Text('Ir a servicios'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final barberosAsync = ref.watch(barberosPorServicioProvider(servicio.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elige tu barbero'),
        leading: IconButton(
          onPressed: () => context.go('/reservar/servicio'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ReservaProgressStep2(),
                const SizedBox(height: 14),
                _ServicioContextCard(servicio: servicio),
                const SizedBox(height: 14),
                Expanded(
                  child: barberosAsync.when(
                    loading: () => const _LoadingBarberos(),
                    error: (error, stackTrace) => BarberiaErrorWidget(
                      message:
                          'No pudimos cargar los barberos. Intenta nuevamente.',
                      onRetry: () =>
                          ref.refresh(barberosPorServicioProvider(servicio.id)),
                    ),
                    data: (barberos) {
                      if (barberos.isEmpty) {
                        return const _EmptyBarberos();
                      }

                      return GridView.builder(
                        itemCount: barberos.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: columns == 1 ? 2.2 : 1.25,
                        ),
                        itemBuilder: (context, index) {
                          final barbero = barberos[index];
                          return BarberoCard(
                            barbero: barbero,
                            onTap: () async {
                              ref
                                  .read(reservaNotifierProvider.notifier)
                                  .seleccionarBarbero(barbero);

                              await ref
                                  .read(disponibilidadNotifierProvider.notifier)
                                  .reiniciarParaNuevaSeleccion(
                                    barberoId: barbero.id,
                                    servicioId: servicio.id,
                                  );

                              if (!context.mounted) {
                                return;
                              }
                              context.go('/reservar/horario');
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReservaProgressStep2 extends StatelessWidget {
  const _ReservaProgressStep2();

  static const _steps = ['Servicio', 'Barbero', 'Horario', 'Confirmar'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paso 2 de 4', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < _steps.length; i++) ...[
              Expanded(
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: i <= 1
                        ? AppColors.primary
                        : AppColors.textMuted.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              if (i < _steps.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < _steps.length; i++)
              Expanded(
                child: Text(
                  _steps[i],
                  textAlign: i == 0
                      ? TextAlign.left
                      : i == _steps.length - 1
                      ? TextAlign.right
                      : TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: i == 1 ? AppColors.textPrimary : AppColors.textMuted,
                    fontWeight: i == 1 ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ServicioContextCard extends StatelessWidget {
  const _ServicioContextCard({required this.servicio});

  final ServicioModel servicio;

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.decimalPattern('es_CO');
    final precio = '\$${format.format(servicio.precio.round())}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.content_cut_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Reservando: ${servicio.nombre} · ${servicio.duracionFormateada} · $precio',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBarberos extends StatelessWidget {
  const _LoadingBarberos();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const BarberoCardShimmer(),
    );
  }
}

class _EmptyBarberos extends StatelessWidget {
  const _EmptyBarberos();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.group_off_rounded,
              size: 52,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'No hay barberos para este servicio',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
