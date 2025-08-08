import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/reading.dart';

class PlantDetailChart extends StatelessWidget {
  final List<Reading> readings;
  final bool isMonthly;

  const PlantDetailChart({
    super.key,
    required this.readings,
    required this.isMonthly,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // データを日別・月別に変換
    final data = _aggregateData();

    return LineChart(
      LineChartData(
        backgroundColor: Colors.white,
        gridData: FlGridData(show: true, horizontalInterval: 10),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();
                return Text(
                  data[index].label,
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < data.length; i++)
                FlSpot(i.toDouble(), data[i].value),
            ],
            isCurved: true,
            barWidth: 2,
            color: Colors.blue,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.2),
            ),
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  List<_ChartPoint> _aggregateData() {
    if (!isMonthly) {
      // 日別（最新30件）
      return readings
          .takeLast(30) // 拡張関数っぽいけど下で作る
          .map(
            (r) => _ChartPoint(
              label: '${r.timestamp.month}/${r.timestamp.day}',
              value: r.power,
            ),
          )
          .toList();
    } else {
      // 月別集計
      final Map<String, double> monthly = {};
      for (final r in readings) {
        final key = '${r.timestamp.year}/${r.timestamp.month}';
        monthly[key] = (monthly[key] ?? 0) + r.power;
      }
      return monthly.entries
          .map((e) => _ChartPoint(label: e.key, value: e.value))
          .toList();
    }
  }
}

class _ChartPoint {
  final String label;
  final double value;
  _ChartPoint({required this.label, required this.value});
}

// List<Reading> の末尾n件取得用
extension TakeLastExtension<E> on List<E> {
  Iterable<E> takeLast(int n) => length <= n ? this : sublist(length - n);
}
