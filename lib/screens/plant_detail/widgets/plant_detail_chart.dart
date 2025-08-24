import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/reading.dart';

class PlantDetailChart extends StatelessWidget {
  final List<Reading> readings;
  final bool isMonthly; // This can be used later to adjust the time scale

  const PlantDetailChart({
    super.key,
    required this.readings,
    this.isMonthly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const Center(child: Text('No data to display.'));
    }

    final spots = readings.map((r) {
      return FlSpot(r.timestamp.millisecondsSinceEpoch.toDouble(), r.power);
    }).toList();

    final theme = Theme.of(context);

    return LineChart(
      LineChartData(
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: theme.dividerColor.withAlpha((255 * 0.1).round()), strokeWidth: 1);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: theme.dividerColor.withAlpha((255 * 0.1).round()), strokeWidth: 1);
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
              interval: _getInterval(),
              getTitlesWidget: _bottomTitleWidgets,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: _leftTitleWidgets,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: theme.dividerColor.withAlpha((255 * 0.2).round())),
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
              color: theme.primaryColor.withAlpha((255 * 0.2).round()),
            ),
          ),
        ],
      ),
    );
  }

  double _getInterval() {
    if (readings.isEmpty) return 1;
    final duration = readings.last.timestamp.difference(readings.first.timestamp);
    // Simple interval logic, can be improved
    if (duration.inDays > 30) {
      return const Duration(days: 7).inMilliseconds.toDouble(); // Weekly
    } else if (duration.inDays > 1) {
      return const Duration(days: 1).inMilliseconds.toDouble(); // Daily
    } else {
      return const Duration(hours: 4).inMilliseconds.toDouble(); // 4-hourly
    }
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final timestamp = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    String text;
    final duration = readings.last.timestamp.difference(readings.first.timestamp);

    if (duration.inDays > 2) {
      text = DateFormat.Md().format(timestamp); // e.g., 7/15
    } else {
      text = DateFormat.Hm().format(timestamp); // e.g., 14:30
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: Text(text, style: const TextStyle(fontSize: 10)),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    if (value == meta.max || value == meta.min) {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: Text('${value.toStringAsFixed(1)}kW', style: const TextStyle(fontSize: 10)),
    );
  }
}
