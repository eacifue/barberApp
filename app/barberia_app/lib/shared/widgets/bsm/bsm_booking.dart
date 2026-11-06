import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../format/formato.dart';

const _tabular = [FontFeature.tabularFigures()];

/// Progreso de la reserva: «Paso X de 4» + cuatro segmentos con nombre.
/// Tocar un paso hecho regresa a él conservando la selección.
class BookingStepper extends StatelessWidget {
  const BookingStepper({super.key, required this.current, this.steps = const ['Servicio', 'Barbero', 'Horario', 'Confirmar'], this.onStep});

  /// 1–4
  final int current;
  final List<String> steps;
  final ValueChanged<int>? onStep;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      label: 'Paso $current de ${steps.length}, ${steps[current - 1]}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: 'Paso $current de ${steps.length}',
              style: AppTextStyles.weight(AppTextStyles.caption, FontWeight.w600).copyWith(color: p.ink, fontSize: 13),
              children: [TextSpan(text: ' · ${steps[current - 1]}', style: AppTextStyles.caption.copyWith(color: p.inkMuted, fontSize: 13))],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(child: _step(context, p, i + 1, steps[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _step(BuildContext context, AppPalette p, int n, String label) {
    final done = n < current;
    final isCurrent = n == current;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 4, decoration: BoxDecoration(color: done || isCurrent ? p.brass : p.line, borderRadius: BorderRadius.circular(4))),
        const SizedBox(height: 6),
        Row(
          children: [
            if (done) ...[Icon(LucideIcons.check, size: 14, color: p.brassInk), const SizedBox(width: 2)],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: (isCurrent ? AppTextStyles.weight(AppTextStyles.caption, FontWeight.w600) : AppTextStyles.caption)
                    .copyWith(color: done || isCurrent ? p.ink : p.inkMuted),
              ),
            ),
          ],
        ),
      ],
    );
    if (!done || onStep == null) return ExcludeSemantics(child: body);
    return InkWell(
      onTap: () => onStep!(n),
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: Semantics(button: true, label: 'Volver a $label', excludeSemantics: true, child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 44), child: body)),
    );
  }
}

/// Calendario mensual: lunes primero, hoy con anillo, día elegido en latón,
/// días sin atención deshabilitados; punto naranja = pocos horarios.
class BsmCalendar extends StatelessWidget {
  const BsmCalendar({
    super.key,
    required this.month,
    required this.onSelect,
    this.selected,
    this.today,
    this.isDisabled,
    this.fewSlots = const {},
    this.anySlots = const {},
    this.onPrevMonth,
    this.onNextMonth,
    this.legend,
  });

  /// Cualquier fecha del mes a mostrar.
  final DateTime month;
  final DateTime? selected;
  final DateTime? today;
  final bool Function(DateTime day)? isDisabled;

  /// Días (número) con pocos horarios libres.
  final Set<int> fewSlots;

  /// Días (número) con horarios.
  final Set<int> anySlots;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;
  final String? legend;

