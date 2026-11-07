import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/secure_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bsm/bsm.dart';

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
      Future<void>.delayed(const Duration(milliseconds: 600)),
    ]);
    if (!mounted) return;
    final visto = results[0] as bool;
    final token = results[1] as String?;
    if (!visto) {
      context.go('/bienvenida');
    } else {
      context.go(token != null && token.isNotEmpty ? '/dashboard' : '/login');
    }
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
