import 'package:flutter/material.dart';

import '../tabs/admin_barberias_tab.dart';
import '../tabs/admin_barberos_tab.dart';
import '../tabs/admin_servicios_tab.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administración'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.store), text: 'Barberías'),
              Tab(icon: Icon(Icons.content_cut), text: 'Barberos'),
              Tab(icon: Icon(Icons.miscellaneous_services), text: 'Servicios'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminBarberiasTab(),
            AdminBarberosTab(),
            AdminServiciosTab(),
          ],
        ),
      ),
    );
  }
}
