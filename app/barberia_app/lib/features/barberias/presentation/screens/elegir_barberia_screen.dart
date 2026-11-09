import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../domain/barberia_busqueda.dart';
import '../../domain/barbershop_model.dart';
import '../providers/barberia_elegida_provider.dart';
import '../providers/barbershops_provider.dart';

/// Antes de entrar se elige la barbería: la cuenta, las citas y el catálogo son
/// de cada una. Se ve sin sesión, al abrir la app por primera vez o tras
/// «Cambiar de barbería».
class ElegirBarberiaScreen extends ConsumerStatefulWidget {
  const ElegirBarberiaScreen({super.key});

  @override
  ConsumerState<ElegirBarberiaScreen> createState() => _ElegirBarberiaScreenState();
}

class _ElegirBarberiaScreenState extends ConsumerState<ElegirBarberiaScreen> {
  final _busqueda = TextEditingController();
  String _consulta = '';
  String? _eligiendo;

  @override
  void initState() {
    super.initState();
    // Al llegar aquí la lista puede estar vieja (p. ej. desactivaron la barbería guardada).
    Future.microtask(() {
      if (mounted) ref.invalidate(barbershopsProvider);
    });
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _elegir(BarbershopModel barberia) async {
    setState(() => _eligiendo = barberia.id);
    final router = GoRouter.of(context);
    await ref.read(barberiaElegidaProvider.notifier).elegir(barberia);
    router.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final async = ref.watch(barbershopsProvider);
    final todas = async.valueOrNull ?? const <BarbershopModel>[];
    final visibles = filtrarBarberias(todas, _consulta);

    final List<Widget> cuerpo;
    if (async.hasError && !async.hasValue) {
      cuerpo = [
        BsmEmptyState(
          isError: true,
          title: 'No pudimos cargar las barberías',
          body: 'Revisa tu conexión e inténtalo de nuevo.',
          actionLabel: 'Reintentar',
          actionIcon: LucideIcons.refreshCw,
          onAction: () => ref.invalidate(barbershopsProvider),
        ),
      ];
    } else if (!async.hasValue) {
      cuerpo = const [BsmSkeleton(variant: BsmSkeletonVariant.card, count: 3)];
    } else if (todas.isEmpty) {
      cuerpo = const [
        BsmEmptyState(icon: LucideIcons.store, title: 'Aún no hay barberías disponibles', body: 'Vuelve más tarde; estamos preparando las reservas.'),
      ];
    } else {
      cuerpo = [
        BsmTextField(
          controller: _busqueda,
          label: 'Buscar',
          icon: LucideIcons.search,
          placeholder: 'Nombre, ciudad o dirección',
          textInputAction: TextInputAction.search,
          onChanged: (v) => setState(() => _consulta = v),
        ),
        const SizedBox(height: AppSpace.s5),
        if (visibles.isEmpty)
          BsmEmptyState(
            icon: LucideIcons.searchX,
            title: 'No encontramos «${_consulta.trim()}»',
            body: 'Prueba con otro nombre o con la ciudad.',
          )
        else ...[
          Semantics(
            liveRegion: true,
            child: Text(
              visibles.length == 1 ? '1 barbería' : '${visibles.length} barberías',
              style: AppTextStyles.overline.copyWith(color: p.inkMuted),
            ),
          ),
          const SizedBox(height: AppSpace.s3),
          for (final b in visibles) ...[
            _BarberiaOpcion(barberia: b, cargando: _eligiendo == b.id, onTap: _eligiendo == null ? () => _elegir(b) : null),
            const SizedBox(height: AppSpace.s3),
          ],
        ],
      ];
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(barbershopsProvider.future),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpace.s5, AppSpace.s10, AppSpace.s5, AppSpace.s6),
                children: [
                  const Align(alignment: Alignment.centerLeft, child: BsmLogo(horizontal: true, height: 48)),
                  const SizedBox(height: AppSpace.s10),
                  Semantics(header: true, child: Text('Elige tu barbería', style: AppTextStyles.display.copyWith(color: p.ink))),
                  const SizedBox(height: AppSpace.s2),
                  Text(
                    'Tu cuenta y tus citas son de la barbería que elijas. Puedes cambiarla después.',
                    style: AppTextStyles.bodyLg.copyWith(color: p.inkMuted),
                  ),
                  const SizedBox(height: AppSpace.s8),
                  ...cuerpo,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarberiaOpcion extends StatelessWidget {
  const _BarberiaOpcion({required this.barberia, required this.onTap, this.cargando = false});

  final BarbershopModel barberia;
  final VoidCallback? onTap;
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: '${barberia.nombre}, ${barberia.direccionCompleta}',
      excludeSemantics: true,
      child: BsmCardFrame(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: p.brassSoft, borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Icon(LucideIcons.store, color: p.brassInk),
            ),
            const SizedBox(width: AppSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(barberia.nombre, style: AppTextStyles.titleSm.copyWith(color: p.ink)),
                  const SizedBox(height: 2),
                  Text(barberia.direccionCompleta, style: AppTextStyles.body.copyWith(color: p.inkMuted)),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.s2),
            cargando
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator.adaptive(strokeWidth: 2))
                : Icon(LucideIcons.chevronRight, color: p.inkMuted),
          ],
        ),
      ),
    );
  }
}
