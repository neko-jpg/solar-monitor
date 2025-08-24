import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_settings.dart';

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings());

  void toggle(bool v) => state = state.copyWith(enabled: v);
  void setStaleMinutes(int m) => state = state.copyWith(staleMinutes: m);
  void setLowPower(double kw) => state = state.copyWith(lowPowerKw: kw);
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  (ref) => NotificationSettingsNotifier(),
);
