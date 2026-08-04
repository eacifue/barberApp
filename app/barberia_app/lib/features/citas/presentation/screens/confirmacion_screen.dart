import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../barberias/presentation/providers/barbershops_provider.dart';
import '../../../../features/horarios/presentation/providers/disponibilidad_provider.dart';
import '../../domain/models/cita_model.dart';
import '../providers/citas_provider.dart';
import '../providers/reprogramacion_provider.dart';
import '../providers/reserva_notifier.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_widget.dart';

class ConfirmacionScreen extends ConsumerStatefulWidget {
  const ConfirmacionScreen({super.key});

  @override
  ConsumerState<ConfirmacionScreen> createState() => _ConfirmacionScreenState();
}

class _ConfirmacionScreenState extends ConsumerState<ConfirmacionScreen> {
  final _notasController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }

  Future<bool> _confirmarSalida() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Salir de la confirmación?'),
            content: const Text('Tu horario temporal podría liberarse.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Continuar aquí'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Salir'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final reserva = ref.watch(reservaNotifierProvider);
    final horarioState = ref.watch(disponibilidadNotifierProvider);
    final citaRepo = ref.watch(citaRepositoryProvider);
    final router = GoRouter.of(context);
    final barbershopAsync = ref.watch(myBarbershopProvider);
    final citaIdAReprogramar = ref.watch(citaIdAReprogramarProvider);

    final servicio = reserva.servicioSeleccionado;
    final barbero = reserva.barberoSeleccionado;
    final slot = reserva.slotSeleccionado;
    final fecha = reserva.fechaSeleccionada;
    final token = reserva.tokenBloqueo;

    if (servicio == null ||
        barbero == null ||
        slot == null ||
        fecha == null ||
        token == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Confirma tu reserva')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/reservar/servicio'),
            child: const Text('Completar flujo de reserva'),
          ),
        ),
      );
    }

    return barbershopAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Confirma tu reserva')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Confirma tu reserva')),
        body: BarberiaErrorWidget(
          message: 'No pudimos cargar la información de tu barbería.',
          onRetry: () => ref.refresh(myBarbershopProvider),
        ),
      ),
      data: (barbershop) {
        if (barbershop == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Confirma tu reserva')),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No hay una barbería configurada. Contacta al administrador.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final barberiaId = barbershop.id;
        final fechaLarga = DateFormat(
          "EEEE d 'de' MMMM, y",
          'es_CO',
        ).format(fecha);
        final isUrgent =
            horarioState.tiempoRestanteSegundos > 0 &&
            horarioState.tiempoRestanteSegundos < 60;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Confirma tu reserva'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: () async {
                  final salir = await _confirmarSalida();
                  if (!salir || !context.mounted) {
                    return;
                  }
                  await ref
                      .read(disponibilidadNotifierProvider.notifier)
                      .salirPantalla(barberoId: barbero.id);
                  ref.read(reservaNotifierProvider.notifier).resetReserva();
                  ref.read(citaIdAReprogramarProvider.notifier).state = null;
                  if (!context.mounted) {
                    return;
                  }
                  router.go('/dashboard');
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          body: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) {
                return;
              }
              final salir = await _confirmarSalida();
              if (!salir || !context.mounted) {
                return;
              }
              await ref
                  .read(disponibilidadNotifierProvider.notifier)
                  .salirPantalla(barberoId: barbero.id);
              ref.read(reservaNotifierProvider.notifier).resetReserva();
              ref.read(citaIdAReprogramarProvider.notifier).state = null;
              if (!context.mounted) {
                return;
              }
              router.go('/dashboard');
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (citaIdAReprogramar != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event_repeat_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Estás reprogramando tu cita. Al confirmar, la anterior se cancelará automáticamente.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Container(
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
                      _Section(
                        title: 'SERVICIO',
                        child: Text(
                          '${servicio.nombre} · ${servicio.duracionMinutos} minutos',
                        ),
                      ),
                      _Section(
                        title: 'BARBERO',
                        child: Text(
                          '${barbero.nombreCompleto} · ${barbero.ratingText}',
                        ),
                      ),
                      _Section(
                        title: 'FECHA Y HORA',
                        child: Text(
                          '$fechaLarga\n${slot.horaInicioFormateada} — ${slot.horaFinFormateada}',
                        ),
                      ),
                      _Section(
                        title: 'PRECIO',
                        footer: Text(
                          'Pago en el local',
                          style: TextStyle(
                            color: AppColors.textMutedOf(context),
                          ),
                        ),
                        child: Text(
                          NumberFormat.currency(
                            locale: 'es_CO',
                            symbol: r'$',
                            decimalDigits: 0,
                          ).format(servicio.precio),
                        ),
                      ),
                      if (horarioState.tiempoRestanteSegundos > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: horarioState.tiempoRestanteSegundos / 300,
                              color: isUrgent
                                  ? AppColors.error
                                  : AppColors.primary,
                              backgroundColor: AppColors.textMutedOf(
                                context,
                              ).withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Completa tu reserva en: ${horarioState.tiempoRestanteTexto}',
                              style: TextStyle(
                                color: isUrgent
                                    ? AppColors.error
                                    : AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _notasController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Alguna nota para el barbero (opcional)',
                  ),
                ),
                const SizedBox(height: 18),
                AppButton(
                  label: 'Reservar ahora',
                  isLoading: _loading,
                  onPressed: () async {
                    setState(() => _loading = true);
                    try {
                      final cita = await citaRepo.crearCita(
                        CrearCitaRequestModel(
                          barberoId: barbero.id,
                          servicioId: servicio.id,
                          fechaCita: fecha,
                          horaInicio: slot.horaInicioFormateada,
                          tokenRedisBloqueo: token,
                          notas: _notasController.text.trim().isEmpty
                              ? null
                              : _notasController.text.trim(),
                        ),
                      );

                      ref.invalidate(misCitasProvider(barberiaId));
                      await ref
                          .read(disponibilidadNotifierProvider.notifier)
                          .salirPantalla(barberoId: barbero.id);
                      ref.read(reservaNotifierProvider.notifier).resetReserva();

                      if (citaIdAReprogramar != null) {
                        try {
                          await citaRepo.cancelarCita(
                            citaIdAReprogramar,
                            motivo: 'Reprogramada por el cliente',
                          );
                          ref.invalidate(citaByIdProvider(citaIdAReprogramar));
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Tu nueva cita quedó confirmada, pero no pudimos '
                                  'cancelar la anterior automáticamente. '
                                  'Cancélala manualmente si sigue apareciendo activa.',
                                ),
                              ),
                            );
                          }
                        } finally {
                          ref.read(citaIdAReprogramarProvider.notifier).state =
                              null;
                        }
                      }

                      if (!context.mounted) {
                        return;
                      }
                      router.go('/reservar/exito', extra: cita);
                    } on ValidationException catch (ex) {
                      // Validation failures from the backend at this step are
                      // almost always "this slot is no longer available" — send
                      // the user back to pick a new time instead of retrying
                      // the same (now invalid) confirmation.
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(ex.message)));
                      router.go('/reservar/horario');
                    } on AppException catch (ex) {
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(ex.message)));
                    } catch (_) {
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No pudimos confirmar la cita. Intenta de nuevo.',
                          ),
                        ),
                      );
                    } finally {
                      if (mounted) {
                        setState(() => _loading = false);
                      }
                    }
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          final confirmado =
                              await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Cancelar reserva'),
                                  content: const Text(
                                    '¿Seguro que deseas cancelar este proceso?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('No'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Sí, cancelar'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                          if (!confirmado || !context.mounted) {
                            return;
                          }
                          await ref
                              .read(disponibilidadNotifierProvider.notifier)
                              .salirPantalla(barberoId: barbero.id);
                          ref
                              .read(reservaNotifierProvider.notifier)
                              .resetReserva();
                          ref.read(citaIdAReprogramarProvider.notifier).state =
                              null;
                          if (!context.mounted) {
                            return;
                          }
                          router.go('/dashboard');
                        },
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, this.footer, required this.child});

  final String title;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          child,
          if (footer != null) ...[const SizedBox(height: 4), footer!],
        ],
      ),
    );
  }
}
