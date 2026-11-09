import 'dart:convert';

import 'package:barberia_app/core/api/api_client.dart';
import 'package:barberia_app/core/auth/jwt_utils.dart';
import 'package:barberia_app/core/config/destino_inicial.dart';
import 'package:barberia_app/core/storage/secure_storage.dart';
import 'package:barberia_app/features/barberias/domain/barberia_busqueda.dart';
import 'package:barberia_app/features/barberias/domain/barbershop_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

String _token(Map<String, dynamic> payload) {
  String b64(Object o) => base64Url.encode(utf8.encode(json.encode(o))).replaceAll('=', '');
  return '${b64({'alg': 'HS256'})}.${b64(payload)}.firma';
}

BarbershopModel _barberia(String id, String nombre, {String ciudad = 'Medellín', String direccion = ''}) =>
    BarbershopModel.fromJson({'id': id, 'nombre': nombre, 'ciudad': ciudad, 'direccion': direccion});

void main() {
  group('La barbería viaja en cada petición', () {
    test('con una barbería elegida, la petición lleva su X-Barberia-Id', () {
      final options = RequestOptions(path: '/servicios');

      ApiClient.aplicarBarberia(options, 'b-laureles');

      expect(options.headers['X-Barberia-Id'], 'b-laureles');
    });

    test('sin barbería elegida, la petición no lleva X-Barberia-Id', () {
      final options = RequestOptions(path: '/auth/login', headers: {'X-Barberia-Id': 'vieja'});

      ApiClient.aplicarBarberia(options, null);

      expect(options.headers.containsKey('X-Barberia-Id'), isFalse);
    });

    test('el listado para elegir barbería nunca lleva X-Barberia-Id', () {
      // Si la barbería guardada fue desactivada, el header haría fallar el listado con 404.
      final options = RequestOptions(path: '/barberias', extra: ApiClient.sinBarberia);

      ApiClient.aplicarBarberia(options, 'b-desactivada');

      expect(options.headers.containsKey('X-Barberia-Id'), isFalse);
    });

    test('sin sesión, un 404 «La barbería no existe.» significa que hay que elegir otra', () {
      expect(ApiClient.barberiaYaNoExiste(404, {'message': 'La barbería no existe.'}, conSesion: false), isTrue);
    });

    test('otro 404, o con sesión, no borra la barbería elegida', () {
      expect(ApiClient.barberiaYaNoExiste(404, {'message': 'La cita no existe.'}, conSesion: false), isFalse);
      expect(ApiClient.barberiaYaNoExiste(404, {'message': 'La barbería no existe.'}, conSesion: true), isFalse);
      expect(ApiClient.barberiaYaNoExiste(400, {'message': 'La barbería no existe.'}, conSesion: false), isFalse);
    });
  });

  group('JwtUtils · barbería de la cuenta', () {
    test('lee el claim barberiaId', () {
      expect(JwtUtils.tryGetBarberiaId(_token({'role': 'Cliente', 'barberiaId': 'b-1'})), 'b-1');
    });

    test('el SuperAdmin no trae barberiaId', () {
      expect(JwtUtils.tryGetBarberiaId(_token({'role': 'Admin'})), isNull);
    });
  });

  group('La barbería elegida se guarda en el dispositivo', () {
    late SecureStorageService storage;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      storage = const SecureStorageService(FlutterSecureStorage());
    });

    test('guarda y lee la barbería elegida', () async {
      await storage.saveBarberia(id: 'b-1', nombre: 'Barbería Laureles');

      expect(await storage.getBarberiaId(), 'b-1');
      expect(await storage.getBarberiaNombre(), 'Barbería Laureles');
    });

    test('cerrar sesión conserva la barbería; cambiar de barbería la olvida', () async {
      await storage.saveToken('t');
      await storage.saveBarberia(id: 'b-1', nombre: 'Barbería Laureles');

      await storage.clearToken();
      expect(await storage.getBarberiaId(), 'b-1');

      await storage.clearBarberia();
      expect(await storage.getBarberiaId(), isNull);
      expect(await storage.getBarberiaNombre(), isNull);
    });
  });

  group('Destino al abrir la app', () {
    test('primera apertura: onboarding', () {
      expect(destinoInicial(onboardingVisto: false, conSesion: false, conBarberia: false), '/bienvenida');
    });

    test('sin barbería elegida y sin sesión: elegir barbería', () {
      expect(destinoInicial(onboardingVisto: true, conSesion: false, conBarberia: false), '/elegir-barberia');
    });

    test('con barbería y sin sesión: login', () {
      expect(destinoInicial(onboardingVisto: true, conSesion: false, conBarberia: true), '/login');
    });

    test('con sesión y barbería: inicio', () {
      expect(destinoInicial(onboardingVisto: true, conSesion: true, conBarberia: true), '/dashboard');
    });

    test('con sesión pero sin barbería (cuenta de antes de varias barberías): elegir barbería', () {
      expect(destinoInicial(onboardingVisto: true, conSesion: true, conBarberia: false), '/elegir-barberia');
    });
  });

  group('Sesión abierta de antes de las varias barberías', () {
    late SecureStorageService storage;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      storage = const SecureStorageService(FlutterSecureStorage());
    });

    test('si la cuenta trae su barbería, se guarda y sigue a Inicio', () async {
      final token = _token({'role': 'Cliente', 'barberiaId': 'b-1'});
      await storage.saveToken(token);

      final destino = await resolverDestinoInicial(storage, onboardingVisto: true, token: token, barberiaId: null);

      expect(destino, '/dashboard');
      expect(await storage.getBarberiaId(), 'b-1');
      expect(await storage.getToken(), token);
    });

    test('si la cuenta no trae barbería, se cierra la sesión y se elige barbería', () async {
      final token = _token({'role': 'Cliente'});
      await storage.saveToken(token);

      final destino = await resolverDestinoInicial(storage, onboardingVisto: true, token: token, barberiaId: null);

      expect(destino, '/elegir-barberia');
      expect(await storage.getToken(), isNull);
    });
  });

  group('Buscar barbería', () {
    final todas = [
      _barberia('1', 'BarberShop El Poblado', direccion: 'Cra 43A #9'),
      _barberia('2', 'Barbería Laureles', direccion: 'Cra 76 #33'),
      _barberia('3', 'Corte Fino', ciudad: 'Bogotá'),
    ];

    test('sin texto muestra todas, en orden alfabético', () {
      expect(filtrarBarberias(todas, '  ').map((b) => b.nombre), ['Barbería Laureles', 'BarberShop El Poblado', 'Corte Fino']);
    });

    test('busca por nombre sin importar mayúsculas ni tildes', () {
      expect(filtrarBarberias(todas, 'BARBERIA lau').map((b) => b.id), ['2']);
    });

    test('busca por ciudad y por dirección', () {
      expect(filtrarBarberias(todas, 'bogota').map((b) => b.id), ['3']);
      expect(filtrarBarberias(todas, '76').map((b) => b.id), ['2']);
    });

    test('sin coincidencias devuelve vacío', () {
      expect(filtrarBarberias(todas, 'cali'), isEmpty);
    });
  });
}
