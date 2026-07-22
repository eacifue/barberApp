import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/local_preferences.dart';

class SelectedBarbershopState {
  const SelectedBarbershopState({required this.ready, this.barberiaId});

  final bool ready;
  final String? barberiaId;

  bool get hasSelection => (barberiaId ?? '').trim().isNotEmpty;

  SelectedBarbershopState copyWith({bool? ready, String? barberiaId}) {
    return SelectedBarbershopState(
      ready: ready ?? this.ready,
      barberiaId: barberiaId,
    );
  }
}

final selectedBarbershopProvider =
    StateNotifierProvider<
      SelectedBarbershopController,
      SelectedBarbershopState
    >(
      (ref) =>
          SelectedBarbershopController(ref.watch(localPreferencesProvider)),
    );

class SelectedBarbershopController
    extends StateNotifier<SelectedBarbershopState> {
  SelectedBarbershopController(this._preferences)
    : super(const SelectedBarbershopState(ready: false)) {
    _hydrate();
  }

  final LocalPreferences _preferences;

  Future<void> _hydrate() async {
    final storedId = await _preferences.getSelectedBarbershopId();
    state = SelectedBarbershopState(ready: true, barberiaId: storedId);
  }

  Future<void> selectBarbershop(String barberiaId) async {
    await _preferences.setSelectedBarbershopId(barberiaId);
    state = SelectedBarbershopState(ready: true, barberiaId: barberiaId);
  }

  Future<void> clearSelection() async {
    await _preferences.clearSelectedBarbershopId();
    state = const SelectedBarbershopState(ready: true, barberiaId: null);
  }
}
