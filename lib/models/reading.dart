class Reading {
  final DateTime ts; // 計測時刻
  final double kw; // 発電量
  final double? dayMax; // その時点での当日最高

  Reading({required this.ts, required this.kw, this.dayMax});
}
