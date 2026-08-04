import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/cita_model.dart';

class CitaExitosaScreen extends StatelessWidget {
  const CitaExitosaScreen({super.key, required this.cita});

  final CitaModel cita;

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat(
      "EEEE d 'de' MMMM",
      'es_CO',
    ).format(cita.fechaCita);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserva confirmada'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 180,
                    child: Lottie.asset(
                      'assets/animations/success.json',
                      repeat: false,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 120,
                      ),
                    ),
                  ),
                  Text(
                    'Reserva confirmada',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recibirás una notificación de confirmación.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceOf(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.textMutedOf(
                          context,
                        ).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cita.servicio.nombre,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text('${cita.barbero.nombre} ${cita.barbero.apellido}'),
                        Text('$fecha · ${cita.horaInicio.substring(0, 5)}'),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/appointments'),
                      child: const Text('Ver mis citas'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/dashboard'),
                    child: const Text('Volver al inicio'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
