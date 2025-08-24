import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plant.dart';
import '../services/storage/plant_prefs.dart';

// Provider for the PlantPrefs service
final plantPrefsProvider = Provider((ref) => PlantPrefs());

// Provider for the list of plants, managed by PlantsNotifier
final plantsProvider = StateNotifierProvider<PlantsNotifier, List<Plant>>((ref) {
  final prefs = ref.watch(plantPrefsProvider);
  return PlantsNotifier(prefs);
});

class PlantsNotifier extends StateNotifier<List<Plant>> {
  final PlantPrefs _prefs;

  PlantsNotifier(this._prefs) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _prefs.load();
  }

  Future<void> _save() async {
    await _prefs.save(state);
  }

  Future<void> add(Plant plant) async {
    // Avoid adding a plant with a duplicate ID
    if (state.any((p) => p.id == plant.id)) {
      return;
    }
    state = [...state, plant];
    await _save();
  }

  Future<void> update(Plant plant) async {
    state = [
      for (final p in state)
        if (p.id == plant.id) plant else p,
    ];
    await _save();
  }

  Future<void> remove(String plantId) async {
    state = state.where((p) => p.id != plantId).toList();
    await _save();
  }

  Plant? find(String plantId) {
    try {
      return state.firstWhere((p) => p.id == plantId);
    } catch (e) {
      return null; // Not found
    }
  }
}
