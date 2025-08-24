import '../models/reading.dart';

/// energyKwh があれば増分合計、無ければ power を台形則で積分
double totalEnergyKwh(List<Reading> list) {
  if (list.isEmpty) return 0;
  final s = [...list]..sort((a,b)=>a.timestamp.compareTo(b.timestamp));
  final hasEnergy = s.any((r) => r.energyKwh != null);
  if (hasEnergy) {
    double minV = double.infinity, maxV = 0;
    for (final r in s) { final e = r.energyKwh; if (e==null) continue; if (e<minV) minV=e; if (e>maxV) maxV=e; }
    return (maxV - minV).clamp(0, double.infinity);
  }
  double kwh=0; for (var i=1;i<s.length;i++){final a=s[i-1], b=s[i];final h=b.timestamp.difference(a.timestamp).inMinutes/60.0; if(h>0){kwh+=((a.power+b.power)/2.0)*h;}}
  return kwh;
}

/// 日単位に丸めた合計kWh（全プラントの readings を結合して集計）
/// 返り値：昇順の (日付, kWh)
List<MapEntry<DateTime,double>> aggregateDaily(Map<String, List<Reading>> byPlant) {
  final buckets = <DateTime,double>{};
  void addKwh(DateTime day, double v) {
    final cur = buckets[day] ?? 0.0; buckets[day] = cur + v;
  }
  // プラントごとに 1 日の kWh を算出し、日付キーに加算
  byPlant.forEach((_, list) {
    if (list.isEmpty) return;
    final s = [...list]..sort((a,b)=>a.timestamp.compareTo(b.timestamp));
    // 1日単位バケット
    DateTime key(DateTime t)=> DateTime(t.year, t.month, t.day);

    // energy があれば 1 日の (max - min)
    final hasEnergy = s.any((r) => r.energyKwh != null);
    if (hasEnergy) {
      var i = 0;
      while (i < s.length) {
        final d = key(s[i].timestamp);
        double minV = double.infinity, maxV = 0;
        while (i < s.length && key(s[i].timestamp) == d) {
          final e = s[i].energyKwh; if (e != null) { if (e < minV) minV = e; if (e > maxV) maxV = e; }
          i++;
        }
        final kwh = (maxV - minV).clamp(0.0, double.infinity);
        if (kwh > 0) addKwh(d, kwh);
      }
      return;
    }
    // power の場合は台形則で 1 日ごとに積分
    var i = 1;
    while (i < s.length) {
      final a = s[i-1], b = s[i];
      final dayA = DateTime(a.timestamp.year, a.timestamp.month, a.timestamp.day);
      final dayB = DateTime(b.timestamp.year, b.timestamp.month, b.timestamp.day);
      final h = b.timestamp.difference(a.timestamp).inMinutes / 60.0;
      if (h > 0) {
        final kwh = ((a.power + b.power) / 2.0) * h;
        // 区間が日をまたぐ場合は簡略に「終端の所属日に加算」
        addKwh(dayB == dayA ? dayA : dayB, kwh);
      }
      i++;
    }
  });
  final out = buckets.entries.toList()
    ..sort((a,b)=>a.key.compareTo(b.key));
  return out;
}
