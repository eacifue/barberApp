import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:barberia_app/core/storage/secure_storage.dart';
import 'package:barberia_app/core/theme/app_theme.dart';
import 'package:barberia_app/features/auth/presentation/screens/splash_screen.dart';

class _StorageFalso implements SecureStorageService {
  _StorageFalso({required this.visto, this.token, this.barberiaId = 'b-1'});

  final bool visto;
  final String? token;
  final String? barberiaId;

  @override
  Future<String?> getBarberiaId() async => barberiaId;

  @override
  Future<String?> getBarberiaNombre() async => barberiaId == null ? null : 'Barbería Laureles';

  @override
  Future<bool> onboardingVisto() async => visto;

  @override
  Future<String?> getToken() async => token;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<GoRouter> _montar(WidgetTester tester, _StorageFalso storage) async {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      for (final ruta in ['/bienvenida', '/elegir-barberia', '/login', '/dashboard']) GoRoute(path: ruta, builder: (context, state) => Text(ruta)),
    ],
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [secureStorageProvider.overrideWithValue(storage)],
    child: MaterialApp.router(theme: buildTheme(Brightness.light), routerConfig: router),
  ));
  return router;
}

void main() {
  testWidgets('El splash muestra el emblema de la marca sobre carbón', (tester) async {
    await _montar(tester, _StorageFalso(visto: true));

    expect(find.bySemanticsLabel('BarberShop Medellín'), findsOneWidget);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFF1C1814));
    await tester.pumpAndSettle(const Duration(milliseconds: 700));
  });

  testWidgets('Primera apertura: el splash lleva al onboarding', (tester) async {
    await _montar(tester, _StorageFalso(visto: false));
    await tester.pumpAndSettle(const Duration(milliseconds: 700));
    expect(find.text('/bienvenida'), findsOneWidget);
  });

  testWidgets('Con sesión y onboarding visto: el splash lleva a Inicio', (tester) async {
    await _montar(tester, _StorageFalso(visto: true, token: 'jwt'));
    await tester.pumpAndSettle(const Duration(milliseconds: 700));
    expect(find.text('/dashboard'), findsOneWidget);
  });

  testWidgets('Sin barbería elegida: el splash lleva a elegir barbería', (tester) async {
    await _montar(tester, _StorageFalso(visto: true, barberiaId: null));
    await tester.pumpAndSettle(const Duration(milliseconds: 700));
    expect(find.text('/elegir-barberia'), findsOneWidget);
  });

  testWidgets('Sin sesión: el splash lleva a iniciar sesión', (tester) async {
    await _montar(tester, _StorageFalso(visto: true));
    await tester.pumpAndSettle(const Duration(milliseconds: 700));
    expect(find.text('/login'), findsOneWidget);
  });
}
