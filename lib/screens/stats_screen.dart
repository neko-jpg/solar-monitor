import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/plants_provider.dart';
import '../models/plant.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plants = ref.watch(plantsProvider);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stats'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Total'),
            Tab(text: 'Comparison'),
            Tab(text: 'Export'),
          ]),
        ),
        body: TabBarView(
          children: [
            _TotalGenerationTab(plants: plants),
            _ComparisonTab(plants: plants),
            _ExportTab(plants: plants),
          ],
        ),
      ),
    );
  }
}

class _TotalGenerationTab extends StatelessWidget {
  const _TotalGenerationTab({required this.plants});
  final List<Plant> plants;

  @override
  Widget build(BuildContext context) {
    if (plants.isEmpty) return const Center(child: Text('No data'));
    final days = plants.first.readings.length;
    final totals = List<double>.filled(days, 0);
    for (var p in plants) {
      for (var i = 0; i < p.readings.length; i++) {
        totals[i] += p.readings[i].power;
      }
    }
    final spots = [
      for (int i = 0; i < totals.length; i++)
        FlSpot(i.toDouble(), totals[i])
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
            )
          ],
        ),
      ),
    );
  }
}

class _ComparisonTab extends StatelessWidget {
  const _ComparisonTab({required this.plants});
  final List<Plant> plants;

  @override
  Widget build(BuildContext context) {
    final bars = [
      for (int i = 0; i < plants.length; i++)
        BarChartGroupData(x: i, barRods: [
          BarChartRodData(toY: plants[i].readings.fold(0.0, (a, b) => a + b.power))
        ])
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
                final index = v.toInt();
                if (index < 0 || index >= plants.length) return const SizedBox();
                return Text(plants[index].name);
              }),
            ),
          ),
          barGroups: bars,
        ),
      ),
    );
  }
}

class _ExportTab extends StatelessWidget {
  const _ExportTab({required this.plants});
  final List<Plant> plants;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exported (mock)')),
          );
        },
        child: const Text('Export CSV'),
      ),
    );
  }
}
