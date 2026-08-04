import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../barberias/presentation/providers/selected_barbershop_provider.dart';
import '../../../../features/citas/presentation/providers/reserva_notifier.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../providers/servicios_provider.dart';
import '../widgets/servicio_card.dart';

class SeleccionServicioScreen extends ConsumerStatefulWidget {
  const SeleccionServicioScreen({super.key});

  @override
  ConsumerState<SeleccionServicioScreen> createState() =>
      _SeleccionServicioScreenState();
}

class _SeleccionServicioScreenState
    extends ConsumerState<SeleccionServicioScreen> {
  static const _todos = 'Todos';

  String _filtroSeleccionado = _todos;

  @override
  Widget build(BuildContext context) {
    final selectedState = ref.watch(selectedBarbershopProvider);
    final barberiaId = selectedState.barberiaId;

    if ((barberiaId ?? '').isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('¿Qué servicio deseas?')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/select-barbershop'),
            child: const Text('Seleccionar barbería'),
          ),
        ),
      );
    }

    final serviciosAsync = ref.watch(serviciosProvider(barberiaId!));
    final reservaState = ref.watch(reservaNotifierProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;

    final columns = screenWidth < 600
        ? 1
        : screenWidth < 1024
        ? 2
        : 3;

    return Scaffold(
      appBar: AppBar(title: const Text('¿Qué servicio deseas?')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ReservaProgress(),
                const SizedBox(height: 16),
                Expanded(
                  child: serviciosAsync.when(
                    loading: () => const _LoadingServicios(),
                    error: (error, stackTrace) {
                      return BarberiaErrorWidget(
                        message:
                            'No pudimos cargar los servicios. Intenta nuevamente.',
                        onRetry: () =>
                            ref.refresh(serviciosProvider(barberiaId)),
                      );
                    },
                    data: (servicios) {
                      final activos = servicios.where((s) => s.activo).toList();
                      final tipos = <String>{for (final s in activos) s.tipo}
                          .toList()
                        ..sort();
                      final filtros = [_todos, ...tipos];
                      final filtroActivo = filtros.contains(_filtroSeleccionado)
                          ? _filtroSeleccionado
                          : _todos;
                      final filtrados = filtroActivo == _todos
                          ? activos
                          : activos
                                .where((s) => s.tipo == filtroActivo)
                                .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FiltroServicios(
                            filtros: filtros,
                            seleccionado: filtroActivo,
                            onChanged: (filtro) =>
                                setState(() => _filtroSeleccionado = filtro),
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            child: filtrados.isEmpty
                                ? const _EmptyServicios()
                                : GridView.builder(
                                    itemCount: filtrados.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: columns,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          childAspectRatio: columns == 1
                                              ? 2.5
                                              : 1.55,
                                        ),
                                    itemBuilder: (context, index) {
                                      final servicio = filtrados[index];
                                      final seleccionado =
                                          reservaState
                                              .servicioSeleccionado
                                              ?.id ==
                                          servicio.id;

                                      return ServicioCard(
                                        servicio: servicio,
                                        seleccionado: seleccionado,
                                        onTap: () {
                                          ref
                                              .read(
                                                reservaNotifierProvider
                                                    .notifier,
                                              )
                                              .seleccionarServicio(servicio);
                                          context.go('/reservar/barbero');
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ],
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

class _ReservaProgress extends StatelessWidget {
  const _ReservaProgress();

  static const _steps = ['Servicio', 'Barbero', 'Horario', 'Confirmar'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paso 1 de 4', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < _steps.length; i++) ...[
              Expanded(
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == 0
                        ? AppColors.primary
                        : AppColors.textMutedOf(context).withValues(alpha: 0.25),
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
                  textAlign: i == 0 ? TextAlign.left : TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: i == 0
                        ? AppColors.textPrimaryOf(context)
                        : AppColors.textMutedOf(context),
                    fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FiltroServicios extends StatelessWidget {
  const _FiltroServicios({
    required this.filtros,
    required this.seleccionado,
    required this.onChanged,
  });

  final List<String> filtros;
  final String seleccionado;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filtros.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filtro = filtros[index];
          final isSelected = filtro == seleccionado;
          return InkWell(
            borderRadius: BorderRadius.circular(99),
            onTap: () => onChanged(filtro),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surfaceOf(context),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textMutedOf(context).withValues(alpha: 0.28),
                ),
              ),
              child: Text(
                filtro,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textMutedOf(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoadingServicios extends StatelessWidget {
  const _LoadingServicios();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const ServicioCardShimmer(),
    );
  }
}

class _EmptyServicios extends StatelessWidget {
  const _EmptyServicios();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.content_cut,
                size: 54,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay servicios disponibles',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otro filtro o vuelve a cargar en unos segundos.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
