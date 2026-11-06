import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barberia_app/core/theme/app_theme.dart';
import 'package:barberia_app/shared/widgets/bsm/bsm.dart';

Widget _wrap(Widget child, {Brightness brightness = Brightness.light}) => MaterialApp(
      theme: buildTheme(brightness),
      home: Scaffold(body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: child)),
    );

void main() {
  group('AppointmentStatus', () {
    test('mapea los valores del backend', () {
      expect(AppointmentStatus.fromBackend('Pendiente'), AppointmentStatus.pendiente);
      expect(AppointmentStatus.fromBackend('EnProgreso'), AppointmentStatus.enProgreso);
      expect(AppointmentStatus.fromBackend('NoShow'), AppointmentStatus.noShow);
      expect(AppointmentStatus.fromBackend('desconocido'), AppointmentStatus.pendiente);
      expect(AppointmentStatus.noShow.label, 'No asistió');
      expect(AppointmentStatus.confirmada.isUpcoming, isTrue);
      expect(AppointmentStatus.completada.isUpcoming, isFalse);
    });
  });

  testWidgets('StatusBadge muestra ícono y palabra (no solo color)', (tester) async {
    await tester.pumpWidget(_wrap(const StatusBadge(AppointmentStatus.enProgreso)));
    expect(find.text('En progreso'), findsOneWidget);
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('BsmButton en carga ignora toques y conserva la etiqueta', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(BsmButton(label: 'Reservando…', loading: true, onPressed: () => taps++)));
    await tester.tap(find.text('Reservando…'));
    expect(taps, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ServiceCard formatea precio y duración en es-CO', (tester) async {
    await tester.pumpWidget(_wrap(const ServiceCard(name: 'Corte + barba', type: 'Combo', durationMinutes: 75, price: 50000, selected: true)));
    expect(find.text(r'$50.000'), findsOneWidget);
    expect(find.text('1 h 15 min'), findsOneWidget);
  });

  testWidgets('BsmRating sin reseñas muestra «Nuevo»', (tester) async {
    await tester.pumpWidget(_wrap(const BsmRating(value: null)));
    expect(find.text('Nuevo'), findsOneWidget);
  });

  testWidgets('SlotGrid: no disponibles no se pueden elegir', (tester) async {
    SlotItem? picked;
    await tester.pumpWidget(_wrap(SlotGrid(
      slots: const [SlotItem(hour: 9, minute: 0), SlotItem(hour: 9, minute: 30, available: false)],
      onSelect: (s) => picked = s,
    )));
    await tester.tap(find.text('9:30'));
    expect(picked, isNull);
    await tester.tap(find.text('9:00'));
    expect(picked?.key, '09:00');
  });

  testWidgets('showBsmConfirm devuelve true al confirmar', (tester) async {
    bool? result;
    await tester.pumpWidget(_wrap(Builder(
      builder: (context) => BsmButton(
        label: 'Cancelar cita',
        variant: BsmButtonVariant.dangerGhost,
        onPressed: () async => result = await showBsmConfirm(context, title: '¿Cancelar esta cita?', body: 'Se liberará el horario.', confirmLabel: 'Sí, cancelar cita'),
      ),
    )));
    await tester.tap(find.text('Cancelar cita'));
    await tester.pumpAndSettle();
    expect(find.text('¿Cancelar esta cita?'), findsOneWidget);
    await tester.tap(find.text('Sí, cancelar cita'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('los componentes se construyen en tema oscuro', (tester) async {
    await tester.pumpWidget(_wrap(
      Column(children: [
        const BsmBanner(title: 'Estás reprogramando tu cita'),
        const BsmEmptyState(title: 'Aún no tienes citas'),
        BsmCalendar(month: DateTime(2026, 11), onSelect: (_) {}),
      ]),
      brightness: Brightness.dark,
    ));
    expect(find.text('Noviembre 2026'), findsOneWidget);
  });
}
