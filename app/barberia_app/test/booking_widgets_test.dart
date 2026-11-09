import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barberia_app/core/theme/app_theme.dart';
import 'package:barberia_app/features/citas/presentation/widgets/booking_scaffold.dart';

void main() {
  test('fechaConHora combina la fecha de la cita con HH:mm[:ss]', () {
    final d = fechaConHora(DateTime(2026, 11, 12), '15:30:00');
    expect(d, DateTime(2026, 11, 12, 15, 30));
    expect(fechaConHora(DateTime(2026, 11, 12), '09:05'), DateTime(2026, 11, 12, 9, 5));
  });

  testWidgets('BookingScaffold muestra el paso, el título y la barra con el resumen', (tester) async {
    var continuar = 0;
    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(Brightness.light),
      home: BookingScaffold(
        step: 2,
        title: 'Elige tu barbero',
        onBack: () {},
        bottom: BookingBottomBar(title: 'Julián Restrepo', subtitle: r'Corte + barba · $50.000', label: 'Continuar', onPressed: () => continuar++),
        children: const [Text('contenido')],
      ),
    ));

    expect(find.text('Elige tu barbero'), findsOneWidget);
    expect(find.textContaining('Paso 2 de 4'), findsOneWidget);
    expect(find.text('Julián Restrepo'), findsOneWidget);
    await tester.tap(find.text('Continuar'));
    expect(continuar, 1);
  });

  testWidgets('BookingBottomBar sin selección deshabilita «Continuar»', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(Brightness.light),
      home: const Scaffold(bottomNavigationBar: BookingBottomBar(hint: 'Elige un horario para continuar', label: 'Continuar', onPressed: null)),
    ));
    expect(find.text('Elige un horario para continuar'), findsOneWidget);
    final boton = tester.widget<TextButton>(find.byType(TextButton));
    expect(boton.onPressed, isNull);
  });
}
