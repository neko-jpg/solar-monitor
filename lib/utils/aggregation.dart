import '../models/reading.dart';

class TimePoint {
  final DateTime t;
  final double v;
  const TimePoint(this.t, this.v);
}

List<Reading> _sorted(List<Reading> rs) {
  final list = List<Reading>.from(rs);
  list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  return list;
}

List<TimePoint> _downsample(List<TimePoint> points, {int maxPoints = 120}) {
  if (points.length <= maxPoints) return points;
  final ratio = points.length / maxPoints;
  final out = <TimePoint>[];
  double acc = 0;
  var bucket = <TimePoint>[];
  for (var i = 0; i < points.length; i++) {
    bucket.add(points[i]);
    acc += 1;
    if (acc >= ratio) {
      final v =
          bucket.map((e) => e.v).fold<double>(0, (a, b) => a + b) /
          bucket.length;
      out.add(TimePoint(bucket.last.t, v));
      bucket.clear();
      acc = 0;
    }
  }
  if (bucket.isNotEmpty) {
    final v =
        bucket.map((e) => e.v).fold<double>(0, (a, b) => a + b) / bucket.length;
    out.add(TimePoint(bucket.last.t, v));
  }
  return out;
}

List<TimePoint> aggregateDaily(List<Reading> raw) {
  final rs = _sorted(raw);
  if (rs.isEmpty) return const [];
  final Map<DateTime, List<double>> bins = {};
  for (final r in rs) {
    final key = DateTime(
      r.timestamp.year,
      r.timestamp.month,
      r.timestamp.day,
      r.timestamp.hour,
    );
    bins.putIfAbsent(key, () => <double>[]).add(r.power);
  }
  final out =
      bins.entries.map((e) {
          final avg = e.value.fold<double>(0, (a, b) => a + b) / e.value.length;
          return TimePoint(e.key, avg);
        }).toList()
        ..sort((a, b) => a.t.compareTo(b.t));
  return _downsample(out);
}

List<TimePoint> aggregateWeekly(List<Reading> raw) {
  final rs = _sorted(raw);
  if (rs.isEmpty) return const [];
  final Map<DateTime, double> dailyPeak = {};
  for (final r in rs) {
    final key = DateTime(r.timestamp.year, r.timestamp.month, r.timestamp.day);
    final prev = dailyPeak[key] ?? 0.0;
    if (r.power > prev) dailyPeak[key] = r.power;
  }
  final out =
      dailyPeak.entries.map((e) => TimePoint(e.key, e.value)).toList()
        ..sort((a, b) => a.t.compareTo(b.t));
  return _downsample(out, maxPoints: 90);
}

List<TimePoint> aggregateMonthly(List<Reading> raw) {
  final rs = _sorted(raw);
  if (rs.isEmpty) return const [];
  final Map<DateTime, List<double>> byDay = {};
  for (final r in rs) {
    final key = DateTime(r.timestamp.year, r.timestamp.month, r.timestamp.day);
    byDay.putIfAbsent(key, () => <double>[]).add(r.power);
  }
  final out =
      byDay.entries.map((e) {
          final avg = e.value.fold<double>(0, (a, b) => a + b) / e.value.length;
          return TimePoint(e.key, avg);
        }).toList()
        ..sort((a, b) => a.t.compareTo(b.t));
  return _downsample(out, maxPoints: 180);
}

class SeriesStats {
  final double max;
  final double avg;
  const SeriesStats(this.max, this.avg);
}

SeriesStats calcStats(List<TimePoint> pts) {
  if (pts.isEmpty) return const SeriesStats(0, 0);
  final maxV = pts.map((e) => e.v).fold<double>(0, (a, b) => a > b ? a : b);
  final avgV =
      pts.map((e) => e.v).fold<double>(0, (a, b) => a + b) / pts.length;
  return SeriesStats(maxV, avgV);
}
