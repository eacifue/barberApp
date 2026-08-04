import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/logout_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../citas/presentation/providers/reprogramacion_provider.dart';
import '../../../citas/presentation/providers/reserva_notifier.dart';
import '../providers/barbershops_provider.dart';
import '../providers/selected_barbershop_provider.dart';

class SelectBarbershopScreen extends ConsumerStatefulWidget {
  const SelectBarbershopScreen({super.key});

  @override
  ConsumerState<SelectBarbershopScreen> createState() =>
      _SelectBarbershopScreenState();
}

class _SelectBarbershopScreenState
    extends ConsumerState<SelectBarbershopScreen> {
  String? _savingId;

  @override
  Widget build(BuildContext context) {
    final barbershopsAsync = ref.watch(barbershopsProvider);
    final selectedState = ref.watch(selectedBarbershopProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu barbería'),
        actions: [LogoutButton(disabled: _savingId != null)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: barbershopsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => BarberiaErrorWidget(
            message:
                'No fue posible cargar barberías. Verifica tu conexión e inténtalo de nuevo.',
            onRetry: () => ref.refresh(barbershopsProvider),
          ),
          data: (barbershops) {
            if (barbershops.isEmpty) {
              return const _EmptyBarbershops();
            }

            return ListView.separated(
              itemCount: barbershops.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = barbershops[index];
                final isSelected = selectedState.barberiaId == item.id;
                final isSaving = _savingId == item.id;

                return AppCard(
                  onTap: isSaving
                      ? null
                      : () async {
                          setState(() => _savingId = item.id);
                          ref
                              .read(reservaNotifierProvider.notifier)
                              .resetReserva();
                          ref.read(citaIdAReprogramarProvider.notifier).state =
                              null;
                          await ref
                              .read(selectedBarbershopProvider.notifier)
                              .selectBarbershop(item.id);
                          if (!context.mounted) {
                            return;
                          }
                          context.go('/dashboard');
                        },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nombre,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.ubicacion,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.2,
                          ),
                        ),
                        child: isSaving
                            ? const Padding(
                                padding: EdgeInsets.all(6),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: AppButton(
          label: 'Continuar al dashboard',
          onPressed: selectedState.hasSelection
              ? () => context.go('/dashboard')
              : null,
        ),
      ),
    );
  }
}

class _EmptyBarbershops extends StatelessWidget {
  const _EmptyBarbershops();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store_mall_directory_outlined, size: 52),
            const SizedBox(height: 10),
            Text(
              'No hay barberías disponibles',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Contacta al administrador para activar una barbería.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
