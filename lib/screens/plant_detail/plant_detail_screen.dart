import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/plant.dart';
import '../../providers/plants_provider.dart';
import '../../providers/reading_provider.dart';
import 'widgets/plant_detail_chart.dart';
import 'widgets/history_list.dart';

class PlantDetailScreen extends ConsumerWidget {
  final String plantId;
  const PlantDetailScreen({super.key, required this.plantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Correctly watch the provider and find the plant
    final plants = ref.watch(plantsProvider);
    Plant? plant;
    for (final p in plants) {
      if (p.id == plantId) {
        plant = p;
        break;
      }
    }

    if (plant == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Plant not found or has been deleted.'))
      );
    }

    // Create a non-nullable reference to the plant.
    final finalPlant = plant;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(finalPlant.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                context.goNamed('edit_plant', pathParameters: {'plantId': finalPlant.id});
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref, finalPlant),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.show_chart), text: 'Chart'),
              Tab(icon: Icon(Icons.history), text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ChartTabView(plant: finalPlant),
            _HistoryTabView(plant: finalPlant),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Plant plant) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Plant'),
        content: Text('Are you sure you want to delete "${plant.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(plantsProvider.notifier).remove(plant.id);
              // Pop the dialog
              Navigator.pop(context);
              // Go back to the dashboard
              context.goNamed('dashboard');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ChartTabView extends ConsumerWidget {
  const _ChartTabView({required this.plant});
  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allReadingsAsync = ref.watch(allReadingsProvider);

    return allReadingsAsync.when(
      data: (allReadings) {
        final readings = allReadings[plant.id] ?? [];
        if (readings.isEmpty) {
          return const Center(child: Text('No data available for this plant.'));
        }
        // TODO: The isMonthly flag logic needs to be re-implemented if needed.
        // For now, displaying all data.
        return PlantDetailChart(readings: readings, isMonthly: false);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Failed to load chart data: $err'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(allReadingsProvider),
              child: const Text('Retry'),
            )
          ],
        ),
      ),
    );
  }
}

class _HistoryTabView extends ConsumerWidget {
  const _HistoryTabView({required this.plant});
  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allReadingsAsync = ref.watch(allReadingsProvider);

    return allReadingsAsync.when(
      data: (allReadings) {
        final readings = allReadings[plant.id] ?? [];
        if (readings.isEmpty) {
          return const Center(child: Text('No history available for this plant.'));
        }
        return HistoryList(readings: readings);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Failed to load history: $err'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(allReadingsProvider),
              child: const Text('Retry'),
            )
          ],
        ),
      ),
    );
  }
}
