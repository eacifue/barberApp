import 'package:flutter_test/flutter_test.dart';

import 'package:barberia_app/features/auth/presentation/screens/auth_validators.dart';

void main() {
  test('correo: vacío, inválido y válido', () {
    expect(AuthValidators.correo(''), 'Escribe tu correo.');
    expect(AuthValidators.correo('andres@correo'), contains('correo válido'));
    expect(AuthValidators.correo(' andres.gomez@correo.co '), isNull);
  });

  test('celular: 10 dígitos, con espacios o +57', () {
    expect(AuthValidators.celular(''), 'Escribe tu celular.');
    expect(AuthValidators.celular('300 123'), 'Ingresa un número de 10 dígitos.');
    expect(AuthValidators.celular('300 123 4567'), isNull);
    expect(AuthValidators.celular('+57 300 123 4567'), isNull);
  });

  test('contraseña: mínimo 6 caracteres', () {
    expect(AuthValidators.clave('12345'), 'La contraseña debe tener al menos 6 caracteres.');
    expect(AuthValidators.clave('barberia26'), isNull);
  });
}
