import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../shared/widgets/bsm/bsm.dart';
import 'auth_role_provider.dart';

/// Shared "cerrar sesión" AppBar action: confirms before signing out, then
/// clears the session consistently everywhere it's used, instead of each
/// screen re-implementing its own copy.
class LogoutButton extends ConsumerStatefulWidget {
  const LogoutButton({super.key, this.disabled = false});

  final bool disabled;

  @override
  ConsumerState<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends ConsumerState<LogoutButton> {
  bool _loggingOut = false;

  Future<bool> _confirmLogout() => showBsmConfirm(
        context,
        title: '¿Cerrar sesión?',
        body: 'Tendrás que entrar de nuevo con tu correo y contraseña.',
        confirmLabel: 'Cerrar sesión',
        tone: BsmConfirmTone.info,
        icon: LucideIcons.logOut,
      );

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
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            )
          : const Icon(LucideIcons.logOut),
    );
  }
}
