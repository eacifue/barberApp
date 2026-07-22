import 'dart:convert';

class JwtUtils {
  JwtUtils._();

  static const _roleClaimCandidates = [
    'role',
    'roles',
    'Role',
    'http://schemas.microsoft.com/ws/2008/06/identity/claims/role',
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/role',
  ];

  static String? tryGetRole(String token) {
    final payload = _tryDecodePayload(token);
    if (payload == null) return null;

    Object? role;
    for (final key in _roleClaimCandidates) {
      if (payload.containsKey(key)) {
        role = payload[key];
        break;
      }
    }

    if (role is String) return role;
    if (role is List && role.isNotEmpty && role.first is String) {
      return role.first as String;
    }

    return null;
  }

  static bool isAdminRole(String? role) {
    if (role == null || role.trim().isEmpty) {
      return false;
    }
    return role.trim().toLowerCase() == 'admin';
  }

  static Map<String, dynamic>? _tryDecodePayload(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return null;

    try {
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = json.decode(decoded);
      return payload is Map<String, dynamic> ? payload : null;
    } catch (_) {
      return null;
    }
  }
}
