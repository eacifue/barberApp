import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../tabs/admin_barberias_tab.dart';
import '../tabs/admin_barberos_tab.dart';
import '../tabs/admin_clientes_tab.dart';
import '../tabs/admin_servicios_tab.dart';

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
            tabs: [
              Tab(icon: Icon(LucideIcons.store), text: 'Barberías'),
              Tab(icon: Icon(LucideIcons.scissors), text: 'Barberos'),
              Tab(icon: Icon(LucideIcons.scissors), text: 'Servicios'),
              Tab(icon: Icon(LucideIcons.users), text: 'Clientes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminBarberiasTab(),
            AdminBarberosTab(),
            AdminServiciosTab(),
            AdminClientesTab(),
          ],
        ),
      ),
    );
  }
}
