import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plant.dart';

class PlantsNotifier extends StateNotifier<List<Plant>> {
  PlantsNotifier() : super([]);

  void add(Plant plant) {
    state = [...state, plant];
  }

  void update(Plant updated) {
    state = [
      for (final p in state)
        if (p.id == updated.id) updated else p,
    ];
  }

  void remove(String id) {
    state = state.where((p) => p.id != id).toList();
  }

  Plant? find(String id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

final plantsProvider = StateNotifierProvider<PlantsNotifier, List<Plant>>((
  ref,
) {
  return PlantsNotifier();
});
