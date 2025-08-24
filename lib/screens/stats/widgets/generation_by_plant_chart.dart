import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/reading.dart';
import '../../../providers/plants_provider.dart';
import '../../../providers/reading_provider.dart';

class GenerationByPlantChart extends ConsumerWidget {
  const GenerationByPlantChart({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plants = ref.watch(plantsProvider);
    final async = ref.watch(allReadingsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('取得失敗: $e')),
      data: (byPlant) {
        final entries = plants.map((p) => (p, _totalKwh(byPlant[p.id] ?? const []))).toList();
        final bars = <BarChartGroupData>[];
        for (var i = 0; i < entries.length; i++) {
          final (plant, kwh) = entries[i];
          bars.add(BarChartGroupData(x: i, barRods: [
            BarChartRodData(toY: kwh, width: 16, color: Color(plant.color),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
            ),
          ]));
        }
        return SizedBox(
          height: 260,
          child: BarChart(BarChartData(
            barGroups: bars,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 42)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
                final idx = v.toInt();
                if (idx < 0 || idx >= entries.length) return const SizedBox.shrink();
                final name = entries[idx].$1.name;
                return Padding(padding: const EdgeInsets.only(top: 6), child: Text(name.length>6? '${name.substring(0,6)}…': name, style: const TextStyle(fontSize: 11)));
              })),
            ),
          )),
        );
      },
    );
  }

  double _totalKwh(List<Reading> list) {
    if (list.isEmpty) return 0;
    final s = [...list]..sort((a,b)=>a.timestamp.compareTo(b.timestamp));
    final hasEnergy = s.any((r) => r.energyKwh != null);
    if (hasEnergy) {
      double minV = double.infinity, maxV = 0;
      for (final r in s) { final e = r.energyKwh; if (e==null) continue; if (e<minV) minV=e; if (e>maxV) maxV=e; }
      return (maxV - minV).clamp(0, double.infinity);
    }
    double total=0; for (var i=1;i<s.length;i++){final a=s[i-1], b=s[i]; final h=b.timestamp.difference(a.timestamp).inMinutes/60.0; if(h>0){ total+=((a.power+b.power)/2.0)*h; }}
    return total;
  }
}
