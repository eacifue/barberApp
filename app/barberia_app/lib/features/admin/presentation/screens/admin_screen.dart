import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../tabs/admin_barberias_tab.dart';
import '../tabs/admin_barberos_tab.dart';
import '../tabs/admin_clientes_tab.dart';
import '../tabs/admin_servicios_tab.dart';

/// Administración dentro de la app (rol Admin). Sin diseño propio: sigue los
/// patrones de design/docs/02-patrones.md con las mismas reglas que el panel.
/// Agenda, usuarios y disponibilidad viven en el panel web.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administración'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(icon: Icon(LucideIcons.store, size: 20), text: 'Mi negocio'),
              Tab(icon: Icon(LucideIcons.users, size: 20), text: 'Equipo'),
              Tab(icon: Icon(LucideIcons.clipboardList, size: 20), text: 'Servicios'),
              Tab(icon: Icon(LucideIcons.userRound, size: 20), text: 'Clientes'),
            ],
          ),
        ),
        body: const SafeArea(
          top: false,
          child: TabBarView(
            children: [
              AdminBarberiasTab(),
              AdminBarberosTab(),
              AdminServiciosTab(),
              AdminClientesTab(),
            ],
          ),
        ),
      ),
    );
  }
}
