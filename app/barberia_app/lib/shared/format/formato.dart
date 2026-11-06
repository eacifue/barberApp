// Formatos es-CO del sistema de diseño (design/docs/03-copy.md).
//
// Se construyen a mano en vez de con los patrones CLDR de `intl` para que el
// resultado sea idéntico en todas las versiones del paquete (CLDR cambia las
// abreviaturas de mes y los marcadores a. m. / p. m. entre versiones).

/// Espacio sin salto: evita que «p. m.», «12 nov» o «50 min» se partan entre líneas.
const _nbsp = '\u00A0';

const _dias = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
const _meses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];
const _mesesCortos = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

String _miles(int n) {
  final digits = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  return n < 0 ? '-$buf' : buf.toString();
}

String _capitalizar(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

abstract final class Formato {
  /// `$45.000` · `$1.245.000` (pesos, sin decimales).
  static String dinero(num valor) => '\$${_miles(valor.round())}';

  /// `4,8` (decimal con coma).
  static String decimal(num valor, {int decimales = 1}) => valor.toStringAsFixed(decimales).replaceAll('.', ',');

  /// `3:30 p. m.` (12 h).
  static String hora(DateTime t) => horaDe(t.hour, t.minute);

  /// `9:00 a. m.` a partir de hora y minuto (0–23, 0–59).
  static String horaDe(int hour, int minute) {
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    final marca = hour < 12 ? 'a.${_nbsp}m.' : 'p.${_nbsp}m.';
    return '$h12:${minute.toString().padLeft(2, '0')}$_nbsp$marca';
  }

  /// `3:30 p. m. – 4:20 p. m.`
  static String rango(DateTime inicio, DateTime fin) => '${hora(inicio)} – ${hora(fin)}';

  /// `lunes` … `domingo` (minúscula, para usar dentro de una frase).
  static String diaSemana(DateTime d) => _dias[d.weekday - 1];

  /// `jueves 12 de noviembre`. Con [conAnio]: `jueves 12 de noviembre de 2026`.
  static String fechaLarga(DateTime d, {bool conAnio = false}) =>
      '${diaSemana(d)} ${d.day} de ${_meses[d.month - 1]}${conAnio ? ' de ${d.year}' : ''}';

  /// `12 nov` · con [conAnio]: `12 nov 2026`.
  static String fechaCorta(DateTime d, {bool conAnio = false}) =>
      '${d.day}$_nbsp${_mesesCortos[d.month - 1]}${conAnio ? '$_nbsp${d.year}' : ''}';

  /// `Jue 12 nov` (barra de resumen de la reserva).
  static String fechaResumen(DateTime d) =>
      '${_capitalizar(_dias[d.weekday - 1].substring(0, 3))} ${fechaCorta(d)}';

  /// `Noviembre 2026` (título de calendario).
  static String mesAnio(DateTime d) => '${_capitalizar(_meses[d.month - 1])} ${d.year}';

  /// `50 min` · `1 h` · `1 h 15 min`.
  static String duracion(int minutos) {
    final h = minutos ~/ 60;
    final m = minutos % 60;
    if (h == 0) return '$m${_nbsp}min';
    if (m == 0) return '$h${_nbsp}h';
    return '$h${_nbsp}h $m${_nbsp}min';
  }

  /// `300 123 4567` (agrupa 3-3-4 un celular colombiano de 10 dígitos).
  static String telefono(String raw) {
    final d = raw.replaceAll(RegExp(r'\D'), '');
    final local = d.length == 12 && d.startsWith('57') ? d.substring(2) : d;
    if (local.length != 10) return raw;
    return '${local.substring(0, 3)} ${local.substring(3, 6)} ${local.substring(6)}';
  }
}
