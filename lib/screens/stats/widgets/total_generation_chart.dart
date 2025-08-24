import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/reading_provider.dart';
import '../../../utils/aggregation.dart';

class TotalGenerationChart extends ConsumerWidget {
  const TotalGenerationChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allReadingsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Center(child: Text('取得失敗')),
      data: (byPlant) {
        final daily = aggregateDaily(byPlant); // List<MapEntry<DateTime,double>>
        if (daily.isEmpty) {
          return const Center(child: Text('データがありません'));
        }

        final spots = <FlSpot>[];
        for (var i = 0; i < daily.length; i++) {
          spots.add(FlSpot(i.toDouble(), daily[i].value));
        }

        int labelStep() {
          if (daily.length <= 7) return 1;
          if (daily.length <= 14) return 2;
          if (daily.length <= 30) return 3;
          return 5;
        }

        return LineChart(
          LineChartData(
            minY: 0,
            lineTouchData: const LineTouchData(enabled: true),
            gridData: const FlGridData(show: true),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                preventCurveOverShooting: true,
                spots: spots,
                dotData: const FlDotData(show: false),
              ),
            ],
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 42),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, meta) {
                    final idx = v.toInt();
                    if (idx < 0 || idx >= daily.length) {
                      return const SizedBox.shrink();
                    }
                    if (idx % labelStep() != 0) {
                      return const SizedBox.shrink();
                    }
                    final d = daily[idx].key;
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text('${d.month}/${d.day}',
                          style: const TextStyle(fontSize: 11)),
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
}

