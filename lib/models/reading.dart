class Reading {
  final DateTime timestamp;
  final double power;
  final double? energyKwh; // Cumulative energy, optional

  const Reading({
    required this.timestamp,
    required this.power,
    this.energyKwh,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'power': power,
        'energyKwh': energyKwh,
      };

  static Reading fromJson(Map<String, dynamic> json) => Reading(
        timestamp: DateTime.parse(json['timestamp'] as String),
        power: (json['power'] as num).toDouble(),
        energyKwh: (json['energyKwh'] as num?)?.toDouble(),
      );
}
