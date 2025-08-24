import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSettings {
  final bool enabled; final int staleMinutes; final double lowPowerKw;
  const NotificationSettings({this.enabled=true, this.staleMinutes=30, this.lowPowerKw=0.5});
  NotificationSettings copyWith({bool? enabled,int? staleMinutes,double? lowPowerKw})
    => NotificationSettings(enabled: enabled??this.enabled, staleMinutes: staleMinutes??this.staleMinutes, lowPowerKw: lowPowerKw??this.lowPowerKw);
}
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier(): super(const NotificationSettings());
  void toggle(bool v)=> state = state.copyWith(enabled: v);
  void setStale(int m)=> state = state.copyWith(staleMinutes: m);
  void setLow(double kw)=> state = state.copyWith(lowPowerKw: kw);
  // ★ 互換 alias（既存画面が setStaleMinutes / setLowPower を呼ぶため）
  void setStaleMinutes(int m) => setStale(m);
  void setLowPower(double kw) => setLow(kw);
}
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((_)=>NotificationSettingsNotifier());
