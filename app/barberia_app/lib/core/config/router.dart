import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/recuperar_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/registro_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/barberias/presentation/screens/elegir_barberia_screen.dart';
import '../../features/barberos/presentation/screens/seleccion_barbero_screen.dart';
import '../../features/citas/presentation/screens/confirmacion_screen.dart';
import '../../features/citas/presentation/screens/calificar_cita_screen.dart';
import '../../features/citas/presentation/screens/cita_exitosa_screen.dart';
import '../../features/citas/presentation/screens/detalle_cita_screen.dart';
import '../../features/citas/presentation/screens/mis_citas_screen.dart';
import '../../features/citas/domain/models/cita_model.dart';
import '../../features/admin/presentation/screens/admin_screen.dart';
import '../../features/citas/presentation/screens/agenda_barbero_screen.dart';
import '../../features/dev/componentes_screen.dart';
import '../../features/horarios/presentation/screens/seleccion_horario_screen.dart';
import '../../features/servicios/presentation/screens/home_screen.dart';
import '../../features/servicios/presentation/screens/seleccion_servicio_screen.dart';
import '../../shared/widgets/bsm/bsm.dart';
import '../auth/jwt_utils.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
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
      final eligiendo = state.matchedLocation == '/elegir-barberia';
      final isAuthRoute =
          eligiendo ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/registro' ||
          state.matchedLocation == '/recuperar';
      // Splash y onboarding se ven con o sin sesión; el splash decide el destino.
      final isPublic = state.matchedLocation == '/' || state.matchedLocation == '/bienvenida';
      if (isPublic) return null;
      final isAdminRoute = state.matchedLocation.startsWith('/admin');

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // Sin barbería elegida no hay dónde entrar ni registrarse: primero se elige.
      if (!isLoggedIn && !eligiendo) {
        final barberiaId = await storage.getBarberiaId();
        if (barberiaId == null || barberiaId.isEmpty) return '/elegir-barberia';
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

      // El barbero usa la app para ver su agenda; reservar es del cliente.
      if (isLoggedIn) {
        final esBarbero = JwtUtils.isBarberoRole(JwtUtils.tryGetRole(token));
        final enAgenda = state.matchedLocation == '/agenda';
        if (esBarbero && !enAgenda) return '/agenda';
        if (!esBarbero && enAgenda) return '/dashboard';
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
      GoRoute(path: '/bienvenida', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/elegir-barberia', builder: (context, state) => const ElegirBarberiaScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/recuperar',
        builder: (context, state) => RecuperarScreen(correoInicial: state.extra is String ? state.extra! as String : ''),
      ),
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
      GoRoute(path: '/agenda', builder: (context, state) => const AgendaBarberoScreen()),
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

    final p = context.palette;
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: p.warningBg,
        leading: Icon(LucideIcons.triangleAlert, color: p.warning),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tu sesión expirará pronto', style: AppTextStyles.label.copyWith(color: p.ink)),
            Text(
              'Si estás reservando, termina ahora o vuelve a iniciar sesión para no perder tu horario.',
              style: AppTextStyles.body.copyWith(color: p.ink),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            style: TextButton.styleFrom(foregroundColor: p.warning),
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
