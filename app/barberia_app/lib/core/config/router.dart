import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/registro_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/barberos/presentation/screens/seleccion_barbero_screen.dart';
import '../../features/citas/presentation/screens/confirmacion_screen.dart';
import '../../features/citas/presentation/screens/calificar_cita_screen.dart';
import '../../features/citas/presentation/screens/cita_exitosa_screen.dart';
import '../../features/citas/presentation/screens/detalle_cita_screen.dart';
import '../../features/citas/presentation/screens/mis_citas_screen.dart';
import '../../features/citas/domain/models/cita_model.dart';
import '../../features/admin/presentation/screens/admin_screen.dart';
import '../../features/dev/componentes_screen.dart';
import '../../features/horarios/presentation/screens/seleccion_horario_screen.dart';
import '../../features/servicios/presentation/screens/home_screen.dart';
import '../../features/servicios/presentation/screens/seleccion_servicio_screen.dart';
import '../../shared/widgets/bsm/bsm.dart';
import '../auth/jwt_utils.dart';
import '../storage/secure_storage.dart';

const _sessionExpiryWarningThreshold = Duration(minutes: 30);

final routerProvider = Provider<GoRouter>((ref) {
  final storage = ref.watch(secureStorageProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      // Galería de componentes: solo en modo debug y sin sesión.
      if (kDebugMode && state.matchedLocation == '/_componentes') return null;

      final token = await storage.getToken();
      final isLoggedIn = token != null && token.isNotEmpty;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/registro';
      final isAdminRoute = state.matchedLocation.startsWith('/admin');

      if (state.matchedLocation == '/') {
        return isLoggedIn ? '/dashboard' : '/login';
      }

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/dashboard';
      }

      if (isLoggedIn && isAdminRoute) {
        final role = JwtUtils.tryGetRole(token);
        if (!JwtUtils.isAdminRole(role)) {
          return '/dashboard';
        }
      }

      if (state.matchedLocation == '/home') {
        return '/dashboard';
      }

      if (state.matchedLocation == '/mis-citas') {
        return '/appointments';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/registro',
        builder: (context, state) => const RegistroScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => _AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/appointments',
            builder: (context, state) => const MisCitasScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    DetalleCitaScreen(citaId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'calificar',
                    builder: (context, state) =>
                        CalificarCitaScreen(citaId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/reservar',
            redirect: (context, state) => '/reservar/servicio',
          ),
          GoRoute(
            path: '/reservar/servicio',
            builder: (context, state) => const SeleccionServicioScreen(),
          ),
          GoRoute(
            path: '/reservar/barbero',
            builder: (context, state) => const SeleccionBarberoScreen(),
          ),
          GoRoute(
            path: '/reservar/horario',
            builder: (context, state) => const SeleccionHorarioScreen(),
          ),
          GoRoute(
            path: '/reservar/confirm',
            builder: (context, state) => const ConfirmacionScreen(),
          ),
          GoRoute(
            path: '/reservar/exito',
            builder: (context, state) {
              final cita = state.extra as CitaModel;
              return CitaExitosaScreen(cita: cita);
            },
          ),
        ],
      ),
      GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
      if (kDebugMode)
        GoRoute(path: '/_componentes', builder: (context, state) => const ComponentesScreen()),
    ],
  );
});

class _AppShell extends ConsumerStatefulWidget {
  const _AppShell({required this.child});

  final Widget child;

  // Destinos de la barra inferior: (ruta, prefijo que la marca activa, ítem).
  // Perfil se agrega cuando exista su pantalla (design/docs/02-patrones.md).
  static const _tabs = [
    ('/dashboard', '/dashboard', BsmNavItem(icon: LucideIcons.house, label: 'Inicio')),
    ('/reservar/servicio', '/reservar', BsmNavItem(icon: LucideIcons.calendarPlus, label: 'Reservar')),
    ('/appointments', '/appointments', BsmNavItem(icon: LucideIcons.calendarDays, label: 'Mis citas')),
  ];

  /// La barra se ve solo en las pantallas raíz; se oculta en los pasos 2–4,
  /// en la confirmación y en los detalles, para mantener el foco.
  static const _conBarra = {'/dashboard', '/reservar/servicio', '/appointments'};

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  Timer? _sessionCheckTimer;
  bool _warningShown = false;

  @override
  void initState() {
    super.initState();
    _checkSessionExpiry();
    _sessionCheckTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _checkSessionExpiry(),
    );
  }

  @override
  void dispose() {
    _sessionCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkSessionExpiry() async {
    if (_warningShown || !mounted) {
      return;
    }

    final storage = ref.read(secureStorageProvider);
    final token = await storage.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    final expiry = JwtUtils.tryGetExpiry(token);
    if (expiry == null) {
      return;
    }

    final remaining = expiry.difference(DateTime.now());
    if (remaining <= Duration.zero ||
        remaining > _sessionExpiryWarningThreshold) {
      return;
    }

    _warningShown = true;
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: const Text(
          'Tu sesión expirará pronto. Si estás en medio de una reserva, '
          'complétala pronto o inicia sesión de nuevo para no perderla.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _AppShell._tabs.indexWhere(
      (item) => location.startsWith(item.$2),
    );

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _AppShell._conBarra.contains(location)
          ? BsmBottomNav(
              items: [for (final tab in _AppShell._tabs) tab.$3],
              selectedIndex: currentIndex < 0 ? 0 : currentIndex,
              onSelected: (index) => context.go(_AppShell._tabs[index].$1),
            )
          : null,
    );
  }
}
