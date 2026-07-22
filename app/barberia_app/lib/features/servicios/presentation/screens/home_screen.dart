import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/jwt_utils.dart';
import '../../../../core/auth/auth_role_provider.dart';
import '../../../../features/barberias/presentation/providers/selected_barbershop_provider.dart';
import '../../../../features/citas/presentation/providers/citas_provider.dart';
import '../../../../features/auth/data/auth_repository.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../providers/servicios_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(authRoleProvider);
    final selectedState = ref.watch(selectedBarbershopProvider);
    final isAdmin = roleAsync.maybeWhen(
      data: JwtUtils.isAdminRole,
      orElse: () => false,
    );

    final barberiaId = selectedState.barberiaId;

    if ((barberiaId ?? '').isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/select-barbershop'),
            child: const Text('Seleccionar barbería'),
          ),
        ),
      );
    }

    final serviciosAsync = ref.watch(serviciosProvider(barberiaId!));
    final citasAsync = ref.watch(misCitasProvider(barberiaId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Cambiar barbería',
            onPressed: () => context.go('/select-barbershop'),
            icon: const Icon(Icons.storefront_rounded),
          ),
          if (isAdmin)
            IconButton(
              tooltip: 'Administración',
              onPressed: () => context.go('/admin'),
              icon: const Icon(Icons.admin_panel_settings_rounded),
            ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await ref.read(authRepositoryProvider).logout();
              await ref
                  .read(selectedBarbershopProvider.notifier)
                  .clearSelection();
              ref.invalidate(authRoleProvider);
              if (!context.mounted) {
                return;
              }
              context.go('/login');
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Resumen de tu barbería',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Datos en tiempo real filtrados por la barbería seleccionada.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/select-barbershop'),
              icon: const Icon(Icons.storefront_rounded),
              label: const Text('Cambiar barbería'),
            ),
          ),
          const SizedBox(height: 12),
          serviciosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => BarberiaErrorWidget(
              message: 'No pudimos cargar servicios del dashboard.',
              onRetry: () => ref.refresh(serviciosProvider(barberiaId)),
            ),
            data: (servicios) {
              final serviciosActivos = servicios
                  .where((x) => x.activo)
                  .toList();
              return AppCard(
                child: _MetricRow(
                  title: 'Servicios activos',
                  subtitle:
                      '${serviciosActivos.length} disponibles para reserva',
                  icon: Icons.content_cut_rounded,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          citasAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => BarberiaErrorWidget(
              message: 'No pudimos cargar próximas citas.',
              onRetry: () => ref.refresh(misCitasProvider(barberiaId)),
            ),
            data: (citas) {
              final proximas = citas.where((cita) {
                final estado = cita.estado.toLowerCase();
                return estado == 'pendiente' || estado == 'confirmada';
              }).toList()..sort((a, b) => a.fechaCita.compareTo(b.fechaCita));

              return AppCard(
                child: _MetricRow(
                  title: 'Próximas citas',
                  subtitle: proximas.isEmpty
                      ? 'No tienes citas próximas en esta barbería.'
                      : '${proximas.length} por atender',
                  icon: Icons.event_available_rounded,
                ),
              );
            },
          ),
          if (isAdmin) ...[
            const SizedBox(height: 16),
            Text(
              'Administración',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _AdminOptionTile(
              icon: Icons.store,
              title: 'Gestionar barberías',
              onTap: () => context.go('/admin'),
            ),
            const SizedBox(height: 12),
            _AdminOptionTile(
              icon: Icons.content_cut,
              title: 'Gestionar barberos',
              onTap: () => context.go('/admin'),
            ),
            const SizedBox(height: 12),
            _AdminOptionTile(
              icon: Icons.miscellaneous_services,
              title: 'Gestionar servicios',
              onTap: () => context.go('/admin'),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 20, child: Icon(icon, size: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminOptionTile extends StatelessWidget {
  const _AdminOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
