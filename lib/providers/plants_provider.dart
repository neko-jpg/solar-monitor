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

  Future<void> load() async { state = await _prefs.load(); }
  Future<void> _save() async => _prefs.save(state);

  Future<void> add(Plant p) async { state = [...state, p]; await _save(); }
  Future<void> update(Plant p) async { state = [for (final x in state) if (x.id==p.id) p else x]; await _save(); }
  Future<void> remove(String id) async { state = state.where((e)=>e.id!=id).toList(); await _save(); }

  // ★ 追加：find
  Plant? find(String id) {
    for (final p in state) { if (p.id == id) return p; }
    return null;
  }
}
