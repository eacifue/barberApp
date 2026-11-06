import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../barberias/presentation/providers/barbershops_provider.dart';
import '../../../../features/citas/presentation/providers/reserva_notifier.dart';
import '../../../../shared/extensions/date_extensions.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../domain/slot_model.dart';
import '../providers/disponibilidad_provider.dart';
import '../providers/disponibilidad_state.dart';

class SeleccionHorarioScreen extends ConsumerStatefulWidget {
  const SeleccionHorarioScreen({super.key});

  @override
  ConsumerState<SeleccionHorarioScreen> createState() =>
      _SeleccionHorarioScreenState();
}

class _SeleccionHorarioScreenState
    extends ConsumerState<SeleccionHorarioScreen> {
  DateTime _focusedDay = DateTime.now();
  late final ProviderSubscription<DisponibilidadState> _disponibilidadSub;

  @override
  void initState() {
    super.initState();
    _disponibilidadSub = ref.listenManual<DisponibilidadState>(
      disponibilidadNotifierProvider,
      (prev, next) {
        final before = prev?.expiracionEventoId ?? 0;
        if (next.expiracionEventoId <= before || !mounted) {
          return;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }

          showDialog<void>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Tiempo expirado'),
                content: const Text('El tiempo expiró. Selecciona de nuevo.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Entendido'),
                  ),
                ],
              );
            },
          );
        });
      },
    );
  }

  @override
  void dispose() {
    _disponibilidadSub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reserva = ref.watch(reservaNotifierProvider);
    final disponibilidadState = ref.watch(disponibilidadNotifierProvider);
    final notifier = ref.read(disponibilidadNotifierProvider.notifier);
    final barbero = reserva.barberoSeleccionado;
    final servicio = reserva.servicioSeleccionado;
    final slotSeleccionado = disponibilidadState.slotSeleccionado;

    final barbershop = ref.watch(myBarbershopProvider).valueOrNull;
    bool esDiaLaborable(DateTime date) {
      if (barbershop == null) {
        return true;
      }
      return barbershop.esDiaLaborable(date);
    }

    if (barbero == null || servicio == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Selecciona fecha y hora')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.info,
                  color: AppColors.primary,
                  size: 44,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Primero selecciona un servicio y un barbero para continuar.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.go('/reservar/servicio'),
                  child: const Text('Volver al flujo'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final disponibilidadAsync = ref.watch(
      disponibilidadProvider(
        barberoId: barbero.id,
        servicioId: servicio.id,
        fecha: disponibilidadState.fechaSeleccionada,
      ),
    );

    Future<void> goBackAndRelease() async {
      final router = GoRouter.of(context);
      await notifier.salirPantalla(barberoId: barbero.id);
      if (!mounted) {
        return;
      }
      router.go('/reservar/barbero');
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await goBackAndRelease();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Selecciona fecha y hora'),
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: goBackAndRelease,
          ),
        ),
        bottomNavigationBar: slotSeleccionado == null
            ? null
            : _BottomReservaBar(
                slot: slotSeleccionado,
                duracionMin: servicio.duracionMinutos,
                estaBloqueando: disponibilidadState.estaBloqueando,
                tiempoRestante: disponibilidadState.tiempoRestanteTexto,
                onContinuar: () => context.go('/reservar/confirm'),
              ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          children: [
            const _ReservaProgressStep3(),
            const SizedBox(height: 12),
            _ContextoReservaCard(
              barberoNombre: barbero.nombreCompleto,
              servicioNombre: servicio.nombre,
              duracionMin: servicio.duracionMinutos,
            ),
            const SizedBox(height: 12),
            _CalendarioMensual(
              focusedDay: _focusedDay,
              fechaSeleccionada: disponibilidadState.fechaSeleccionada,
              selectableDayPredicate: esDiaLaborable,
              onFocusedChanged: (focused) =>
                  setState(() => _focusedDay = focused),
              onDaySelected: (selected, focused) async {
                setState(() => _focusedDay = focused);
                await notifier.seleccionarFecha(
                  fecha: selected,
                  barberoId: barbero.id,
                  servicioId: servicio.id,
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Horarios disponibles para ${disponibilidadState.fechaSeleccionada.toHumanDate}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            disponibilidadAsync.when(
              loading: () => const _LoadingSlotsGrid(),
              error: (error, stackTrace) => BarberiaErrorWidget(
                message: 'No pudimos cargar los horarios. Intenta nuevamente.',
                onRetry: () => ref.refresh(
                  disponibilidadProvider(
                    barberoId: barbero.id,
                    servicioId: servicio.id,
                    fecha: disponibilidadState.fechaSeleccionada,
                  ),
                ),
              ),
              data: (data) {
                if (data.slots.isEmpty) {
                  return const _EmptySlots();
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.slots.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2.3,
                  ),
                  itemBuilder: (context, index) {
                    final slot = data.slots[index];
                    final isSelected =
                        disponibilidadState
                            .slotSeleccionado
                            ?.horaInicioFormateada ==
                        slot.horaInicioFormateada;

                    return _SlotChip(
                      slot: slot,
                      isSelected: isSelected,
                      onTap: () async {
                        final error = await notifier.seleccionarSlot(
                          slot: slot,
                          barberoId: barbero.id,
                          servicioId: servicio.id,
                        );

                        if (!context.mounted) {
                          return;
                        }

                        if (error != null) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(error)));
                        }
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservaProgressStep3 extends StatelessWidget {
  const _ReservaProgressStep3();

  static const _steps = ['Servicio', 'Barbero', 'Horario', 'Confirmar'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paso 3 de 4', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < _steps.length; i++) ...[
              Expanded(
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: i <= 2
                        ? AppColors.primary
                        : AppColors.textMutedOf(
                            context,
                          ).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              if (i < _steps.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }
}

class _ContextoReservaCard extends StatelessWidget {
  const _ContextoReservaCard({
    required this.barberoNombre,
    required this.servicioNombre,
    required this.duracionMin,
  });

  final String barberoNombre;
  final String servicioNombre;
  final int duracionMin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.user, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$barberoNombre · $servicioNombre · $duracionMin min',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, fontVariations: const [FontVariation('wght', 700.0)]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarioMensual extends StatelessWidget {
  const _CalendarioMensual({
    required this.focusedDay,
    required this.fechaSeleccionada,
    required this.selectableDayPredicate,
    required this.onFocusedChanged,
    required this.onDaySelected,
  });

  final DateTime focusedDay;
  final DateTime fechaSeleccionada;
  final bool Function(DateTime day) selectableDayPredicate;
  final ValueChanged<DateTime> onFocusedChanged;
  final void Function(DateTime selected, DateTime focused) onDaySelected;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);
    final last = first.add(const Duration(days: 30));
    final safeInitial = _coerceSelectableDate(
      date: fechaSeleccionada,
      first: first,
      last: last,
      selectableDayPredicate: selectableDayPredicate,
    );
    final safeCurrent = _coerceSelectableDate(
      date: focusedDay,
      first: first,
      last: last,
      selectableDayPredicate: selectableDayPredicate,
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Calendario', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          CalendarDatePicker(
            initialDate: safeInitial,
            currentDate: safeCurrent,
            firstDate: first,
            lastDate: last,
            selectableDayPredicate: selectableDayPredicate,
            onDateChanged: (selected) {
              onFocusedChanged(selected);
              onDaySelected(selected, selected);
            },
          ),
        ],
      ),
    );
  }
}

DateTime _coerceSelectableDate({
  required DateTime date,
  required DateTime first,
  required DateTime last,
  required bool Function(DateTime day) selectableDayPredicate,
}) {
  var candidate = DateTime(date.year, date.month, date.day);
  final firstDate = DateTime(first.year, first.month, first.day);
  final lastDate = DateTime(last.year, last.month, last.day);

  if (candidate.isBefore(firstDate)) {
    candidate = firstDate;
  }
  if (candidate.isAfter(lastDate)) {
    candidate = lastDate;
  }

  while (!selectableDayPredicate(candidate) && candidate.isBefore(lastDate)) {
    candidate = candidate.add(const Duration(days: 1));
  }

  while (!selectableDayPredicate(candidate) && candidate.isAfter(firstDate)) {
    candidate = candidate.subtract(const Duration(days: 1));
  }

  return candidate;
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final SlotModel slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unavailable = !slot.disponible;
    final blocked = slot.bloqueadoPorRedis;

    Color background = AppColors.secondaryOf(context).withValues(alpha: 0.12);
    Color textColor = AppColors.textPrimaryOf(context);
    Widget? trailing;

    if (isSelected) {
      background = AppColors.primary.withValues(alpha: 0.12);
      trailing = const Icon(
        LucideIcons.circleCheck,
        size: 14,
        color: AppColors.primary,
      );
    } else if (blocked) {
      background = AppColors.warning.withValues(alpha: 0.25);
      textColor = AppColors.warning;
      trailing = const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(strokeWidth: 1.8),
      );
    } else if (unavailable) {
      background = AppColors.textMutedOf(context).withValues(alpha: 0.25);
      textColor = AppColors.textMutedOf(context);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slot.horaInicioFormateada,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700, fontVariations: const [FontVariation('wght', 700.0)],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 6), trailing],
              ],
            ),
            if (blocked && slot.minutosRestantesBloqueo != null)
              Text(
                '${slot.minutosRestantesBloqueo} min',
                style: TextStyle(
                  color: textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600, fontVariations: const [FontVariation('wght', 600.0)],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LoadingSlotsGrid extends StatelessWidget {
  const _LoadingSlotsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.3,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.backgroundOf(context),
          highlightColor: AppColors.shimmerHighlightOf(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}

class _EmptySlots extends StatelessWidget {
  const _EmptySlots();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Text(
          'No hay horarios para este día. Prueba con otra fecha.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class _BottomReservaBar extends StatelessWidget {
  const _BottomReservaBar({
    required this.slot,
    required this.duracionMin,
    required this.estaBloqueando,
    required this.tiempoRestante,
    required this.onContinuar,
  });

  final SlotModel slot;
  final int duracionMin;
  final bool estaBloqueando;
  final String tiempoRestante;
  final VoidCallback onContinuar;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          border: Border(
            top: BorderSide(
              color: AppColors.textMutedOf(context).withValues(alpha: 0.22),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccionaste las ${slot.horaInicioFormateada} · $duracionMin min',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700, fontVariations: const [FontVariation('wght', 700.0)]),
            ),
            const SizedBox(height: 8),
            if (estaBloqueando) const LinearProgressIndicator(),
            if (estaBloqueando) const SizedBox(height: 8),
            Text(
              'Tiempo restante: $tiempoRestante',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700, fontVariations: const [FontVariation('wght', 700.0)],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: estaBloqueando ? null : onContinuar,
                icon: const Icon(LucideIcons.arrowRight, size: 18),
                label: const Text('CONTINUAR'),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Este horario se reserva por 5 min mientras confirmas',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
