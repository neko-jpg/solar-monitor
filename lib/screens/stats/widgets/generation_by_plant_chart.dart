import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/plant.dart';

class GenerationByPlantChart extends StatelessWidget {
  final List<Plant> plants;
  final bool compact;
  const GenerationByPlantChart({
    super.key,
    required this.plants,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final groups = <BarChartGroupData>[];
    for (int i = 0; i < plants.length; i++) {
      final total = plants[i].readings.fold<double>(0, (a, b) => a + b.power);
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: total,
              width: compact ? 14 : 18,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: compact ? 220 : 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generation by Plant',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: groups,
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
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
                        final i = v.toInt();
                        if (i < 0 || i >= plants.length)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            plants[i].name,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
