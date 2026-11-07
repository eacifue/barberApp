import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/storage/secure_storage.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(secureStorageProvider),
  );
});

class AuthRepository {
  const AuthRepository(this._apiClient, this._secureStorageService);

  final ApiClient _apiClient;
  final SecureStorageService _secureStorageService;

  Future<void> login({required String correo, required String password}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {'correo': correo.trim(), 'password': password},
      fromJson: (json) => json,
    );

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isEmpty
            ? 'No se pudo iniciar sesión.'
            : response.message,
      );
    }

    final token = response.data!['token'] as String?;
    if (token == null || token.isEmpty) {
      throw AppException('La respuesta de autenticación no contiene token.');
    }

    await _secureStorageService.saveToken(token);
    final nombre = (response.data!['nombreCompleto'] as String? ?? '').trim().split(RegExp(r'\s+')).first;
    if (nombre.isNotEmpty) await _secureStorageService.saveNombre(nombre);
  }

  Future<void> registro({
    required String nombre,
    required String apellido,
    required String telefono,
    required String correo,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.registro,
      data: {
        'nombre': nombre.trim(),
        'apellido': apellido.trim(),
        'telefono': telefono.trim(),
        'correo': correo.trim(),
        'password': password,
      },
      fromJson: (json) => json,
    );

    if (!response.success || response.data == null) {
      throw AppException(
        response.message.isEmpty
            ? 'No se pudo crear la cuenta.'
            : response.message,
      );
    }

    final token = response.data!['token'] as String?;
    if (token == null || token.isEmpty) {
      throw AppException('La respuesta de registro no contiene token.');
    }

    await _secureStorageService.saveToken(token);
    final primerNombre = nombre.trim().split(RegExp(r'\s+')).first;
    if (primerNombre.isNotEmpty) await _secureStorageService.saveNombre(primerNombre);
  }

  Future<void> actualizarTokenFCM(String token) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.authFcmToken,
      data: {'token': token},
      fromJson: (json) => json,
    );

    if (!response.success) {
      throw AppException(
        response.message.isEmpty
            ? 'No se pudo actualizar token FCM.'
            : response.message,
      );
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.authLogout,
        fromJson: (json) => json,
      );
    } catch (_) {
      // El logout local no debe depender de que la API responda.
    } finally {
      await _secureStorageService.clearToken();
    }
  }
}
