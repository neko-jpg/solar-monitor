// lib/models/reading.dart
import 'package:equatable/equatable.dart';

/// 1点の計測値（時刻＋出力[kW]）
class Reading extends Equatable {
  final DateTime timestamp;
  final double power;

  const Reading({required this.timestamp, required this.power});

  Reading copyWith({DateTime? timestamp, double? power}) => Reading(
    timestamp: timestamp ?? this.timestamp,
    power: power ?? this.power,
  );

  /// JSON → Reading
  /// timestamp: ISO8601 文字列 or int(ミリ秒) の両対応
  factory Reading.fromJson(Map<String, dynamic> j) {
    final ts = j['timestamp'];
    final DateTime t = switch (ts) {
      int ms => DateTime.fromMillisecondsSinceEpoch(ms),
      String s => DateTime.parse(s),
      _ => throw ArgumentError('Invalid timestamp: $ts'),
    };
    final p = (j['power'] as num).toDouble();
    return Reading(timestamp: t, power: p);
  }

  /// Reading → JSON（ISO8601）
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'power': power,
  };

  /// 並べ替え用：時刻昇順（古い→新しい）
  static int compareByTimeAsc(Reading a, Reading b) =>
      a.timestamp.compareTo(b.timestamp);

  @override
  List<Object?> get props => [timestamp, power];
}
