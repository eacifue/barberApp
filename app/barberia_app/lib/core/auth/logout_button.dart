import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/barberias/presentation/providers/selected_barbershop_provider.dart';
import 'auth_role_provider.dart';

/// Shared "cerrar sesión" AppBar action: confirms before signing out, then
/// clears the session and the selected barbershop consistently everywhere
/// it's used, instead of each screen re-implementing its own copy.
class LogoutButton extends ConsumerStatefulWidget {
  const LogoutButton({super.key, this.disabled = false});

  final bool disabled;

  @override
  ConsumerState<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends ConsumerState<LogoutButton> {
  bool _loggingOut = false;

  Future<bool> _confirmLogout() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Seguro que deseas cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Cerrar sesión',
      onPressed: widget.disabled || _loggingOut
          ? null
          : () async {
              final confirmado = await _confirmLogout();
              if (!confirmado || !context.mounted) {
                return;
              }

              setState(() => _loggingOut = true);
              try {
                await ref.read(authRepositoryProvider).logout();
                await ref
                    .read(selectedBarbershopProvider.notifier)
                    .clearSelection();
                ref.invalidate(authRoleProvider);
                if (!context.mounted) {
                  return;
                }
                context.go('/login');
              } finally {
                if (mounted) {
                  setState(() => _loggingOut = false);
                }
              }
            },
      icon: _loggingOut
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.logout_rounded),
    );
  }
}
