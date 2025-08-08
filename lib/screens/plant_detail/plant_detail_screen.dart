import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../models/plant.dart';
import '../providers/plants_provider.dart';
import 'widgets/plant_detail_chart.dart'; // ← チャート用ウィジェットを別ファイル化推奨

class PlantDetailScreen extends ConsumerStatefulWidget {
  final String plantId;
  const PlantDetailScreen({super.key, required this.plantId});

  @override
  ConsumerState<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends ConsumerState<PlantDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 日別・月別
  }

  @override
  Widget build(BuildContext context) {
    final plants = ref.watch(plantsProvider);
    final plant = plants.firstWhere((p) => p.id == widget.plantId);

    return Scaffold(
      appBar: AppBar(
        title: Text(plant.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.pushNamed('editPlant', pathParameters: {'id': plant.id});
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, plant),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Daily'), Tab(text: 'Monthly')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailTab(context, plant, isMonthly: false),
          _buildDetailTab(context, plant, isMonthly: true),
        ],
      ),
    );
  }

  Widget _buildDetailTab(
    BuildContext context,
    Plant plant, {
    required bool isMonthly,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMonthly ? 'Monthly Generation' : 'Daily Generation',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: PlantDetailChart(
                  readings: plant.readings,
                  isMonthly: isMonthly,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Latest Reading',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                plant.readings.isNotEmpty
                    ? '${plant.readings.last.power.toStringAsFixed(2)} kW'
                    : 'No data',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (plant.readings.isNotEmpty)
                Text(
                  'at ${plant.readings.last.timestamp}',
                  style: const TextStyle(color: Colors.black54),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, Plant plant) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Plant'),
            content: Text('Are you sure you want to delete "${plant.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(plantsProvider.notifier).removePlant(plant);
                  Navigator.pop(context);
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

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTok.shadow,
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
