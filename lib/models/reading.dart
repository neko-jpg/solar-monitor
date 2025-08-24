class Reading {
  final DateTime timestamp; // 旧 at→timestamp
  final double power;       // 旧 powerKw→power（kW）
  final double? energyKwh;  // 積算（任意）
  const Reading({required this.timestamp, required this.power, this.energyKwh});
}
