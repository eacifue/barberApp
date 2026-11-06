import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';

/// Estado de una cita = color + ícono + palabra, igual en app, panel y agenda
/// (design/docs/componentes/StatusBadge.md).
enum AppointmentStatus {
  pendiente('Pendiente', LucideIcons.hourglass),
  confirmada('Confirmada', LucideIcons.circleCheck),
  enProgreso('En progreso', LucideIcons.scissors),
  completada('Completada', LucideIcons.checkCheck),
  cancelada('Cancelada', LucideIcons.circleX),
  noShow('No asistió', LucideIcons.userX);

  const AppointmentStatus(this.label, this.icon);

  final String label;
  final IconData icon;

  /// Valores del backend: `Pendiente`, `Confirmada`, `EnProgreso`, `Completada`, `Cancelada`, `NoShow`.
  static AppointmentStatus fromBackend(String? value) {
    switch ((value ?? '').toLowerCase().replaceAll(RegExp(r'[\s_]'), '')) {
      case 'confirmada':
        return AppointmentStatus.confirmada;
      case 'enprogreso':
        return AppointmentStatus.enProgreso;
      case 'completada':
        return AppointmentStatus.completada;
      case 'cancelada':
        return AppointmentStatus.cancelada;
      case 'noshow':
      case 'noasistio':
        return AppointmentStatus.noShow;
      default:
        return AppointmentStatus.pendiente;
    }
  }

  Color color(AppPalette p) => switch (this) {
        AppointmentStatus.pendiente => p.statusPendiente,
        AppointmentStatus.confirmada => p.statusConfirmada,
        AppointmentStatus.enProgreso => p.statusEnprogreso,
        AppointmentStatus.completada => p.statusCompletada,
        AppointmentStatus.cancelada => p.statusCancelada,
        AppointmentStatus.noShow => p.statusNoshow,
      };

  Color background(AppPalette p) => switch (this) {
        AppointmentStatus.pendiente => p.statusPendienteBg,
        AppointmentStatus.confirmada => p.statusConfirmadaBg,
        AppointmentStatus.enProgreso => p.statusEnprogresoBg,
        AppointmentStatus.completada => p.statusCompletadaBg,
        AppointmentStatus.cancelada => p.statusCanceladaBg,
        AppointmentStatus.noShow => p.statusNoshowBg,
      };

  /// Se puede reprogramar o cancelar desde el detalle.
  bool get isUpcoming => this == AppointmentStatus.pendiente || this == AppointmentStatus.confirmada;
}
