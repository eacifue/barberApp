import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/auth/auth_role_provider.dart';
import '../../../../core/errors/error_message.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/permiso_notificaciones.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../data/auth_repository.dart';
import 'auth_validators.dart';

/// Inicia sesión (design/pantallas/app-movil/Login y Login-error): errores
/// debajo de cada campo; el aviso general solo cuando el servidor rechaza las
/// credenciales.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  bool _cargando = false;
  bool _rechazado = false;

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    setState(() => _rechazado = false);
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _cargando = true);
    final router = GoRouter.of(context);
    try {
      await ref.read(authRepositoryProvider).login(correo: _correo.text.trim(), password: _clave.text);
      // Sin diálogo del sistema aquí: el permiso se pide en el onboarding o tras la primera reserva.
      await ref.read(permisoNotificacionesProvider).sincronizarSiAutorizado();
      ref.invalidate(authRoleProvider);
      router.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      final ex = excepcionDe(e);
      // 401 (credenciales) o 400 (datos rechazados): aviso general; lo demás, toast.
      final credenciales = ex is UnauthorizedException || ex is ValidationException;
      if (credenciales) {
        setState(() => _rechazado = true);
      } else {
        showBsmToast(context, mensajeDeError(e, 'No pudimos iniciar sesión. Inténtalo de nuevo.'), tone: BsmToastTone.danger);
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpace.s5, AppSpace.s10, AppSpace.s5, AppSpace.s6),
              children: [
                const Align(alignment: Alignment.centerLeft, child: BsmLogo(horizontal: true, height: 48)),
                const SizedBox(height: AppSpace.s10),
                Semantics(header: true, child: Text('Inicia sesión', style: AppTextStyles.display.copyWith(color: p.ink))),
                const SizedBox(height: AppSpace.s2),
                Text('Ingresa para reservar y gestionar tus citas.', style: AppTextStyles.bodyLg.copyWith(color: p.inkMuted)),
                const SizedBox(height: AppSpace.s8),
                AutofillGroup(
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_rechazado) ...[
                          const BsmBanner(tone: BsmBannerTone.danger, title: 'Correo o contraseña incorrectos', body: 'Revísalos e inténtalo de nuevo.'),
                          const SizedBox(height: AppSpace.s4),
                        ],
                        BsmTextField(
                          controller: _correo,
                          label: 'Correo electrónico',
                          icon: LucideIcons.mail,
                          placeholder: 'nombre@correo.co',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: AuthValidators.correo,
                        ),
                        const SizedBox(height: AppSpace.s4),
                        BsmTextField(
                          controller: _clave,
                          label: 'Contraseña',
                          revealable: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onSubmitted: (_) => _entrar(),
                          validator: (v) => (v ?? '').isEmpty ? 'Escribe tu contraseña.' : null,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _cargando ? null : () => context.go('/recuperar', extra: _correo.text.trim()),
                            child: const Text('¿Olvidaste tu contraseña?'),
                          ),
                        ),
                        const SizedBox(height: AppSpace.s2),
                        BsmButton(label: _cargando ? 'Entrando…' : 'Entrar', size: BsmButtonSize.lg, block: true, loading: _cargando, onPressed: _entrar),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.s6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿No tienes cuenta?', style: AppTextStyles.body.copyWith(color: p.inkMuted)),
                    TextButton(onPressed: _cargando ? null : () => context.go('/registro'), child: const Text('Crear cuenta')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
