import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/bsm/bsm.dart';

/// Hora `HH:mm[:ss]` del backend sobre la fecha de la cita.
DateTime fechaConHora(DateTime fecha, String hora) {
  final parts = hora.split(':');
  return DateTime(fecha.year, fecha.month, fecha.day, int.tryParse(parts[0]) ?? 0, parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0);
}

String capitalizar(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

/// Marco de los pasos de la reserva (design/docs/02-patrones.md · Reserva):
/// flecha atrás, Stepper, título `display` y barra fija inferior.
class BookingScaffold extends StatelessWidget {
  const BookingScaffold({
    super.key,
    required this.step,
    required this.title,
    required this.children,
    this.onBack,
    this.backLabel,
    this.onStep,
    this.bottom,
  });

  final int step;
  final String title;
  final List<Widget> children;
  final VoidCallback? onBack;
  final String? backLabel;
  final ValueChanged<int>? onStep;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      bottomNavigationBar: bottom,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.s4, AppSpace.s1, AppSpace.s4, AppSpace.s6),
          children: [
            if (onBack != null)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: backLabel ?? 'Volver',
                  onPressed: onBack,
                  icon: const Icon(LucideIcons.arrowLeft, size: 24),
                  style: IconButton.styleFrom(foregroundColor: p.ink),
                ),
              )
            else
              const SizedBox(height: AppSpace.s3),
            const SizedBox(height: AppSpace.s1),
            BookingStepper(current: step, onStep: onStep),
            const SizedBox(height: AppSpace.s4),
            Semantics(header: true, child: Text(title, style: AppTextStyles.display.copyWith(color: p.ink))),
            const SizedBox(height: AppSpace.s5),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Barra fija inferior: resumen de lo elegido + CTA `lg`. Sin resumen, el
/// botón ocupa todo el ancho. [top] va encima (p. ej. la cuenta regresiva).
class BookingBottomBar extends StatelessWidget {
  const BookingBottomBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.title,
    this.subtitle,
    this.hint,
    this.loading = false,
    this.top,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? title;
  final String? subtitle;

  /// Texto atenuado cuando aún no hay selección («Elige un horario para continuar»).
  final String? hint;
  final bool loading;
  final Widget? top;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final hasSummary = title != null || hint != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.line)),
        boxShadow: const [BoxShadow(color: Color(0x0F1C1814), blurRadius: 2, offset: Offset(0, -1))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.s4, AppSpace.s3, AppSpace.s4, AppSpace.s3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (top != null) ...[top!, const SizedBox(height: AppSpace.s3)],
              if (hasSummary)
                Row(
                  children: [
                    Expanded(
                      child: title != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.titleSm.copyWith(color: p.ink)),
                                if (subtitle != null)
                                  Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.body.copyWith(color: p.inkMuted)),
                              ],
                            )
                          : Text(hint!, style: AppTextStyles.body.copyWith(color: p.inkMuted)),
                    ),
                    const SizedBox(width: AppSpace.s3),
                    BsmButton(label: label, size: BsmButtonSize.lg, onPressed: onPressed, loading: loading),
                  ],
                )
              else
                BsmButton(label: label, size: BsmButtonSize.lg, block: true, onPressed: onPressed, loading: loading),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta plana de resumen con secciones separadas por hilos.
class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(color: p.surface, border: Border.all(color: p.line), borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, color: p.line),
            Padding(padding: const EdgeInsets.all(AppSpace.s4), child: children[i]),
          ],
        ],
      ),
    );
  }
}

/// Rótulo `overline` (SERVICIO, FECHA Y HORA): la única mayúscula del sistema.
class Overline extends StatelessWidget {
  const Overline(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: AppTextStyles.overline.copyWith(color: context.palette.inkMuted));
}
