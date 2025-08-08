import '../providers/plants_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/reading.dart';

enum Range { daily, weekly, monthly }

class PlantDetailScreen extends ConsumerStatefulWidget {
  const PlantDetailScreen({super.key, required this.plantId});
  final String plantId;

  @override
  ConsumerState<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends ConsumerState<PlantDetailScreen> {
  Range range = Range.daily;

  @override
  Widget build(BuildContext context) {
    final plant = ref
        .watch(plantsProvider)
        .firstWhere((p) => p.id == widget.plantId);
    final readings = _filteredReadings(plant.readings);
    final spots = [
      for (int i = 0; i < readings.length; i++)
        FlSpot(i.toDouble(), readings[i].power),
    ];
    final maxPower =
        readings.isNotEmpty
            ? readings.map((e) => e.power).reduce((a, b) => a > b ? a : b)
            : 0.0;
    final avgPower =
        readings.isNotEmpty
            ? readings.map((e) => e.power).reduce((a, b) => a + b) /
                readings.length
            : 0.0;

    return Scaffold(
      appBar: AppBar(title: Text(plant.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: Range.values.map((r) => r == range).toList(),
              onPressed: (i) => setState(() => range = Range.values[i]),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Daily'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Weekly'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Monthly'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: plant.themeColor,
                      spots: spots,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Max: ${maxPower.toStringAsFixed(1)} kW'),
            Text('Average: ${avgPower.toStringAsFixed(1)} kW'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final uri = Uri.parse(plant.url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              child: const Text('Go to site'),
            ),
          ],
        ),
      ),
    );
  }

  List<Reading> _filteredReadings(List<Reading> all) {
    // For now we return original readings for all ranges.
    return all;
  }
}
