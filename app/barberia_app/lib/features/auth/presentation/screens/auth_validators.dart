/// Validaciones de login y registro (design/docs/03-copy.md): el mensaje dice
/// cómo corregir.
abstract final class AuthValidators {
  static final _correo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');

  static String? correo(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Escribe tu correo.';
    if (!_correo.hasMatch(t)) return 'Ingresa un correo válido, por ejemplo nombre@correo.co.';
    return null;
  }

  static String? requerido(String? v, String mensaje) => (v ?? '').trim().isEmpty ? mensaje : null;

  /// Celular colombiano de 10 dígitos (acepta espacios y +57).
  static String? celular(String? v) {
    final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
    final local = d.length == 12 && d.startsWith('57') ? d.substring(2) : d;
    if (local.isEmpty) return 'Escribe tu celular.';
    if (local.length != 10) return 'Ingresa un número de 10 dígitos.';
    return null;
  }

  static String? clave(String? v) => (v ?? '').length < 6 ? 'La contraseña debe tener al menos 6 caracteres.' : null;
}
