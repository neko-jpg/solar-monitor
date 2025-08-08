import 'dart:convert';
import '../../models/plant.dart';
import '../../models/notification_settings.dart';

abstract class StorageService {
  Future<void> savePlants(List<Plant> plants);
  Future<List<Plant>> loadPlants();

  Future<void> saveNotificationSettings(NotificationSettings s);
  Future<NotificationSettings?> loadNotificationSettings();
}

// キー定義（SPキーの集中管理）
class StorageKeys {
  static const plants = 'plants_json_v1';
  static const notification = 'notification_settings_v1';
}

// ヘルパ
String encodePlants(List<Plant> list) =>
    jsonEncode(list.map((e) => e.toJson()).toList());
List<Plant> decodePlants(String s) =>
    (jsonDecode(s) as List).map((e) => Plant.fromJson(e)).toList();
