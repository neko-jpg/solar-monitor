import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_settings.dart';
import '../services/storage/sp_storage_service.dart';

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
      (ref) => NotificationSettingsNotifier()..init(),
    );

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings());
  final _sp = SpStorageService();

  Future<void> init() async {
    final loaded = await _sp.loadNotificationSettings();
    if (loaded != null) state = loaded;
  }

  Future<void> _persist() async => _sp.saveNotificationSettings(state);

  void toggleDaily(bool v) {
    state = state.copyWith(dailySummary: v);
    _persist();
  }

  void addTime(TimeOfDay t) {
    state = state.copyWith(times: [...state.times, t]);
    _persist();
  }

  void removeTime(int i) {
    state = state.copyWith(times: [...state.times]..removeAt(i));
    _persist();
  }

  void setThreshold(double v) {
    state = state.copyWith(thresholdKw: v);
    _persist();
  }

  void toggleAbnormal(bool v) {
    state = state.copyWith(abnormalAlert: v);
    _persist();
  }

  void toggleMaxUpdate(bool v) {
    state = state.copyWith(maxUpdate: v);
    _persist();
  }
}
