import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/providers/plants_provider.dart';
import '/utils/aggregation.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plants = ref.watch(plantsProvider); // List<Plant>
    if (plants.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No plant data available')),
      );
    }

    // 全プラントの readings を結合
    final allReadings = plants.expand((p) => p.readings).toList();

    final daily = aggregateDaily(allReadings);
    final weekly = aggregateWeekly(allReadings);
    final monthly = aggregateMonthly(allReadings);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Daily', daily),
          _buildSection('Weekly', weekly),
          _buildSection('Monthly', monthly),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<TimePoint> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (data.isEmpty)
              const Text('No data')
            else
              Column(
                children:
                    data
                        .map(
                          (e) => Text('${e.t}: ${e.v.toStringAsFixed(2)} kW'),
                        )
                        .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
