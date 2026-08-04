import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/logout_button.dart';
import '../../../barberias/presentation/providers/selected_barbershop_provider.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../domain/models/cita_model.dart';
import '../providers/citas_provider.dart';
import '../widgets/cita_card.dart';

class MisCitasScreen extends ConsumerStatefulWidget {
  const MisCitasScreen({super.key});

  @override
  ConsumerState<MisCitasScreen> createState() => _MisCitasScreenState();
}

class _MisCitasScreenState extends ConsumerState<MisCitasScreen> {
  String? _citaCancelandoId;

  @override
  Widget build(BuildContext context) {
    final selectedState = ref.watch(selectedBarbershopProvider);
    final barberiaId = selectedState.barberiaId;
    final citasAsync = (barberiaId ?? '').isEmpty
        ? const AsyncValue<List<CitaModel>>.data([])
        : ref.watch(misCitasProvider(barberiaId!));
    final repo = ref.watch(citaRepositoryProvider);

    if ((barberiaId ?? '').isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mis citas')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/select-barbershop'),
            child: const Text('Seleccionar barbería'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis citas'),
        actions: [
          IconButton(
            tooltip: 'Cambiar barbería',
            onPressed: () => context.go('/select-barbershop'),
            icon: const Icon(Icons.storefront_rounded),
          ),
          const LogoutButton(),
        ],
      ),
      body: citasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => BarberiaErrorWidget(
          message: 'No pudimos cargar tus citas.',
          onRetry: () => ref.invalidate(misCitasProvider(barberiaId!)),
        ),
        data: (citas) {
          final proximas = _proximas(citas);
          final historial = _historial(citas);

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'PRÓXIMAS'),
                    Tab(text: 'HISTORIAL'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _CitasList(
                        items: proximas,
                        citaCancelandoId: _citaCancelandoId,
                        onTap: (cita) => context.go('/appointments/${cita.id}'),
                        onCancelar: (cita) async {
                          final ok = await _confirmCancel(context);
                          if (!ok || !mounted) {
                            return;
                          }
                          setState(() => _citaCancelandoId = cita.id);
                          try {
                            await repo.cancelarCita(
                              cita.id,
                              motivo: 'Cancelada por cliente en app',
                            );
                            ref.invalidate(misCitasProvider(barberiaId!));
                          } finally {
                            if (mounted) {
                              setState(() => _citaCancelandoId = null);
                            }
                          }
                        },
                      ),
                      _CitasList(
                        items: historial,
                        citaCancelandoId: _citaCancelandoId,
                        onTap: (cita) => context.go('/appointments/${cita.id}'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool> _confirmCancel(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancelar cita'),
            content: const Text('¿Seguro que deseas cancelar esta cita?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sí, cancelar'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _CitasList extends StatelessWidget {
  const _CitasList({
    required this.items,
    required this.onTap,
    this.onCancelar,
    this.citaCancelandoId,
  });

  final List<CitaModel> items;
  final void Function(CitaModel) onTap;
  final void Function(CitaModel)? onCancelar;
  final String? citaCancelandoId;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Sin citas en esta sección.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final cita = items[index];
        return Stack(
          children: [
            CitaCard(
              cita: cita,
              onTap: () => onTap(cita),
              onCancelar: onCancelar == null ? null : () => onCancelar!(cita),
            ),
            if (citaCancelandoId == cita.id)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x66000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }
}

List<CitaModel> _proximas(List<CitaModel> citas) {
  final allowed = {'pendiente', 'confirmada', 'enprogreso'};
  final filtered = citas
      .where((c) => allowed.contains(c.estado.toLowerCase()))
      .toList();
  filtered.sort((a, b) => a.fechaCita.compareTo(b.fechaCita));
  return filtered;
}

List<CitaModel> _historial(List<CitaModel> citas) {
  final allowed = {'completada', 'cancelada'};
  final filtered = citas
      .where((c) => allowed.contains(c.estado.toLowerCase()))
      .toList();
  filtered.sort((a, b) => b.fechaCita.compareTo(a.fechaCita));
  return filtered;
}
