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
      error: (e, _) => Center(child: Text('Failed to load chart: $e')),
      data: (byPlant) {
        // plantId -> total kWh
        final totals = <String, double>{};
        for (final p in plants) {
          final list = (byPlant[p.id] ?? const <Reading>[]);
          totals[p.id] = _totalEnergyKwh(list);
        }

        final entries = plants.map((p) => (p, totals[p.id] ?? 0.0)).toList();
        final groups = <BarChartGroupData>[];
        for (var i = 0; i < entries.length; i++) {
          final (plant, kwh) = entries[i];
          groups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: kwh,
                  width: 16,
                  color: Color(plant.color),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4), topRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
          );
        }

        return BarChart(
          BarChartData(
            barGroups: groups,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= entries.length) return const SizedBox.shrink();
                    final name = entries[idx].$1.name;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        name.length > 6 ? '${name.substring(0, 6)}…' : name,
                        style: const TextStyle(fontSize: 11),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _totalEnergyKwh(List<Reading> list) {
    if (list.isEmpty) return 0;
    final hasEnergy = list.any((r) => r.energyKwh != null);

    final sorted = [...list]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (hasEnergy) {
      double sum = 0;
      double? prev;
      for (final r in sorted) {
        final e = r.energyKwh;
        if (e == null) continue;
        if (prev != null) {
          final delta = e - prev;
          if (delta > 0) sum += delta;
        }
        prev = e;
      }
      if (sum == 0 && prev != null) {
        final minVal = sorted.map((r) => r.energyKwh ?? double.maxFinite).reduce((a, b) => a < b ? a : b);
        final maxVal = sorted.map((r) => r.energyKwh ?? double.minPositive).reduce((a, b) => a > b ? a : b);
        if (minVal != double.maxFinite) {
            sum = (maxVal - minVal).clamp(0, double.infinity);
        }
      }
      return sum;
    } else {
      // Trapezoidal rule: kW * hours -> kWh
      double total = 0;
      for (var i = 1; i < sorted.length; i++) {
        final a = sorted[i - 1];
        final b = sorted[i];
        final hours = b.timestamp.difference(a.timestamp).inMinutes / 60.0;
        if (hours <= 0) continue;
        final avgKw = (a.power + b.power) / 2.0;
        total += avgKw * hours;
      }
      return total;
    }
  }
}
