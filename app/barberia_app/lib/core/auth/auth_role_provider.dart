import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_storage.dart';
import 'jwt_utils.dart';

final authRoleProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  final token = await storage.getToken();
  if (token == null || token.isEmpty) return null;

  final role = JwtUtils.tryGetRole(token);
  if (kDebugMode) {
    debugPrint('User role: $role');
  }

  return role;
});
