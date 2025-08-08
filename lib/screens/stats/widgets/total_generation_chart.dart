import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/plant.dart';

class TotalGenerationChart extends StatelessWidget {
  final List<Plant> plants;
  const TotalGenerationChart({super.key, required this.plants});

  @override
  Widget build(BuildContext context) {
    if (plants.isEmpty) {
      return const SizedBox(height: 220, child: Center(child: Text('No data')));
    }

    // 各時点の合計を作成（全プラントの同じインデックスを足す）
    final len = plants.first.readings.length;
    final totals = List<double>.filled(len, 0);
    for (final p in plants) {
      for (var i = 0; i < len && i < p.readings.length; i++) {
        totals[i] += p.readings[i].power;
      }
    }

    final spots = [
      for (var i = 0; i < totals.length; i++) FlSpot(i.toDouble(), totals[i]),
    ];

    return SizedBox(
      height: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Generation',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: _niceStep(totals),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    spots: spots,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.28),
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.04),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _niceStep(List<double> values) {
    final max = values.fold<double>(0, (m, v) => v > m ? v : m);
    if (max <= 0) return 20;
    final rough = max / 5;
    // 5の倍数に丸め
    return (rough / 10).ceil() * 10.0;
  }
}
