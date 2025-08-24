import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/plant.dart';
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
      appBar: AppBar(title: const Text('SolarTrack')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (alerts.isNotEmpty) ...alerts,
        const SectionHeader(title: 'Plants'),
        if (plants.isEmpty) const Text('プラントを追加してください'),
        ...plants.map((p) => _PlantTile(plant: p)),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: ()=>context.goNamed('plant_edit'), child: const Icon(Icons.add)),
    );
  }

  List<Widget> _buildAlerts(WidgetRef ref, List<Plant> plants) {
    final st = ref.watch(notificationSettingsProvider);
    final now = DateTime.now();
    final out = <Widget>[];
    for (final p in plants) {
      final async = ref.watch(latestReadingProvider(p));
      async.whenData((r) {
        if (!st.enabled) return;
        if (r == null) {
          out.add(AlertStrip(message: '${p.name}: 取得失敗', color: Colors.orange, onRetry: ()=>ref.invalidate(latestReadingProvider(p))));
          return;
        }
        final stale = now.difference(r.timestamp).inMinutes >= st.staleMinutes;
        if (stale) out.add(AlertStrip(message: '${p.name}: 未更新 ${now.difference(r.timestamp).inMinutes}分', color: Colors.orange, onRetry: ()=>ref.invalidate(latestReadingProvider(p))));
        if (r.power <= st.lowPowerKw) out.add(AlertStrip(message: '${p.name}: 低出力 ${r.power.toStringAsFixed(1)}kW', color: Colors.redAccent, onRetry: ()=>ref.invalidate(latestReadingProvider(p))));
      });
    }
    return out;
  }
}

class _PlantTile extends ConsumerWidget {
  final Plant plant; const _PlantTile({required this.plant});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(latestReadingProvider(plant));
    return Card(child: ListTile(
      onTap: ()=>context.goNamed('plant_detail', pathParameters: {'plantId': plant.id}),
      leading: CircleAvatar(backgroundColor: Color(plant.color)),
      title: Text(plant.name),
      subtitle: async.when(
        loading: () => const SkeletonTile(),
        error: (e, _) => const Text('取得失敗'),
        data: (r) {
          if (r == null) return const Text('データなし');
          final time = DateFormat('MM/dd HH:mm').format(r.timestamp);
          return Text('${r.power.toStringAsFixed(1)} kW  ·  $time');
        },
      ),
      trailing: const Icon(Icons.chevron_right),
    ));
  }
}
