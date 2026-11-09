import 'package:barberia_app/core/storage/secure_storage.dart';
import 'package:barberia_app/core/theme/app_theme.dart';
import 'package:barberia_app/features/barberias/domain/barbershop_model.dart';
import 'package:barberia_app/features/barberias/presentation/providers/barbershops_provider.dart';
import 'package:barberia_app/features/barberias/presentation/screens/elegir_barberia_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

BarbershopModel _barberia(String id, String nombre, String ciudad) =>
    BarbershopModel.fromJson({'id': id, 'nombre': nombre, 'ciudad': ciudad, 'direccion': 'Calle $id'});

Future<void> _abrir(WidgetTester tester, Future<List<BarbershopModel>> Function() barberias) async {
  final router = GoRouter(
    initialLocation: '/elegir-barberia',
    routes: [
      GoRoute(path: '/elegir-barberia', builder: (_, _) => const ElegirBarberiaScreen()),
      GoRoute(path: '/login', builder: (_, _) => const Text('pantalla de login')),
    ],
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [barbershopsProvider.overrideWith((ref) => barberias())],
    child: MaterialApp.router(theme: buildTheme(Brightness.light), routerConfig: router),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('elegir una barbería la guarda y lleva al login', (tester) async {
    await _abrir(tester, () async => [_barberia('b-1', 'BarberShop El Poblado', 'Medellín'), _barberia('b-2', 'Barbería Laureles', 'Medellín')]);

    expect(find.text('2 barberías'), findsOneWidget);
    await tester.tap(find.text('Barbería Laureles'));
    await tester.pumpAndSettle();

    expect(find.text('pantalla de login'), findsOneWidget);
    const storage = SecureStorageService(FlutterSecureStorage());
    expect(await storage.getBarberiaId(), 'b-2');
    expect(await storage.getBarberiaNombre(), 'Barbería Laureles');
  });

  testWidgets('la búsqueda filtra y avisa cuando no hay coincidencias', (tester) async {
    await _abrir(tester, () async => [_barberia('b-1', 'BarberShop El Poblado', 'Medellín'), _barberia('b-3', 'Corte Fino', 'Bogotá')]);

    await tester.enterText(find.byType(TextField), 'bogota');
    await tester.pump();
    expect(find.text('Corte Fino'), findsOneWidget);
    expect(find.text('BarberShop El Poblado'), findsNothing);

    await tester.enterText(find.byType(TextField), 'cali');
    await tester.pump();
    expect(find.text('No encontramos «cali»'), findsOneWidget);
  });

  testWidgets('sin barberías activas lo dice, sin buscador', (tester) async {
    await _abrir(tester, () async => []);

    expect(find.text('Aún no hay barberías disponibles'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('si falla la carga ofrece reintentar', (tester) async {
    await _abrir(tester, () async => throw Exception('sin red'));

    expect(find.text('No pudimos cargar las barberías'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });
}
