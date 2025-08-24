import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plant.dart';
import '../services/storage/plant_prefs.dart';

final plantPrefsProvider = Provider((ref) => PlantPrefs());

final plantsProvider = StateNotifierProvider<PlantsNotifier, List<Plant>>((ref) {
  final prefs = ref.watch(plantPrefsProvider);
  return PlantsNotifier(prefs)..load();
});

class PlantsNotifier extends StateNotifier<List<Plant>> {
  final PlantPrefs _prefs;
  PlantsNotifier(this._prefs) : super(const []);

  Future<void> load() async {
    final list = await _prefs.load();
    state = List.unmodifiable(list);
  }

  Future<void> _save() async => _prefs.save(state);

  Future<void> add(Plant p) async {
    state = [...state, p];
    await _save();
  }

  Future<void> update(Plant p) async {
    state = [for (final x in state) if (x.id == p.id) p else x];
    await _save();
  }

  Future<void> remove(String plantId) async {
    state = state.where((p) => p.id != plantId).toList();
    await _save();
  }

  Plant? find(String plantId) {
    for (final p in state) { if (p.id == plantId) return p; }
    return null;
  }
}
