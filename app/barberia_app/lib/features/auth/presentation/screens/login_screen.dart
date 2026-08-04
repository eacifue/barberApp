import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_role_provider.dart';
import '../../data/auth_repository.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_input.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _loading = false;
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = ref.watch(authRepositoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Iniciar sesión',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ingresa para gestionar tus reservas y horarios.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppCard(
                    child: Column(
                      children: [
                        AppInput(
                          controller: _correoController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          label: 'Correo',
                          hint: 'correo@ejemplo.com',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        AppInput(
                          controller: _passwordController,
                          obscureText: true,
                          label: 'Contraseña',
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Iniciar sesión',
                    isLoading: _loading,
                    onPressed: () async {
                      final correo = _correoController.text.trim();
                      final password = _passwordController.text;

                      if (correo.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ingresa correo y contraseña.'),
                          ),
                        );
                        return;
                      }

                      setState(() => _loading = true);
                      try {
                        try {
                          await authRepository.login(
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
                                'No se pudo iniciar sesión en este momento.',
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

                          final token = await FirebaseMessaging.instance
                              .getToken();
                          if (token != null && token.isNotEmpty) {
                            await authRepository.actualizarTokenFCM(token);
                          }
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Inicio de sesión exitoso. No se pudo actualizar el token FCM en este momento.',
                                ),
                              ),
                            );
                          }
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
                  TextButton(
                    onPressed: () => context.go('/registro'),
                    child: const Text('Crear cuenta'),
                  ),
                  TextButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('¿Olvidaste tu contraseña?'),
                        content: const Text(
                          'La recuperación de contraseña dentro de la app '
                          'todavía no está disponible. Comunícate con tu '
                          'barbería para que te ayuden a restablecerla.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Entendido'),
                          ),
                        ],
                      ),
                    ),
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
