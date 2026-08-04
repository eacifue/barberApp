import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../../core/auth/auth_role_provider.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../data/auth_repository.dart';

class RegistroScreen extends ConsumerStatefulWidget {
  const RegistroScreen({super.key});

  @override
  ConsumerState<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends ConsumerState<RegistroScreen> {
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = ref.watch(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Crea tu cuenta',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  children: [
                    AppInput(
                      controller: _nombreController,
                      label: 'Nombre',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      controller: _apellidoController,
                      label: 'Apellido',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      controller: _correoController,
                      label: 'Correo',
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      controller: _telefonoController,
                      label: 'Teléfono',
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      controller: _passwordController,
                      label: 'Contraseña',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Registrarme',
                isLoading: _loading,
                onPressed: () async {
                  final nombre = _nombreController.text.trim();
                  final apellido = _apellidoController.text.trim();
                  final correo = _correoController.text.trim();
                  final telefono = _telefonoController.text.trim();
                  final password = _passwordController.text;

                  if (nombre.isEmpty ||
                      apellido.isEmpty ||
                      correo.isEmpty ||
                      telefono.isEmpty ||
                      password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Completa todos los campos.'),
                      ),
                    );
                    return;
                  }

                  if (!correo.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingresa un correo válido.'),
                      ),
                    );
                    return;
                  }

                  if (password.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La contraseña debe tener mínimo 6 caracteres.',
                        ),
                      ),
                    );
                    return;
                  }

                  setState(() => _loading = true);
                  try {
                    try {
                      await authRepository.registro(
                        nombre: nombre,
                        apellido: apellido,
                        telefono: telefono,
                        correo: correo,
                        password: password,
                      );
                    } on AppException catch (ex) {
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(ex.message)));
                      return;
                    } catch (_) {
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No se pudo crear la cuenta en este momento.',
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      await FirebaseMessaging.instance.requestPermission(
                        alert: true,
                        badge: true,
                        sound: true,
                      );

                      final token = await FirebaseMessaging.instance.getToken();
                      if (token != null && token.isNotEmpty) {
                        await authRepository.actualizarTokenFCM(token);
                      }
                    } catch (_) {
                      // El registro ya fue exitoso; la notificación push es best-effort.
                    }

                    if (!context.mounted) {
                      return;
                    }

                    ref.invalidate(authRoleProvider);
                    context.go('/dashboard');
                  } finally {
                    if (mounted) {
                      setState(() => _loading = false);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
