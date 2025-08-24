import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/plant.dart';

class PlantPrefs {
  static const _key = 'plants_v1';
  Future<List<Plant>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Plant.fromJson).toList();
  }
  Future<void> save(List<Plant> plants) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(plants.map((e) => e.toJson()).toList());
    await sp.setString(_key, raw);
  }
}
