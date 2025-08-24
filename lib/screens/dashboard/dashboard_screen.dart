import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/plant.dart';
import '../../models/reading.dart';
import '../../providers/plants_provider.dart';
import '../../providers/reading_provider.dart';
import '../../providers/notification_settings_provider.dart';
import '../../widgets/alert_strip.dart';
import '../../widgets/skeleton_tile.dart';
import 'widgets/section_header.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plants = ref.watch(plantsProvider);
    final alerts = _buildAlerts(ref, plants);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.goNamed('add_plant'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.goNamed('notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(plantsProvider);
          ref.invalidate(allReadingsProvider);
          for (final plant in plants) {
            ref.invalidate(latestReadingProvider(plant));
          }
          return await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (alerts.isNotEmpty) ...[
              const SectionHeader('Alerts'),
              const SizedBox(height: 8),
              ...alerts,
            ],
            const SectionHeader('My Plants'),
            const SizedBox(height: 8),
            if (plants.isEmpty)
              const Center(child: Text('No plants have been added yet.'))
            else
              ...plants.map((p) {
                final asyncReading = ref.watch(latestReadingProvider(p));
                return asyncReading.when(
                  loading: () => const SkeletonTile(),
                  error: (e, _) => AlertStrip(
                    message: 'Failed to get data for ${p.name}: $e',
                    color: Colors.orange,
                    onRetry: () => ref.invalidate(latestReadingProvider(p)),
                  ),
                  data: (reading) => _PlantCard(plant: p, reading: reading),
                );
              }),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAlerts(WidgetRef ref, List<Plant> plants) {
    final settings = ref.watch(notificationSettingsProvider);
    if (!settings.enabled) return [];

    final alerts = <Widget>[];

    for (final plant in plants) {
      final readingAsync = ref.watch(latestReadingProvider(plant));
      if (readingAsync.hasValue && readingAsync.value != null) {
        final reading = readingAsync.value!;
        final now = DateTime.now();
        if (now.difference(reading.timestamp).inMinutes > settings.staleMinutes) {
          alerts.add(AlertStrip(
            message: '${plant.name} has not reported data recently.',
            color: Colors.orange,
          ));
        }
        if (reading.power < settings.lowPowerKw) {
          alerts.add(AlertStrip(
            message: '${plant.name} is reporting low power output.',
            color: Colors.yellow.shade800,
          ));
        }
      }
    }
    return alerts;
  }
}

class _PlantCard extends StatelessWidget {
  const _PlantCard({required this.plant, this.reading});
  final Plant plant;
  final Reading? reading;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go('/plant/${plant.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.solar_power,
                color: Color(plant.color),
                size: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    if (reading == null)
                      const Text(
                        'No data available.',
                        style: TextStyle(color: Colors.orange),
                      )
                    else ...[
                      Text(
                        '${reading!.power.toStringAsFixed(2)} kW',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('yyyy/MM/dd HH:mm').format(reading!.timestamp),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ]
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
