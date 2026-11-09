import '../auth/jwt_utils.dart';
import '../storage/secure_storage.dart';

/// A dónde va la app al abrirse (splash y fin del onboarding). Sin barbería
/// elegida no hay a dónde entrar: primero se elige. Una sesión sin barbería es
/// de antes de las varias barberías y el API ya no la acepta.
String destinoInicial({required bool onboardingVisto, required bool conSesion, required bool conBarberia}) {
  if (!onboardingVisto) return '/bienvenida';
  if (!conBarberia) return '/elegir-barberia';
  return conSesion ? '/dashboard' : '/login';
}

/// [destinoInicial] con lo guardado en el dispositivo. Una sesión abierta sin
/// barbería guardada (app de antes de las varias barberías) toma la de su
/// cuenta; si la cuenta no trae una, se cierra la sesión y se elige barbería.
Future<String> resolverDestinoInicial(
  SecureStorageService storage, {
  required bool onboardingVisto,
  required String? token,
  required String? barberiaId,
}) async {
  final conSesion = token != null && token.isNotEmpty;
  var conBarberia = barberiaId != null && barberiaId.isNotEmpty;
  if (conSesion && !conBarberia) {
    final deLaCuenta = JwtUtils.tryGetBarberiaId(token);
    if (deLaCuenta != null) {
      await storage.saveBarberia(id: deLaCuenta, nombre: '');
      conBarberia = true;
    } else {
      await storage.clearToken();
    }
  }
  return destinoInicial(onboardingVisto: onboardingVisto, conSesion: conSesion && conBarberia, conBarberia: conBarberia);
}
