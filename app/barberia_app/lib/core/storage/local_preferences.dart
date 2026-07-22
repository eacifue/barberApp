import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localPreferencesProvider = Provider<LocalPreferences>((ref) {
  return const LocalPreferences();
});

class LocalPreferences {
  const LocalPreferences();

  static const _selectedBarbershopIdKey = 'selected_barbershop_id';

  Future<String?> getSelectedBarbershopId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedBarbershopIdKey);
  }

  Future<void> setSelectedBarbershopId(String barbershopId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedBarbershopIdKey, barbershopId);
  }

  Future<void> clearSelectedBarbershopId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedBarbershopIdKey);
  }
}
