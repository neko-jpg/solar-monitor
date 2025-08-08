// lib/services/storage/sp_storage_service.dart
import 'dart:convert'; // ← 追加
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';
import '../../models/plant.dart';
import '../../models/notification_settings.dart'; // ← 追加

class SpStorageService implements StorageService {
  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<List<Plant>> loadPlants() async {
    final p = await _prefs;
    final s = p.getString(StorageKeys.plants);
    if (s == null || s.isEmpty) return [];
    try {
      return decodePlants(s);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> savePlants(List<Plant> plants) async {
    final p = await _prefs;
    await p.setString(StorageKeys.plants, encodePlants(plants));
  }

  @override
  Future<NotificationSettings?> loadNotificationSettings() async {
    final p = await _prefs;
    final s = p.getString(StorageKeys.notification);
    if (s == null) return null;
    try {
      return NotificationSettings.fromJson(
        Map<String, dynamic>.from(jsonDecode(s)),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveNotificationSettings(NotificationSettings s) async {
    final p = await _prefs;
    await p.setString(StorageKeys.notification, jsonEncode(s.toJson()));
  }
}
