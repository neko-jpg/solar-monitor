import 'dart:convert';

class Reading {
  final DateTime timestamp;
  final double power;

  Reading({required this.timestamp, required this.power});

  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      timestamp: DateTime.parse(json['timestamp'] as String),
      power: (json['power'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'power': power,
      };
}
