import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

// TimeOfDayをJSON変換するためのヘルパー
class TimeOfDayConverter {
  static String toJson(TimeOfDay tod) => '${tod.hour}:${tod.minute}';
  static TimeOfDay fromJson(String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

class NotificationSettings extends Equatable {
  final bool dailySummary;
  final List<TimeOfDay> times;
  final bool abnormalAlert;
  final double thresholdKw;
  final bool maxUpdate;

  const NotificationSettings({
    this.dailySummary = false,
    this.times = const [],
    this.abnormalAlert = false,
    this.thresholdKw = 0,
    this.maxUpdate = false,
  });

  NotificationSettings copyWith({
    bool? dailySummary,
    List<TimeOfDay>? times,
    bool? abnormalAlert,
    double? thresholdKw,
    bool? maxUpdate,
  }) {
    return NotificationSettings(
      dailySummary: dailySummary ?? this.dailySummary,
      times: times ?? this.times,
      abnormalAlert: abnormalAlert ?? this.abnormalAlert,
      thresholdKw: thresholdKw ?? this.thresholdKw,
      maxUpdate: maxUpdate ?? this.maxUpdate,
    );
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      dailySummary: json['dailySummary'] as bool? ?? false,
      times:
          (json['times'] as List<dynamic>? ?? [])
              .map((e) => TimeOfDayConverter.fromJson(e as String))
              .toList(),
      abnormalAlert: json['abnormalAlert'] as bool? ?? false,
      thresholdKw: (json['thresholdKw'] as num?)?.toDouble() ?? 0,
      maxUpdate: json['maxUpdate'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'dailySummary': dailySummary,
    'times': times.map(TimeOfDayConverter.toJson).toList(),
    'abnormalAlert': abnormalAlert,
    'thresholdKw': thresholdKw,
    'maxUpdate': maxUpdate,
  };

  @override
  List<Object?> get props => [
    dailySummary,
    times,
    abnormalAlert,
    thresholdKw,
    maxUpdate,
  ];
}
