import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/barbero_model.dart';

class BarberoCard extends StatelessWidget {
  const BarberoCard({super.key, required this.barbero, required this.onTap});

  final BarberoModel barbero;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAvailable = barbero.disponible;

    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isAvailable ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.textMuted.withValues(alpha: 0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BarberoAvatar(barbero: barbero),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            barbero.nombreCompleto,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const _RatingStars(),
                              const SizedBox(width: 6),
                              Text(
                                barbero.ratingText,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99),
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                            child: Text(
                              '${barbero.aniosExperiencia} años de experiencia',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 32,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: barbero.especialidades.take(3).length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final especialidad = barbero.especialidades
                                    .take(3)
                                    .elementAt(index);
                                return _EspecialidadChip(label: especialidad);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isAvailable
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (!isAvailable)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.46),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No disponible hoy',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BarberoAvatar extends StatelessWidget {
  const _BarberoAvatar({required this.barbero});

  final BarberoModel barbero;

  @override
  Widget build(BuildContext context) {
    final foto = barbero.fotoUrl;

    if (foto != null && foto.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: foto,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              _AvatarInitials(name: barbero.nombreCompleto),
          errorWidget: (context, url, error) =>
              _AvatarInitials(name: barbero.nombreCompleto),
        ),
      );
    }

    return _AvatarInitials(name: barbero.nombreCompleto);
  }
}

class _AvatarInitials extends StatelessWidget {
  const _AvatarInitials({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final words = name.split(' ').where((word) => word.isNotEmpty).toList();
    final initials = words.take(2).map((word) => word[0].toUpperCase()).join();

    return Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.16),
      ),
      child: Text(
        initials.isEmpty ? 'B' : initials,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
        (index) => const Padding(
          padding: EdgeInsets.only(right: 2),
          child: Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
        ),
      ),
    );
  }
}

class _EspecialidadChip extends StatelessWidget {
  const _EspecialidadChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: AppColors.primary.withValues(alpha: 0.1),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class BarberoCardShimmer extends StatelessWidget {
  const BarberoCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.background,
      highlightColor: Colors.white,
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
