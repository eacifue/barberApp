import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/destino_inicial.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../../barberias/presentation/providers/barberia_elegida_provider.dart';

/// Splash: fondo `carbon`, emblema sobre oscuro, sin texto; máximo ~1 s.
/// Decide el destino: onboarding (primera apertura), Inicio o login.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decidir();
  }

  Future<void> _decidir() async {
    final storage = ref.read(secureStorageProvider);
    final results = await Future.wait<Object?>([
      storage.onboardingVisto(),
      storage.getToken(),
      storage.getBarberiaId(),
      Future<void>.delayed(const Duration(milliseconds: 600)),
    ]);
    if (!mounted) return;
    final router = GoRouter.of(context);
    final destino = await resolverDestinoInicial(
      storage,
      onboardingVisto: results[0] as bool,
      token: results[1] as String?,
      barberiaId: results[2] as String?,
    );
    ref.invalidate(barberiaElegidaProvider);
    router.go(destino);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: p.carbon,
        body: const Center(child: BsmLogo(height: 128, onDark: true)),
      ),
    );
  }
}
