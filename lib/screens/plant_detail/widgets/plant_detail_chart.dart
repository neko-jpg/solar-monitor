import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/reading.dart';

class PlantDetailChart extends StatelessWidget {
  final List<Reading> readings;
  final bool isMonthly;

  const PlantDetailChart({
    super.key,
    required this.readings,
    this.isMonthly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < readings.length; i++) {
      spots.add(FlSpot(i.toDouble(), readings[i].power));
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 2,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
