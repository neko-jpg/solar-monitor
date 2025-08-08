import 'dart:math';
import 'package:flutter/material.dart'; // Colors 用
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/plant.dart';
import '../models/reading.dart';
import '../services/storage/sp_storage_service.dart';
import '../services/storage/storage_service.dart';

final _storage = SpStorageService();

/// アプリ全体で利用する plantsProvider
final plantsProvider = StateNotifierProvider<PlantsNotifier, List<Plant>>((
  ref,
) {
  return PlantsNotifier()..init(); // ← 初期化（SP読み込み or モック生成）
});

class PlantsNotifier extends StateNotifier<List<Plant>> {
  PlantsNotifier() : super(const []);

  /// 初期化：保存済みを読む。無ければモック生成→保存
  Future<void> init() async {
    final loaded = await _storage.loadPlants();
    if (loaded.isNotEmpty) {
      state = loaded;
    } else {
      _loadMock();
      await _persist();
    }
  }

  /// --- 公開API（既存互換） ---
  void addPlant(Plant plant) {
    add(plant);
  }

  void removePlant(Plant plant) {
    remove(plant.id);
  }

  void updatePlant(Plant updatedPlant) {
    update(updatedPlant);
  }

  /// --- 新API（短名） ---
  void add(Plant p) {
    state = [...state, p];
    _persist();
  }

  void update(Plant p) {
    state = [
      for (final x in state)
        if (x.id == p.id) p else x,
    ];
    _persist();
  }

  void remove(String id) {
    state = state.where((p) => p.id != id).toList();
    _persist();
  }

  Plant? find(String id) =>
      state.cast<Plant?>().firstWhere((p) => p?.id == id, orElse: () => null);

  // ---- 内部 ----
  Future<void> _persist() async => _storage.savePlants(state);

  void _loadMock() {
    final now = DateTime.now();
    state = List.generate(6, (i) {
      final r = Random(i + 42);
      final readings = List.generate(24, (h) {
        // 日内カーブ：朝→昼ピーク→夕方
        final base = (sin((h - 6) / 24 * 3.14159) * 100).clamp(0, 120);
        return Reading(
          timestamp: DateTime(now.year, now.month, now.day, h),
          power: (base + r.nextInt(20)).toDouble(),
        );
      });
      return Plant(
        id: 'plant_$i',
        name: 'Plant ${i + 1}',
        url: 'https://example.com/p/${i + 1}',
        username: 'user',
        password: 'pass',
        themeColor: Colors.primaries[i % Colors.primaries.length],
        icon: Icons.solar_power.codePoint.toString(),
        readings: readings,
      );
    });
  }
}
