import '../models/reading.dart';

/// energyKwh があれば (max - min)、無ければ power を台形則で積分
double totalEnergyKwh(List<Reading> list) {
  if (list.isEmpty) return 0.0;
  final s = [...list]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  final hasEnergy = s.any((r) => r.energyKwh != null);
  if (hasEnergy) {
    double minV = double.infinity, maxV = -double.infinity;
    for (final r in s) {
      final e = r.energyKwh;
      if (e == null) continue;
      if (e < minV) minV = e;
      if (e > maxV) maxV = e;
    }
    final diff = maxV - minV;
    return diff.isFinite && diff > 0 ? diff : 0.0;
  }

  // 台形則
  double kwh = 0.0;
  for (var i = 1; i < s.length; i++) {
    final a = s[i - 1], b = s[i];
    final h = b.timestamp.difference(a.timestamp).inMinutes / 60.0;
    if (h > 0) {
      kwh += ((a.power + b.power) / 2.0) * h;
    }
  }
  return kwh;
}

/// 全プラント readings を日別合計 (kWh) に集約して、昇順のリストで返す。
/// 戻り値は `[MapEntry<DateTime, double>]` の配列を想定（チャート入力用）。
List<MapEntry<DateTime, double>> aggregateDaily(
    Map<String, List<Reading>> byPlant) {
  final buckets = <DateTime, double>{};

  void addKwh(DateTime day, double v) {
    buckets.update(day, (prev) => prev + v, ifAbsent: () => v);
  }

  byPlant.forEach((_, list) {
    if (list.isEmpty) return;
    final s = [...list]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final hasEnergy = s.any((r) => r.energyKwh != null);
    if (hasEnergy) {
      // energyKwh がある場合、日単位で (max - min)
      DateTime curDay(DateTime t) => DateTime(t.year, t.month, t.day);
      double? dayMin, dayMax;
      DateTime? dayKey;

      void flush() {
        if (dayMin != null && dayMax != null && dayKey != null) {
          final diff = dayMax! - dayMin!;
          if (diff > 0) addKwh(dayKey!, diff);
        }
        dayMin = dayMax = null;
        dayKey = null;
      }

      for (final r in s) {
        final key = curDay(r.timestamp);
        if (dayKey == null) dayKey = key;
        if (key != dayKey) {
          flush();
          dayKey = key;
        }
        final e = r.energyKwh;
        if (e != null) {
          dayMin = (dayMin == null) ? e : (e < dayMin! ? e : dayMin);
          dayMax = (dayMax == null) ? e : (e > dayMax! ? e : dayMax);
        }
      }
      flush();
    } else {
      // energyKwh 無し → 台形則で隣接区間をその「終端側の所属日」に加算
      for (var i = 1; i < s.length; i++) {
        final a = s[i - 1], b = s[i];
        final h = b.timestamp.difference(a.timestamp).inMinutes / 60.0;
        if (h <= 0) continue;
        final kwh = ((a.power + b.power) / 2.0) * h;
        final dayB = DateTime(b.timestamp.year, b.timestamp.month, b.timestamp.day);
        addKwh(dayB, kwh);
      }
    }
  });

  final out = buckets.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return out;
}