  bool _same(DateTime? a, DateTime b) => a != null && a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final first = DateTime(month.year, month.month);
    final offset = first.weekday - 1;
    final days = DateTime(month.year, month.month + 1, 0).day;
    final cells = <DateTime?>[...List<DateTime?>.filled(offset, null), for (var d = 1; d <= days; d++) DateTime(month.year, month.month, d)];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    const weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    const weekdayNames = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Text(Formato.mesAnio(first), style: AppTextStyles.titleSm.copyWith(color: p.ink)),
              ),
            ),
            IconButton(tooltip: 'Mes anterior', onPressed: onPrevMonth, icon: const Icon(LucideIcons.chevronLeft, size: 20)),
            IconButton(tooltip: 'Mes siguiente', onPressed: onNextMonth, icon: const Icon(LucideIcons.chevronRight, size: 20)),
          ],
        ),
        const SizedBox(height: AppSpace.s2),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Semantics(
                  label: weekdayNames[i],
                  excludeSemantics: true,
                  child: SizedBox(
                    height: 32,
                    child: Center(child: Text(weekdays[i], style: AppTextStyles.weight(AppTextStyles.caption, FontWeight.w600).copyWith(color: p.inkMuted))),
                  ),
                ),
              ),
          ],
        ),
        for (var r = 0; r < cells.length / 7; r++)
          Row(
            children: [
              for (final day in cells.sublist(r * 7, r * 7 + 7))
                Expanded(child: day == null ? const SizedBox(height: 46) : _day(p, day)),
            ],
          ),
        if (legend != null) ...[
          const SizedBox(height: AppSpace.s2),
          Text(legend!, style: AppTextStyles.caption.copyWith(color: p.inkMuted)),
        ],
      ],
    );
  }

  Widget _day(AppPalette p, DateTime day) {
    final disabled = isDisabled?.call(day) ?? false;
    final isSel = _same(selected, day);
    final isToday = _same(today, day);
    final few = fewSlots.contains(day.day);
    final any = anySlots.contains(day.day);
    final fg = isSel ? p.onBrass : (disabled ? p.inkDisabled : p.ink);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Center(
        child: Semantics(
          button: true,
          selected: isSel,
          enabled: !disabled,
          label: '${Formato.fechaLarga(day)}${isToday ? ', hoy' : ''}${few ? ', pocos horarios' : ''}${disabled ? ', sin horarios' : ''}',
          excludeSemantics: true,
          child: Material(
            color: isSel ? p.brass : Colors.transparent,
            shape: CircleBorder(side: isToday && !isSel ? BorderSide(color: p.brassInk, width: 1.5) : BorderSide.none),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: disabled ? null : () => onSelect(day),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '${day.day}',
                      style: AppTextStyles.weight(AppTextStyles.bodyLg, isSel || isToday ? FontWeight.w700 : FontWeight.w500)
                          .copyWith(fontSize: 15, color: fg, fontFeatures: _tabular),
                    ),
                    if (few || any)
                      Positioned(
                        bottom: 6,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: isSel ? p.onBrass : (few ? p.warning : p.brassInk)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Horario elegible del paso 3. `available: false` = tachado, no enfocable; el
/// cliente no ve por qué (ocupado, bloqueado o en reserva).
class SlotItem {
  const SlotItem({required this.hour, required this.minute, this.available = true});

  final int hour;
  final int minute;
  final bool available;

  int get minutes => hour * 60 + minute;
  String get key => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// Grilla de horarios agrupada en Mañana / Tarde / Noche.
class SlotGrid extends StatelessWidget {
  const SlotGrid({super.key, required this.slots, required this.onSelect, this.selected});

  final List<SlotItem> slots;

  /// `HH:mm` del horario elegido.
  final String? selected;
  final ValueChanged<SlotItem> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const groups = [('Mañana', 0, 720, 'a. m.'), ('Tarde', 720, 1080, 'p. m.'), ('Noche', 1080, 1440, 'p. m.')];
    return LayoutBuilder(
      builder: (context, c) {
        final columns = ((c.maxWidth + AppSpace.s2) / (76 + AppSpace.s2)).floor().clamp(3, 8).toInt();
        final cell = (c.maxWidth - AppSpace.s2 * (columns - 1)) / columns;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (name, from, to, sfx) in groups)
              if (slots.any((s) => s.minutes >= from && s.minutes < to)) ...[
                Text.rich(
                  TextSpan(
                    text: name.toUpperCase(),
                    style: AppTextStyles.overline.copyWith(color: p.inkMuted),
                    children: [TextSpan(text: ' · $sfx', style: AppTextStyles.caption.copyWith(color: p.inkMuted, letterSpacing: 0))],
                  ),
                ),
                const SizedBox(height: AppSpace.s2),
                Wrap(
                  spacing: AppSpace.s2,
                  runSpacing: AppSpace.s2,
                  children: [
                    for (final s in slots.where((s) => s.minutes >= from && s.minutes < to)) SizedBox(width: cell, child: _slot(p, s)),
                  ],
                ),
                const SizedBox(height: AppSpace.s4),
              ],
          ],
        );
      },
    );
  }

  Widget _slot(AppPalette p, SlotItem s) {
    final sel = selected == s.key;
    final label = Formato.horaDe(s.hour, s.minute);
    final short = label.split(' ').first;
    if (!s.available) {
      return ExcludeFocus(
        child: Semantics(
          label: '$label, no disponible',
          enabled: false,
          excludeSemantics: true,
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: p.surfaceSunken, borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: Text(short, style: AppTextStyles.label.copyWith(color: p.inkDisabled, decoration: TextDecoration.lineThrough, fontFeatures: _tabular)),
          ),
        ),
      );
    }
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: sel,
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: sel ? p.brass : p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(color: sel ? p.brass : p.lineStrong),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: () => onSelect(s),
          child: SizedBox(
            height: 44,
            child: Center(child: Text(short, style: AppTextStyles.label.copyWith(color: sel ? p.onBrass : p.ink, fontFeatures: _tabular))),
          ),
        ),
      ),
    );
  }
}

