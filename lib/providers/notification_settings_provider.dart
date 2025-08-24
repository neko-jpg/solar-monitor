import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSettings {
  final bool enabled;
  final int staleMinutes; // 例: 30分以上更新が無ければ通知
  final double lowPowerKw; // 例: 出力が 0.5kW 未満なら通知

  const NotificationSettings({
    this.enabled = true,
    this.staleMinutes = 30,
    this.lowPowerKw = 0.5,
  });

  NotificationSettings copyWith({
    bool? enabled,
    int? staleMinutes,
    double? lowPowerKw,
  }) => NotificationSettings(
        enabled: enabled ?? this.enabled,
        staleMinutes: staleMinutes ?? this.staleMinutes,
        lowPowerKw: lowPowerKw ?? this.lowPowerKw,
      );
}

class NotificationSettingsNotifier
    extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings());

  void toggle(bool v) => state = state.copyWith(enabled: v);
  void setStaleMinutes(int m) => state = state.copyWith(staleMinutes: m);
  void setLowPower(double kw) => state = state.copyWith(lowPowerKw: kw);
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  (_) => NotificationSettingsNotifier(),
);

