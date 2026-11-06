import 'package:flutter_test/flutter_test.dart';

import 'package:barberia_app/shared/format/formato.dart';

/// Normaliza el espacio sin salto para comparar con el copy de 03-copy.md.
String _plano(String s) => s.replaceAll(' ', ' ');

void main() {
  group('Formato (es-CO)', () {
    test('dinero con punto de miles y sin decimales', () {
      expect(Formato.dinero(45000), r'$45.000');
      expect(Formato.dinero(1245000), r'$1.245.000');
      expect(Formato.dinero(900), r'$900');
      expect(Formato.dinero(49999.6), r'$50.000');
    });

    test('decimal con coma', () {
      expect(Formato.decimal(4.8), '4,8');
    });

    test('hora en 12 h con a. m. / p. m.', () {
      expect(_plano(Formato.horaDe(15, 30)), '3:30 p. m.');
      expect(_plano(Formato.horaDe(9, 0)), '9:00 a. m.');
      expect(_plano(Formato.horaDe(0, 5)), '12:05 a. m.');
      expect(_plano(Formato.horaDe(12, 0)), '12:00 p. m.');
    });

    test('rango con guion largo', () {
      final a = DateTime(2026, 11, 12, 15, 30);
      final b = DateTime(2026, 11, 12, 16, 20);
      expect(_plano(Formato.rango(a, b)), '3:30 p. m. – 4:20 p. m.');
    });

    test('fechas larga, corta, resumen y título de mes', () {
      final d = DateTime(2026, 11, 12); // jueves
      expect(Formato.fechaLarga(d), 'jueves 12 de noviembre');
      expect(_plano(Formato.fechaCorta(d)), '12 nov');
      expect(_plano(Formato.fechaCorta(d, conAnio: true)), '12 nov 2026');
      expect(_plano(Formato.fechaResumen(d)), 'Jue 12 nov');
      expect(Formato.mesAnio(d), 'Noviembre 2026');
    });

    test('la semana empieza el lunes', () {
      expect(Formato.diaSemana(DateTime(2026, 11, 9)), 'lunes');
      expect(Formato.diaSemana(DateTime(2026, 11, 15)), 'domingo');
    });

    test('duración en min y h', () {
      expect(_plano(Formato.duracion(50)), '50 min');
      expect(_plano(Formato.duracion(60)), '1 h');
      expect(_plano(Formato.duracion(75)), '1 h 15 min');
    });

    test('teléfono 3-3-4', () {
      expect(Formato.telefono('3001234567'), '300 123 4567');
      expect(Formato.telefono('+57 300 123 4567'), '300 123 4567');
      expect(Formato.telefono('123'), '123');
    });
  });
}
