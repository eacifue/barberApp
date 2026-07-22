import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../barberias/presentation/providers/selected_barbershop_provider.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../providers/citas_provider.dart';

class DetalleCitaScreen extends ConsumerStatefulWidget {
  const DetalleCitaScreen({super.key, required this.citaId});

  final String citaId;

  @override
  ConsumerState<DetalleCitaScreen> createState() => _DetalleCitaScreenState();
}

class _DetalleCitaScreenState extends ConsumerState<DetalleCitaScreen> {
  int _rating = 0;
  final _comentarioController = TextEditingController();

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final citaAsync = ref.watch(citaByIdProvider(widget.citaId));
    final repo = ref.watch(citaRepositoryProvider);
    final barberiaId = ref.watch(selectedBarbershopProvider).barberiaId;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de cita')),
      body: citaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => BarberiaErrorWidget(
          message: 'No pudimos cargar el detalle de la cita.',
          onRetry: () => ref.invalidate(citaByIdProvider(widget.citaId)),
        ),
        data: (cita) {
          final fecha = DateFormat(
            "EEEE d 'de' MMMM, y",
            'es_CO',
          ).format(cita.fechaCita);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Box(
                title: 'Servicio',
                child: Text(
                  '${cita.servicio.nombre} · ${cita.servicio.duracionMinutos} min',
                ),
              ),
              _Box(
                title: 'Barbero',
                child: Text('${cita.barbero.nombre} ${cita.barbero.apellido}'),
              ),
              _Box(
                title: 'Fecha y hora',
                child: Text(
                  '$fecha\n${cita.horaInicio.substring(0, 5)} - ${cita.horaFin.substring(0, 5)}',
                ),
              ),
              _Box(
                title: 'Precio',
                child: Text(
                  NumberFormat.currency(
                    locale: 'es_CO',
                    symbol: r'$',
                    decimalDigits: 0,
                  ).format(cita.precioFinal),
                ),
              ),
              _Box(
                title: 'Estado',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cita.estadoColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    cita.estado,
                    style: TextStyle(
                      color: cita.estadoColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (cita.estado.toLowerCase() == 'completada')
                _Box(
                  title: '¿Cómo fue tu experiencia?',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) => IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 34),
                            onPressed: () =>
                                setState(() => _rating = index + 1),
                            icon: Icon(
                              index < _rating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ),
                      TextField(
                        controller: _comentarioController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Comparte tu comentario',
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Calificación enviada (mock).'),
                            ),
                          );
                        },
                        child: const Text('Enviar calificación'),
                      ),
                    ],
                  ),
                ),
              _Box(
                title: 'Ubicación',
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.primary.withValues(alpha: 0.08),
                  ),
                  child: const Center(
                    child: Text('Mapa estático de la barbería'),
                  ),
                ),
              ),
              if (cita.esCancelable)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  onPressed: () async {
                    await repo.cancelarCita(
                      cita.id,
                      motivo: 'Cancelada desde detalle de cita',
                    );
                    ref.invalidate(citaByIdProvider(widget.citaId));
                    if ((barberiaId ?? '').isNotEmpty) {
                      ref.invalidate(misCitasProvider(barberiaId!));
                    }
                  },
                  child: const Text('Cancelar cita'),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
