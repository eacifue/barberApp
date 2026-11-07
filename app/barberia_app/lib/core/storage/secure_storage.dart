import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return const SecureStorageService(FlutterSecureStorage());
});

class SecureStorageService {
  const SecureStorageService(this._storage);

  static const _tokenKey = 'jwt_token';
  static const _nombreKey = 'user_nombre';
  static const _onboardingKey = 'onboarding_visto';
  static const _permisoPospuestoKey = 'notificaciones_pospuestas';

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  /// Cierra la sesión local: token y nombre del usuario. El onboarding y la
  /// preferencia de notificaciones son del dispositivo y se conservan.
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _nombreKey);
  }

  /// Nombre de pila para el saludo de Inicio (el JWT no lo trae).
  Future<void> saveNombre(String nombre) => _storage.write(key: _nombreKey, value: nombre);

  Future<String?> getNombre() => _storage.read(key: _nombreKey);

  Future<bool> onboardingVisto() async => await _storage.read(key: _onboardingKey) == '1';

  Future<void> marcarOnboardingVisto() => _storage.write(key: _onboardingKey, value: '1');

  /// «Ahora no» en el onboarding: no volver a pedir el permiso hasta la primera reserva.
  Future<bool> permisoPospuesto() async => await _storage.read(key: _permisoPospuestoKey) == '1';

  Future<void> setPermisoPospuesto(bool value) =>
      value ? _storage.write(key: _permisoPospuestoKey, value: '1') : _storage.delete(key: _permisoPospuestoKey);
}
