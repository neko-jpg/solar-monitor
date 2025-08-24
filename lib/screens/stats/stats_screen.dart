import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/plants_provider.dart';
import '../../providers/reading_provider.dart';
import 'widgets/generation_by_plant_chart.dart';
import 'widgets/total_generation_chart.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allReadingsAsync = ref.watch(allReadingsProvider);
    final plants = ref.watch(plantsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: allReadingsAsync.when(
        data: (readingsByPlant) {
          if (plants.isEmpty) {
            return const Center(child: Text('Add a plant to see statistics.'));
          }

          // Flatten the map values to get a single list for the total chart
          final allReadings = readingsByPlant.values.expand((list) => list).toList();

          if (allReadings.isEmpty) {
            return const Center(child: Text('No data has been recorded yet.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Overall Generation', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: const TotalGenerationChart(),
              ),
              const SizedBox(height: 24),
              Text('Generation by Plant', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              // This widget now gets its data from the provider map internally
              const SizedBox(
                height: 260, // Adjusted height from Ritsu's sample
                child: GenerationByPlantChart(),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load statistics: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(allReadingsProvider),
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
