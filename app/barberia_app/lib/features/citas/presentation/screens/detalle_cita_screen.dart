import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../barberias/domain/barbershop_model.dart';
import '../../../barberias/presentation/providers/barbershops_provider.dart';
import '../../../barberos/presentation/providers/barberos_provider.dart';
import '../../../horarios/presentation/providers/disponibilidad_provider.dart';
import '../../../servicios/presentation/providers/servicios_provider.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../domain/models/cita_model.dart';
import '../providers/citas_provider.dart';
import '../providers/reprogramacion_provider.dart';
import '../providers/reserva_notifier.dart';

class DetalleCitaScreen extends ConsumerStatefulWidget {
  const DetalleCitaScreen({super.key, required this.citaId});

  final String citaId;

  @override
  ConsumerState<DetalleCitaScreen> createState() => _DetalleCitaScreenState();
}

class _DetalleCitaScreenState extends ConsumerState<DetalleCitaScreen> {
  bool _cancelando = false;
  bool _reprogramando = false;

  Future<void> _reprogramar(CitaModel cita) async {
    final barbershop = await ref.read(myBarbershopProvider.future);
    if (barbershop == null) {
      return;
    }

    setState(() => _reprogramando = true);
    try {
      final servicios = await ref.read(serviciosProvider(barbershop.id).future);
      var servicio = servicios.where((s) => s.id == cita.servicio.id).toList();

      if (servicio.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Este servicio ya no está disponible para reprogramar.',
              ),
            ),
          );
        }
        return;
      }

      final barberos = await ref.read(
        barberosPorServicioProvider(servicio.first.id).future,
      );
      final barbero = barberos.where((b) => b.id == cita.barbero.id).toList();

      if (barbero.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Este barbero ya no está disponible para este servicio.',
              ),
            ),
          );
        }
        return;
      }

      final reservaNotifier = ref.read(reservaNotifierProvider.notifier);
      reservaNotifier.resetReserva();
      reservaNotifier.seleccionarServicio(servicio.first);
      reservaNotifier.seleccionarBarbero(barbero.first);
      await ref
          .read(disponibilidadNotifierProvider.notifier)
          .reiniciarParaNuevaSeleccion(
            barberoId: barbero.first.id,
            servicioId: servicio.first.id,
          );
      ref.read(citaIdAReprogramarProvider.notifier).state = cita.id;

      if (!mounted) {
        return;
      }
      context.go('/reservar/horario');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No pudimos iniciar la reprogramación. Intenta de nuevo.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _reprogramando = false);
      }
    }
  }

  Future<bool> _confirmCancel() async {
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

  Future<void> _abrirEnMapas(BarbershopModel barbershop) async {
    final query = Uri.encodeComponent(
      '${barbershop.nombre}, ${barbershop.direccionCompleta}',
    );
    final isApple =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
    final uri = isApple
        ? Uri.parse('https://maps.apple.com/?q=$query')
        : Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos abrir la aplicación de mapas.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final citaAsync = ref.watch(citaByIdProvider(widget.citaId));
    final repo = ref.watch(citaRepositoryProvider);
    final barbershopAsync = ref.watch(myBarbershopProvider);

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
              _Box(
                title: 'Ubicación',
                child: barbershopAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (error, stackTrace) =>
                      const Text('No pudimos cargar la ubicación.'),
                  data: (barbershop) {
                    if (barbershop == null) {
                      return const Text('Ubicación no disponible.');
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(barbershop.nombre),
                        Text(
                          barbershop.direccionCompleta,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => _abrirEnMapas(barbershop),
                          icon: const Icon(Icons.directions_rounded),
                          label: const Text('Cómo llegar'),
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (cita.esCancelable) ...[
                OutlinedButton.icon(
                  onPressed: _reprogramando || _cancelando
                      ? null
                      : () => _reprogramar(cita),
                  icon: _reprogramando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.event_repeat_rounded),
                  label: const Text('Reprogramar'),
                ),
                const SizedBox(height: 10),
              ],
              if (cita.esCancelable)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  onPressed: _cancelando || _reprogramando
                      ? null
                      : () async {
                          final confirmado = await _confirmCancel();
                          if (!confirmado || !context.mounted) {
                            return;
                          }

                          setState(() => _cancelando = true);
                          try {
                            await repo.cancelarCita(
                              cita.id,
                              motivo: 'Cancelada desde detalle de cita',
                            );
                            ref.invalidate(citaByIdProvider(widget.citaId));
                            final barbershop = ref
                                .read(myBarbershopProvider)
                                .valueOrNull;
                            if (barbershop != null) {
                              ref.invalidate(misCitasProvider(barbershop.id));
                            }
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No pudimos cancelar la cita. Intenta de nuevo.',
                                  ),
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _cancelando = false);
                            }
                          }
                        },
                  child: _cancelando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Cancelar cita'),
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
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.textMutedOf(context).withValues(alpha: 0.2),
        ),
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
