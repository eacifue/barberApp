import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/cita_model.dart';

class CitaCard extends StatelessWidget {
  const CitaCard({
    super.key,
    required this.cita,
    required this.onTap,
    this.onCancelar,
  });

  final CitaModel cita;
  final VoidCallback onTap;
  final VoidCallback? onCancelar;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat("EEEE d 'de' MMMM", 'es_CO').format(cita.fechaCita);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textMutedOf(context).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 132,
              decoration: BoxDecoration(
                color: cita.estadoColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Avatar(
                          url: cita.barbero.fotoUrl,
                          name:
                              '${cita.barbero.nombre} ${cita.barbero.apellido}',
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${cita.barbero.nombre} ${cita.barbero.apellido}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800, fontVariations: const [FontVariation('wght', 700.0)],
                                ),
                          ),
                        ),
                        _EstadoBadge(
                          estado: cita.estado,
                          color: cita.estadoColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${cita.servicio.nombre} · ${_currency(cita.precioFinal)}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$date · ${_hora(cita.horaInicio)} - ${_hora(cita.horaFin)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (cita.esCancelable && onCancelar != null) ...[
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: onCancelar,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          minimumSize: const Size(110, 44),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  const _EstadoBadge({required this.estado, required this.color});

  final String estado;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        estado,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700, fontVariations: const [FontVariation('wght', 700.0)],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.name});

  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();

    if (url == null || url!.isEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        child: Text(
          initials.isEmpty ? 'B' : initials,
          style: const TextStyle(color: AppColors.primary),
        ),
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorWidget: (context, value, error) => CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Text(
            initials.isEmpty ? 'B' : initials,
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

String _currency(double value) => NumberFormat.currency(
  locale: 'es_CO',
  symbol: r'$',
  decimalDigits: 0,
).format(value);

String _hora(String value) => value.length >= 5 ? value.substring(0, 5) : value;
