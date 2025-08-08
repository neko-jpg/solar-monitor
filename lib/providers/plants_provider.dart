import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plant.dart';

/// アプリ全体で利用する plantsProvider
final plantsProvider = StateNotifierProvider<PlantsNotifier, List<Plant>>((
  ref,
) {
  return PlantsNotifier();
});

class PlantsNotifier extends StateNotifier<List<Plant>> {
  PlantsNotifier() : super([]);

  void addPlant(Plant plant) {
    state = [...state, plant];
  }

  void removePlant(Plant plant) {
    state = state.where((p) => p.id != plant.id).toList();
  }

  void updatePlant(Plant updatedPlant) {
    state = [
      for (final plant in state)
        if (plant.id == updatedPlant.id) updatedPlant else plant,
    ];
  }
}
