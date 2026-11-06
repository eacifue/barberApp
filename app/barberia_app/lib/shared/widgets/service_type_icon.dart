import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Ícono del tipo de servicio (design/docs/00-sistema.md · Iconografía):
/// Corte `scissors`, Afeitado `navaja`, Barba `barba`, Tinte `droplets`,
/// Tratamiento `sparkles`, Combo `layers`, Otro `ellipsis`, dibujados con la
/// misma gramática que Lucide en `assets/icons/`.
class ServiceTypeIcon extends StatelessWidget {
  const ServiceTypeIcon({super.key, required this.tipo, this.size = 24, this.color});

  /// Tipo tal como llega del backend (`Corte`, `Afeitado`, …) o un nombre libre.
  final String tipo;
  final double size;

  /// Por defecto `brass-ink`.
  final Color? color;

  static String assetFor(String tipo) {
    final t = tipo.toLowerCase();
    if (t.contains('combo')) return 'assets/icons/combo.svg';
    if (t.contains('afeit')) return 'assets/icons/afeitado.svg';
    if (t.contains('barba')) return 'assets/icons/barba.svg';
    if (t.contains('tinte')) return 'assets/icons/tinte.svg';
    if (t.contains('tratam')) return 'assets/icons/tratamiento.svg';
    if (t.contains('corte')) return 'assets/icons/corte.svg';
    return 'assets/icons/otro.svg';
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetFor(tipo),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color ?? context.palette.brassInk, BlendMode.srcIn),
      excludeFromSemantics: true,
    );
  }
}

/// Cuadro de 48 px en `brass-soft` con el ícono del tipo en `brass-ink`.
class ServiceTypeBadge extends StatelessWidget {
  const ServiceTypeBadge({super.key, required this.tipo, this.size = 48});

  final String tipo;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: p.brassSoft, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: ServiceTypeIcon(tipo: tipo, size: size / 2),
    );
  }
}
