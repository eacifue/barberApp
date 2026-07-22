import 'package:flutter/material.dart';

import '../../../../shared/widgets/barberia_button.dart';
import '../../../../shared/widgets/barberia_card.dart';

class RegistroScreen extends StatelessWidget {
  const RegistroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Crea tu cuenta',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              const BarberiaCard(
                child: Column(
                  children: [
                    TextField(decoration: InputDecoration(labelText: 'Nombre')),
                    SizedBox(height: 14),
                    TextField(
                      decoration: InputDecoration(labelText: 'Apellido'),
                    ),
                    SizedBox(height: 14),
                    TextField(decoration: InputDecoration(labelText: 'Correo')),
                    SizedBox(height: 14),
                    TextField(
                      decoration: InputDecoration(labelText: 'Teléfono'),
                    ),
                    SizedBox(height: 14),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Contraseña'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              BarberiaButton(label: 'Registrarme', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
