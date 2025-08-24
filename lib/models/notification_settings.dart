class NotificationSettings {
  final bool enabled;
  final int staleMinutes; // Threshold for no-update warnings
  final double lowPowerKw; // Threshold for low power

  const NotificationSettings({
    this.enabled = true,
    this.staleMinutes = 30,
    this.lowPowerKw = 0.5,
  });

  NotificationSettings copyWith({
    bool? enabled,
    int? staleMinutes,
    double? lowPowerKw,
  }) =>
      NotificationSettings(
        enabled: enabled ?? this.enabled,
        staleMinutes: staleMinutes ?? this.staleMinutes,
        lowPowerKw: lowPowerKw ?? this.lowPowerKw,
      );
}
