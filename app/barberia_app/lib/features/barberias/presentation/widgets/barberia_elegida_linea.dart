import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/auth/auth_role_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../../auth/data/auth_repository.dart';
import '../providers/barberia_elegida_provider.dart';
import '../providers/barbershops_provider.dart';

/// En login y registro: a qué barbería se entra, con «Cambiar» (aún no hay sesión).
class BarberiaElegidaLinea extends ConsumerWidget {
  const BarberiaElegidaLinea({super.key, this.disabled = false});

  final bool disabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final elegida = ref.watch(barberiaElegidaProvider).valueOrNull;
    final nombre = (elegida?.nombre.isNotEmpty ?? false) ? elegida!.nombre : ref.watch(myBarbershopProvider).valueOrNull?.nombre;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpace.s3, AppSpace.s1, AppSpace.s1, AppSpace.s1),
      decoration: BoxDecoration(color: p.surfaceSunken, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Row(
        children: [
          Icon(LucideIcons.store, size: 18, color: p.brassInk),
          const SizedBox(width: AppSpace.s2),
          Expanded(
            child: Text(
              nombre == null || nombre.isEmpty ? 'Tu barbería' : nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(color: p.ink),
            ),
          ),
          TextButton(
            onPressed: disabled
                ? null
                : () async {
                    final router = GoRouter.of(context);
                    await ref.read(barberiaElegidaProvider.notifier).olvidar();
                    router.go('/elegir-barberia');
                  },
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }
}

/// «Cambiar de barbería» con sesión abierta: la cuenta es de una sola barbería,
/// así que se cierra la sesión y se elige otra.
Future<void> cambiarDeBarberia(BuildContext context, WidgetRef ref) async {
  final confirmado = await showBsmConfirm(
    context,
    title: '¿Cambiar de barbería?',
    body: 'Vamos a cerrar tu sesión. En la otra barbería entras con la cuenta que tengas allí, o creas una.',
    confirmLabel: 'Cambiar de barbería',
    tone: BsmConfirmTone.info,
    icon: LucideIcons.store,
  );
  if (!confirmado || !context.mounted) return;
  final router = GoRouter.of(context);
  await ref.read(authRepositoryProvider).logout();
  await ref.read(barberiaElegidaProvider.notifier).olvidar();
  ref.invalidate(authRoleProvider);
  router.go('/elegir-barberia');
}