/// Cuenta regresiva del horario apartado, presentacional: recibe los segundos
/// restantes (p. ej. de `DisponibilidadNotifier`). Latón hasta 1:01; en el
/// último minuto pasa a `warning` y lo anuncia una sola vez. Sigue con
/// «reducir movimiento».
class BsmCountdownView extends StatelessWidget {
  const BsmCountdownView({super.key, required this.seconds, this.totalSeconds = 300, this.compact = false, this.label});

  final int seconds;
  final int totalSeconds;
  final bool compact;

  /// Etiqueta antes del último minuto (por defecto «Horario apartado por»).
  final String? label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = seconds < 0 ? 0 : seconds;
    final low = s <= 60;
    final mm = s ~/ 60;
    final ss = (s % 60).toString().padLeft(2, '0');
    final accent = low ? p.warning : p.brass;
    final fraction = totalSeconds <= 0 ? 0.0 : (s / totalSeconds).clamp(0.0, 1.0).toDouble();

    return Semantics(
      label: 'Tiempo restante $mm minutos ${s % 60} segundos',
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          color: low ? p.warningBg : p.brassSoft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: compact ? const EdgeInsets.fromLTRB(12, 8, 12, 6) : const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Row(
                  children: [
                    Icon(LucideIcons.timer, size: 20, color: low ? p.warning : p.brassInk),
                    const SizedBox(width: AppSpace.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            low ? 'Tu horario se libera en' : (label ?? 'Horario apartado por'),
                            style: AppTextStyles.weight(AppTextStyles.body, FontWeight.w600).copyWith(color: p.ink),
                          ),
                          if (!compact)
                            Text(
                              low ? 'Confirma ahora para no perderlo.' : 'Lo guardamos 5 min mientras confirmas.',
                              style: AppTextStyles.caption.copyWith(color: p.inkMuted, fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '$mm:$ss',
                      style: (compact ? AppTextStyles.numeric.copyWith(fontSize: 20, height: 24 / 20) : AppTextStyles.numeric)
                          .copyWith(color: low ? p.warning : p.ink),
                    ),
                  ],
                ),
              ),
              LinearProgressIndicator(value: fraction, minHeight: 4, color: accent, backgroundColor: p.line),
              // Región viva: el texto aparece una vez al entrar al último minuto.
              Semantics(
                liveRegion: true,
                child: SizedBox(
                  height: 0,
                  child: Text(low && s > 0 ? 'Queda menos de un minuto para confirmar tu horario.' : '', style: const TextStyle(fontSize: 0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cuenta regresiva autónoma contra la expiración del servidor (no resta en
/// local). Vibra al entrar al último minuto y avisa al expirar.
class BsmCountdown extends StatefulWidget {
  const BsmCountdown({super.key, required this.expiresAt, this.total = const Duration(minutes: 5), this.compact = false, this.onExpired});

  final DateTime expiresAt;
  final Duration total;
  final bool compact;
  final VoidCallback? onExpired;

  @override
  State<BsmCountdown> createState() => _BsmCountdownState();
}

class _BsmCountdownState extends State<BsmCountdown> {
  Timer? _timer;
  bool _warned = false;
  bool _expired = false;

  Duration get _left {
    final d = widget.expiresAt.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didUpdateWidget(BsmCountdown old) {
    super.didUpdateWidget(old);
    if (old.expiresAt != widget.expiresAt) {
      _warned = false;
      _expired = false;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  void _tick() {
    if (!mounted) return;
    final left = _left;
    if (!_warned && left.inSeconds <= 60 && left > Duration.zero) {
      _warned = true;
      HapticFeedback.mediumImpact();
    }
    if (left == Duration.zero && !_expired) {
      _expired = true;
      _timer?.cancel();
      widget.onExpired?.call();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BsmCountdownView(seconds: _left.inSeconds, totalSeconds: widget.total.inSeconds, compact: widget.compact);
}
