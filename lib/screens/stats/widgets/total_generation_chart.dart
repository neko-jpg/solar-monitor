import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/reading.dart';
import '../../../utils/aggregation.dart';

class TotalGenerationChart extends StatelessWidget {
  final List<Reading> readings;
  const TotalGenerationChart({super.key, required this.readings});

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const Center(child: Text('No data to display.'));
    }

    // Aggregate the combined readings into daily time points
    final dailyData = aggregateDaily(readings);
    if (dailyData.isEmpty) {
      return const Center(child: Text('Not enough data to display a chart.'));
    }

    final spots = dailyData.map((p) => FlSpot(p.t.millisecondsSinceEpoch.toDouble(), p.v)).toList();
    final theme = Theme.of(context);

    return LineChart(
      LineChartData(
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: theme.dividerColor.withOpacity(0.1), strokeWidth: 1);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: theme.dividerColor.withOpacity(0.1), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final timestamp = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(DateFormat.Md().format(timestamp), style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                if (value == meta.max || value == meta.min) return Container();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text('${value.toStringAsFixed(1)}kW', style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: theme.primaryColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
