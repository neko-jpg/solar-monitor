import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/plant.dart';
import '../../providers/plants_provider.dart';
import '../../providers/reading_provider.dart';
import 'widgets/section_header.dart';
import 'widgets/warning_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plants = ref.watch(plantsProvider);

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
      body: plants.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No plants have been added yet.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.goNamed('add_plant'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add a Plant'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(plantsProvider);
                // Also invalidate the readings for all plants
                for (final plant in plants) {
                  ref.invalidate(readingsProvider(plant));
                }
                return await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // The new Warning Card logic
                  _DashboardAlerts(plants: plants),
                  const SectionHeader('My Plants'),
                  const SizedBox(height: 8),
                  ...plants.map((p) => _PlantCard(plant: p)),
                ],
              ),
            ),
    );
  }
}

class _DashboardAlerts extends ConsumerWidget {
  const _DashboardAlerts({required this.plants});
  final List<Plant> plants;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> errorPlants = [];
    for (final plant in plants) {
      // Watch each provider's state. hasError is the correct property.
      final readingAsync = ref.watch(latestReadingProvider(plant));
      if (readingAsync.hasError) {
        errorPlants.add(plant.name);
      }
    }

    if (errorPlants.isEmpty) {
      // If no errors, return an empty container.
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: WarningCard(
        title: 'Connection Issues Detected',
        message: 'We could not fetch the latest data for the following plants. Please check their configuration or network status.',
        problematicItems: errorPlants,
        onRetry: () {
          // Invalidate the providers for the plants that have errors.
          for (final plant in plants) {
            if (errorPlants.contains(plant.name)) {
              ref.invalidate(readingsProvider(plant));
            }
          }
        },
      ),
    );
  }
}


class _PlantCard extends ConsumerWidget {
  const _PlantCard({required this.plant});
  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestReadingAsync = ref.watch(latestReadingProvider(plant));

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
                IconData(
                  int.tryParse(plant.icon) ?? Icons.wb_sunny.codePoint,
                  fontFamily: 'MaterialIcons',
                ),
                color: plant.themeColor,
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
                    latestReadingAsync.when(
                      data: (reading) {
                        if (reading == null) {
                          return const Text(
                            'No data available.',
                            style: TextStyle(color: Colors.orange),
                          );
                        }
                        final formattedDate = DateFormat('yyyy/MM/dd HH:mm').format(reading.timestamp);
                        return Text(
                          '${reading.power.toStringAsFixed(2)} kW\n$formattedDate',
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      },
                      loading: () => const Row(
                        children: [
                          SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text('Loading...'),
                        ],
                      ),
                      error: (err, stack) => Row(
                        children: [
                          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Failed to load',
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                        ],
                      ),
                    ),
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
