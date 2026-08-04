import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/servicio_model.dart';

class ServicioCard extends StatelessWidget {
  const ServicioCard({
    super.key,
    required this.servicio,
    required this.onTap,
    this.seleccionado = false,
  });

  final ServicioModel servicio;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceOf(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seleccionado
                  ? AppColors.primary.withValues(alpha: 0.65)
                  : AppColors.textMutedOf(context).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 4,
                height: 112,
                decoration: BoxDecoration(
                  color: seleccionado ? AppColors.primary : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _ServicioImage(servicio: servicio),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              servicio.nombre,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              servicio.descripcion,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 16,
                                  color: AppColors.textMutedOf(context),
                                ),
                                const SizedBox(width: 6),
                                Text(servicio.duracionFormateada),
                                const Spacer(),
                                Text(
                                  servicio.precioFormateado,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: AppColors.secondaryOf(context),
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServicioImage extends StatelessWidget {
  const _ServicioImage({required this.servicio});

  final ServicioModel servicio;

  @override
  Widget build(BuildContext context) {
    final imageUrl = servicio.fotoUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return _TipoIcon(tipo: servicio.tipo);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 72,
        height: 72,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: AppColors.surfaceOf(context),
            highlightColor: AppColors.primary,
            child: Container(color: AppColors.surfaceOf(context)),
          ),
          errorWidget: (context, url, error) => _TipoIcon(tipo: servicio.tipo),
        ),
      ),
    );
  }
}

class _TipoIcon extends StatelessWidget {
  const _TipoIcon({required this.tipo});

  final String tipo;

  @override
  Widget build(BuildContext context) {
    final lower = tipo.toLowerCase();
    IconData icon = Icons.content_cut_rounded;
    if (lower.contains('barba')) {
      icon = Icons.face_retouching_natural_rounded;
    } else if (lower.contains('combo')) {
      icon = Icons.auto_awesome_mosaic_rounded;
    } else if (lower.contains('tinte')) {
      icon = Icons.palette_rounded;
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.primary.withValues(alpha: 0.08),
      ),
      child: Icon(icon, color: AppColors.primary, size: 24),
    );
  }
}

class ServicioCardShimmer extends StatelessWidget {
  const ServicioCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundOf(context),
      highlightColor: AppColors.shimmerHighlightOf(context),
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
