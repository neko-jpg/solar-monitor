import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/plants_provider.dart';
import '../models/plant.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plants = ref.watch(plantsProvider);
    final mode = ref.watch(displayModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('発電所一覧'),
        actions: [
          PopupMenuButton<DisplayMode>(
            icon: const Icon(Icons.view_module),
            onSelected: (m) => ref.read(displayModeProvider.notifier).state = m,
            itemBuilder:
                (c) => const [
                  PopupMenuItem(
                    value: DisplayMode.carousel,
                    child: Text('カルーセル'),
                  ),
                  PopupMenuItem(value: DisplayMode.grid, child: Text('グリッド')),
                  PopupMenuItem(value: DisplayMode.list, child: Text('リスト')),
                  PopupMenuItem(value: DisplayMode.auto, child: Text('自動')),
                ],
          ),
        ],
      ),
      body: _buildBody(context, plants, mode, ref),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/plant/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<Plant> plants,
    DisplayMode mode,
    WidgetRef ref,
  ) {
    final resolved = _resolveMode(mode, plants.length);
    switch (resolved) {
      case DisplayMode.carousel:
        return PageView.builder(
          itemCount: plants.length,
          itemBuilder: (_, i) => _PlantBigCard(plant: plants[i]),
        );
      case DisplayMode.grid:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [for (final p in plants) _PlantSmallCard(plant: p)],
          ),
        );
      case DisplayMode.list:
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: plants.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _PlantListTile(plant: plants[i]),
        );
      case DisplayMode.auto:
        // 8拠点まではカルーセル、20までグリッド、それ以上はリスト
        final autoMode =
            plants.length <= 8
                ? DisplayMode.carousel
                : plants.length <= 20
                ? DisplayMode.grid
                : DisplayMode.list;
        return _buildBody(context, plants, autoMode, ref);
    }
  }
}

DisplayMode _resolveMode(DisplayMode m, int count) => m; // ここは上でautoを解決済み

class _PlantBigCard extends StatelessWidget {
  const _PlantBigCard({required this.plant});
  final Plant plant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => context.push('/plant/${plant.id}'),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  plant.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '現在 ${plant.latestKw.toStringAsFixed(0)} kW',
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text('今日の最高 ${plant.todayMaxKw.toStringAsFixed(0)} kW'),
                const SizedBox(height: 8),
                Text(
                  '更新: ${_fmtTime(plant.updatedAt)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantSmallCard extends StatelessWidget {
  const _PlantSmallCard({required this.plant});
  final Plant plant;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/plant/${plant.id}'),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                plant.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                '${plant.latestKw.toStringAsFixed(0)} kW',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                'Max ${plant.todayMaxKw.toStringAsFixed(0)} kW',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlantListTile extends StatelessWidget {
  const _PlantListTile({required this.plant});
  final Plant plant;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push('/plant/${plant.id}'),
      tileColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        plant.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Max ${plant.todayMaxKw.toStringAsFixed(0)} kW・更新 ${_fmtTime(plant.updatedAt)}',
      ),
      trailing: Text(
        '${plant.latestKw.toStringAsFixed(0)} kW',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}

String _fmtTime(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
