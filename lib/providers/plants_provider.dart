import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/plant.dart';
import '../models/reading.dart';

final plantsProvider = StateNotifierProvider<PlantsNotifier, List<Plant>>((ref) {
  return PlantsNotifier()..loadMock();
});

class PlantsNotifier extends StateNotifier<List<Plant>> {
  PlantsNotifier() : super([]);

  void loadMock() {
    final now = DateTime.now();
    state = List.generate(3, (i) {
      final rnd = Random(i);
      final readings = List.generate(7, (d) {
        return Reading(
          timestamp: now.subtract(Duration(days: 6 - d)),
          power: 50 + rnd.nextInt(100).toDouble(),
        );
      });
      return Plant(
        id: 'plant_$i',
        name: 'Plant ${i + 1}',
        url: 'https://example.com/plant${i + 1}',
        username: 'user',
        password: 'pass',
        themeColor: Colors.primaries[i % Colors.primaries.length],
        icon: Icons.solar_power.codePoint.toString(),
        readings: readings,
      );
    });
  }

  void addPlant(Plant plant) {
    state = [...state, plant];
  }

  Plant? getById(String id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
