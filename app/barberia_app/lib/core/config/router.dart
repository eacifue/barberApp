import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/registro_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/barberos/presentation/screens/seleccion_barbero_screen.dart';
import '../../features/barberias/presentation/providers/selected_barbershop_provider.dart';
import '../../features/barberias/presentation/screens/select_barbershop_screen.dart';
import '../../features/citas/presentation/screens/confirmacion_screen.dart';
import '../../features/citas/presentation/screens/cita_exitosa_screen.dart';
import '../../features/citas/presentation/screens/detalle_cita_screen.dart';
import '../../features/citas/presentation/screens/mis_citas_screen.dart';
import '../../features/citas/domain/models/cita_model.dart';
import '../../features/admin/presentation/screens/admin_screen.dart';
import '../../features/horarios/presentation/screens/seleccion_horario_screen.dart';
import '../../features/servicios/presentation/screens/home_screen.dart';
import '../../features/servicios/presentation/screens/seleccion_servicio_screen.dart';
import '../auth/jwt_utils.dart';
import '../storage/secure_storage.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final selectedBarbershopState = ref.watch(selectedBarbershopProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final token = await storage.getToken();
      final isLoggedIn = token != null && token.isNotEmpty;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/registro';
      final isSelectBarbershopRoute =
          state.matchedLocation == '/select-barbershop';
      final isDashboardRoute = state.matchedLocation == '/dashboard';
      final isAppointmentsRoute = state.matchedLocation.startsWith(
        '/appointments',
      );
      final isServiciosRoute =
          state.matchedLocation.startsWith('/reservar') ||
          state.matchedLocation == '/home' ||
          state.matchedLocation.startsWith('/mis-citas');
      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      final needsBarbershopContext =
          isDashboardRoute || isAppointmentsRoute || isServiciosRoute;

      if (!selectedBarbershopState.ready && !isAuthRoute) {
        return '/';
      }

      if (state.matchedLocation == '/') {
        if (!isLoggedIn) {
          return '/login';
        }
        if (!selectedBarbershopState.hasSelection) {
          return '/select-barbershop';
        }
        return '/dashboard';
      }

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn &&
          !selectedBarbershopState.hasSelection &&
          !isSelectBarbershopRoute) {
        return '/select-barbershop';
      }

      if (isLoggedIn &&
          selectedBarbershopState.hasSelection &&
          isSelectBarbershopRoute) {
        return '/dashboard';
      }

      if (isLoggedIn &&
          selectedBarbershopState.hasSelection &&
          needsBarbershopContext) {
        return null;
      }

      if (isLoggedIn && isAdminRoute) {
        final role = JwtUtils.tryGetRole(token);
        if (!JwtUtils.isAdminRole(role)) {
          return '/dashboard';
        }
      }

      if (isLoggedIn &&
          (state.matchedLocation == '/login' ||
              state.matchedLocation == '/registro')) {
        return selectedBarbershopState.hasSelection
            ? '/dashboard'
            : '/select-barbershop';
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
      GoRoute(
        path: '/select-barbershop',
        builder: (context, state) => const SelectBarbershopScreen(),
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
    ],
  );
});

class _AppShell extends StatelessWidget {
  const _AppShell({required this.child});

  final Widget child;

  static const _tabs = [
    ('/dashboard', Icons.dashboard_rounded, 'Dashboard'),
    ('/reservar/servicio', Icons.event_available_rounded, 'Reservar'),
    ('/appointments', Icons.content_cut_rounded, 'Mis citas'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _tabs.indexWhere(
      (item) => location.startsWith(item.$1),
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex < 0 ? 0 : currentIndex,
        onDestinationSelected: (index) => context.go(_tabs[index].$1),
        height: 72,
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(icon: Icon(tab.$2), label: tab.$3),
        ],
      ),
    );
  }
}
