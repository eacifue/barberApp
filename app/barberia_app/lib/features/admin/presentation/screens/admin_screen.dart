import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/auth/auth_role_provider.dart';
import '../../../../core/auth/jwt_utils.dart';
import '../tabs/admin_barberias_tab.dart';
import '../tabs/admin_barberos_tab.dart';
import '../tabs/admin_clientes_tab.dart';
import '../tabs/admin_servicios_tab.dart';

typedef PestanaAdmin = ({String label, IconData icon, Widget Function() build});

/// Administración dentro de la app (SuperAdmin y administrador de barbería).
/// Sin diseño propio: sigue los patrones de design/docs/02-patrones.md con las
/// mismas reglas que el panel. Agenda, usuarios y disponibilidad viven en el panel web.
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  /// Las mismas para el SuperAdmin y el administrador de barbería; el API limita a
  /// cada uno a lo suyo («Mi negocio» del administrador es solo su barbería).
  static List<PestanaAdmin> pestanasPara(String? role) => [
        if (JwtUtils.puedeAdministrar(role)) (label: 'Mi negocio', icon: LucideIcons.store, build: () => const AdminBarberiasTab()),
        (label: 'Equipo', icon: LucideIcons.users, build: () => const AdminBarberosTab()),
        (label: 'Servicios', icon: LucideIcons.clipboardList, build: () => const AdminServiciosTab()),
        (label: 'Clientes', icon: LucideIcons.userRound, build: () => const AdminClientesTab()),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pestanas = pestanasPara(ref.watch(authRoleProvider).valueOrNull);
    return DefaultTabController(
      key: ValueKey(pestanas.length),
      length: pestanas.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administración'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [for (final p in pestanas) Tab(icon: Icon(p.icon, size: 20), text: p.label)],
          ),
        ),
        body: SafeArea(
          top: false,
          child: TabBarView(children: [for (final p in pestanas) p.build()]),
        ),
      ),
    );
  }
}
