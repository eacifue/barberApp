import 'barbershop_model.dart';

String _normalizar(String texto) {
  const conTilde = 'áéíóúüñ';
  const sinTilde = 'aeiouun';
  final minus = texto.toLowerCase();
  final buffer = StringBuffer();
  for (final c in minus.split('')) {
    final i = conTilde.indexOf(c);
    buffer.write(i < 0 ? c : sinTilde[i]);
  }
  return buffer.toString();
}

/// Barberías que coinciden con lo escrito (nombre, ciudad o dirección; sin
/// importar mayúsculas ni tildes), en orden alfabético.
List<BarbershopModel> filtrarBarberias(List<BarbershopModel> barberias, String consulta) {
  final palabras = _normalizar(consulta).split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  final coinciden = barberias.where((b) {
    final texto = _normalizar('${b.nombre} ${b.ciudad} ${b.direccion}');
    return palabras.every(texto.contains);
  }).toList()
    ..sort((a, b) => _normalizar(a.nombre).compareTo(_normalizar(b.nombre)));
  return coinciden;
}
