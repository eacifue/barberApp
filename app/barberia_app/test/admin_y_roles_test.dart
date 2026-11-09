import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:barberia_app/core/auth/jwt_utils.dart';
import 'package:barberia_app/features/admin/data/models/admin_barberia_model.dart';
import 'package:barberia_app/features/admin/presentation/screens/admin_screen.dart';

String _token(Map<String, dynamic> payload) {
  String b64(Object o) => base64Url.encode(utf8.encode(json.encode(o))).replaceAll('=', '');
  return '${b64({'alg': 'HS256'})}.${b64(payload)}.firma';
}

void main() {
  group('JwtUtils · rol Barbero', () {
    test('lee el claim barberoId de una cuenta de barbero', () {
      final t = _token({'role': 'Barbero', 'barberoId': 'b-123'});
      expect(JwtUtils.isBarberoRole(JwtUtils.tryGetRole(t)), isTrue);
      expect(JwtUtils.tryGetBarberoId(t), 'b-123');
    });

    test('un cliente no es barbero ni trae barberoId', () {
      final t = _token({'role': 'Cliente'});
      expect(JwtUtils.isBarberoRole(JwtUtils.tryGetRole(t)), isFalse);
      expect(JwtUtils.tryGetBarberoId(t), isNull);
    });
  });

  group('Quién administra en la app', () {
    test('el SuperAdmin y el administrador de barbería administran; cliente y barbero no', () {
      expect(JwtUtils.puedeAdministrar('Admin'), isTrue);
      expect(JwtUtils.puedeAdministrar('AdministradorBarberia'), isTrue);
      expect(JwtUtils.puedeAdministrar('Cliente'), isFalse);
      expect(JwtUtils.puedeAdministrar('Barbero'), isFalse);
      expect(JwtUtils.puedeAdministrar(null), isFalse);
    });

    test('el administrador de barbería no ve «Mi negocio» (editar la barbería es del SuperAdmin, como en el panel)', () {
      expect(AdminScreen.pestanasPara('AdministradorBarberia').map((p) => p.label), ['Equipo', 'Servicios', 'Clientes']);
      expect(AdminScreen.pestanasPara('Admin').map((p) => p.label), ['Mi negocio', 'Equipo', 'Servicios', 'Clientes']);
    });
  });

  group('AdminBarberiaModel.toUpsertJson', () {
    test('conserva slogan, descripción, país, foto y sitio web al guardar', () {
      final m = AdminBarberiaModel.fromJson({
        'id': 'x',
        'nombre': 'BarberShop Medellín',
        'slogan': 'Corte con oficio',
        'descripcion': 'En El Poblado',
        'pais': 'Colombia',
        'fotoPortada': 'https://ejemplo.co/portada.jpg',
        'sitioWeb': 'https://ejemplo.co',
        'diasDescanso': ['Domingo'],
      });
      final json = m.toUpsertJson();
      expect(json['slogan'], 'Corte con oficio');
      expect(json['descripcion'], 'En El Poblado');
      expect(json['pais'], 'Colombia');
      expect(json['fotoPortada'], 'https://ejemplo.co/portada.jpg');
      expect(json['sitioWeb'], 'https://ejemplo.co');
      expect(json['diasDescanso'], ['Domingo']);
    });

    test('sin país en la respuesta usa Colombia', () {
      expect(AdminBarberiaModel.fromJson({'id': 'x'}).toUpsertJson()['pais'], 'Colombia');
    });
  });
}
