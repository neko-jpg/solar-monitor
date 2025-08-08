import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/plants_provider.dart';
import 'widgets/total_generation_chart.dart';
import 'widgets/generation_by_plant_chart.dart';

// ← 追加
import '../../services/export/csv_export_service.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plants = ref.watch(plantsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          title: const Text('Solar Energy'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Total'),
              Tab(text: 'Comparison'),
              Tab(text: 'Export'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Total
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _Card(child: TotalGenerationChart(plants: plants)),
                const SizedBox(height: 12),
                _Card(
                  child: GenerationByPlantChart(plants: plants, compact: true),
                ),
              ],
            ),

            // Comparison
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [_Card(child: GenerationByPlantChart(plants: plants))],
            ),

            // Export
            _ExportTab(),
          ],
        ),
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

class _ExportTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plants = ref.watch(plantsProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Export your data',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Download CSV or send to Google Sheets (coming soon).',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed:
                  plants.isEmpty
                      ? null
                      : () async {
                        final path = await CsvExportService().exportPlantsToCsv(
                          plants,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Exported CSV → $path')),
                        );
                      },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('CSV'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: null, // Sheetsはv2で実装
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Sheets (coming soon)'),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
