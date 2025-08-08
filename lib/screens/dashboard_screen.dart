import '../providers/plants_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/plant.dart';

enum DashboardView { carousel, grid, list }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DashboardView view = DashboardView.carousel;

  @override
  Widget build(BuildContext context) {
    final plants = ref.watch(plantsProvider);
    Widget body;
    switch (view) {
      case DashboardView.carousel:
        body = PageView.builder(
          itemCount: plants.length,
          itemBuilder:
              (context, index) => _PlantCardLarge(plant: plants[index]),
        );
        break;
      case DashboardView.grid:
        body = GridView.count(
          padding: const EdgeInsets.all(12),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: plants.map((p) => _PlantCardSmall(plant: p)).toList(),
        );
        break;
      case DashboardView.list:
        body = ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: plants.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _PlantTile(plant: plants[i]),
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          PopupMenuButton<DashboardView>(
            icon: const Icon(Icons.view_module),
            initialValue: view,
            onSelected: (v) => setState(() => view = v),
            itemBuilder:
                (_) => const [
                  PopupMenuItem(
                    value: DashboardView.carousel,
                    child: Text('Carousel'),
                  ),
                  PopupMenuItem(value: DashboardView.grid, child: Text('Grid')),
                  PopupMenuItem(value: DashboardView.list, child: Text('List')),
                ],
          ),
        ],
      ),
      body: plants.isEmpty ? const Center(child: Text('No plants')) : body,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('addPlant'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PlantCardLarge extends StatelessWidget {
  const _PlantCardLarge({required this.plant});
  final Plant plant;

  @override
  Widget build(BuildContext context) {
    final latest = plant.readings.isNotEmpty ? plant.readings.last.power : 0.0;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: plant.themeColor.withValues(alpha: (0.1 * 255).toDouble()),
        child: InkWell(
          onTap:
              () => context.pushNamed(
                'plantDetail',
                pathParameters: {'id': plant.id},
              ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  plant.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  '${latest.toStringAsFixed(1)} kW',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantCardSmall extends StatelessWidget {
  const _PlantCardSmall({required this.plant});
  final Plant plant;

  @override
  Widget build(BuildContext context) {
    final latest = plant.readings.isNotEmpty ? plant.readings.last.power : 0.0;
    return Card(
      child: InkWell(
        onTap:
            () => context.pushNamed(
              'plantDetail',
              pathParameters: {'id': plant.id},
            ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                plant.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${latest.toStringAsFixed(1)} kW',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlantTile extends StatelessWidget {
  const _PlantTile({required this.plant});
  final Plant plant;

  @override
  Widget build(BuildContext context) {
    final latest = plant.readings.isNotEmpty ? plant.readings.last.power : 0.0;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Theme.of(context).colorScheme.surface,
      onTap:
          () => context.pushNamed(
            'plantDetail',
            pathParameters: {'id': plant.id},
          ),
      title: Text(plant.name),
      trailing: Text('${latest.toStringAsFixed(1)} kW'),
    );
  }
}
