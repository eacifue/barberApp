import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_repository.dart';
import '../storage/secure_storage.dart';

final permisoNotificacionesProvider = Provider<PermisoNotificaciones>((ref) {
  return PermisoNotificaciones(ref.watch(secureStorageProvider), ref.watch(authRepositoryProvider));
});

/// Permiso de notificaciones (design/docs/02-patrones.md · Onboarding): se pide
/// con un botón propio antes del diálogo del sistema; con «Ahora no» no se
/// vuelve a pedir hasta la primera reserva. Todo es best-effort: si Firebase
/// no está configurado, la app sigue funcionando sin push.
class PermisoNotificaciones {
  const PermisoNotificaciones(this._storage, this._auth);

  final SecureStorageService _storage;
  final AuthRepository _auth;

  bool _autorizado(NotificationSettings s) =>
      s.authorizationStatus == AuthorizationStatus.authorized || s.authorizationStatus == AuthorizationStatus.provisional;

  /// Muestra el diálogo del sistema. Devuelve `true` si el usuario aceptó.
  Future<bool> pedir() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
      await _storage.setPermisoPospuesto(false);
      final ok = _autorizado(settings);
      if (ok) await sincronizarToken();
      return ok;
    } catch (e) {
      debugPrint('No se pudo pedir el permiso de notificaciones: $e');
      return false;
    }
  }

  /// «Ahora no»: se volverá a ofrecer después de la primera reserva.
  Future<void> posponer() => _storage.setPermisoPospuesto(true);

  /// Tras iniciar sesión: sin diálogo; solo registra el token si ya hay permiso.
  Future<void> sincronizarSiAutorizado() async {
    try {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      if (_autorizado(settings)) await sincronizarToken();
    } catch (e) {
      debugPrint('No se pudo revisar el permiso de notificaciones: $e');
    }
  }

  /// Después de reservar: si el cliente lo pospuso y aún no decidió, se pide ahora.
  Future<void> pedirSiPospuesto() async {
    try {
      if (!await _storage.permisoPospuesto()) return;
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        await pedir();
      } else {
        await _storage.setPermisoPospuesto(false);
      }
    } catch (e) {
      debugPrint('No se pudo pedir el permiso de notificaciones: $e');
    }
  }

  Future<void> sincronizarToken() async {
    if ((await _storage.getToken() ?? '').isEmpty) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) await _auth.actualizarTokenFCM(token);
  }
}
