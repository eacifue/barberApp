import 'package:barberia_app/core/api/api_client.dart';
import 'package:barberia_app/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Cada petición le dice al API de qué barbería es la app', () {
    expect(ApiClient.encabezadosBase['X-Barberia-Id'], AppConfig.defaultBarberiaId);
  });
}
