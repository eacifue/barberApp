import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/auth/auth_role_provider.dart';
import '../../../../core/errors/error_message.dart';
import '../../../../core/services/permiso_notificaciones.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/bsm/bsm.dart';
import '../../../barberias/presentation/widgets/barberia_elegida_linea.dart';
import '../../data/auth_repository.dart';
import 'auth_validators.dart';

/// Crea tu cuenta (design/pantallas/app-movil/Registro y Registro-errores):
/// validación por campo al salir y al enviar. Al crear la cuenta se pasa al
/// onboarding si aún no se ha visto.
class RegistroScreen extends ConsumerStatefulWidget {
  const RegistroScreen({super.key});

  @override
  ConsumerState<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends ConsumerState<RegistroScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _celular = TextEditingController();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    for (final c in [_nombre, _apellido, _celular, _correo, _clave]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _crear() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _cargando = true);
    final router = GoRouter.of(context);
    try {
      await ref.read(authRepositoryProvider).registro(
            nombre: _nombre.text.trim(),
            apellido: _apellido.text.trim(),
            telefono: _celular.text.replaceAll(RegExp(r'\D'), ''),
            correo: _correo.text.trim(),
            password: _clave.text,
          );
      await ref.read(permisoNotificacionesProvider).sincronizarSiAutorizado();
      ref.invalidate(authRoleProvider);
      final visto = await ref.read(secureStorageProvider).onboardingVisto();
      router.go(visto ? '/dashboard' : '/bienvenida');
    } catch (e) {
      if (mounted) showBsmToast(context, mensajeDeError(e, 'No pudimos crear tu cuenta. Inténtalo de nuevo.'), tone: BsmToastTone.danger);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const gap = SizedBox(height: AppSpace.s4);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpace.s4, AppSpace.s2, AppSpace.s4, AppSpace.s6),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(tooltip: 'Volver a iniciar sesión', onPressed: () => context.go('/login'), icon: const Icon(LucideIcons.arrowLeft, size: 24)),
                ),
                const SizedBox(height: AppSpace.s2),
                Semantics(header: true, child: Text('Crea tu cuenta', style: AppTextStyles.display.copyWith(color: p.ink))),
                const SizedBox(height: AppSpace.s2),
                Text('Solo lo necesario para tus reservas.', style: AppTextStyles.bodyLg.copyWith(color: p.inkMuted)),
                const SizedBox(height: AppSpace.s5),
                BarberiaElegidaLinea(disabled: _cargando),
                const SizedBox(height: AppSpace.s6),
                AutofillGroup(
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: BsmTextField(
                                controller: _nombre,
                                label: 'Nombre',
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.givenName],
                                validator: (v) => AuthValidators.requerido(v, 'Escribe tu nombre.'),
                              ),
                            ),
                            const SizedBox(width: AppSpace.s3),
                            Expanded(
                              child: BsmTextField(
                                controller: _apellido,
                                label: 'Apellido',
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.familyName],
                                validator: (v) => AuthValidators.requerido(v, 'Escribe tu apellido.'),
                              ),
                            ),
                          ],
                        ),
                        gap,
                        BsmTextField(
                          controller: _celular,
                          label: 'Celular',
                          icon: LucideIcons.phone,
                          placeholder: '300 123 4567',
                          hint: 'Solo para avisos de tus citas.',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d\s+]'))],
                          validator: AuthValidators.celular,
                        ),
                        gap,
                        BsmTextField(
                          controller: _correo,
                          label: 'Correo electrónico',
                          icon: LucideIcons.mail,
                          placeholder: 'nombre@correo.co',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          validator: AuthValidators.correo,
                        ),
                        gap,
                        BsmTextField(
                          controller: _clave,
                          label: 'Contraseña',
                          revealable: true,
                          hint: 'Mínimo 6 caracteres.',
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          onSubmitted: (_) => _crear(),
                          validator: AuthValidators.clave,
                        ),
                        const SizedBox(height: AppSpace.s6),
                        BsmButton(label: _cargando ? 'Creando cuenta…' : 'Crear cuenta', size: BsmButtonSize.lg, block: true, loading: _cargando, onPressed: _crear),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.s6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿Ya tienes cuenta?', style: AppTextStyles.body.copyWith(color: p.inkMuted)),
                    TextButton(onPressed: _cargando ? null : () => context.go('/login'), child: const Text('Inicia sesión')),
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
