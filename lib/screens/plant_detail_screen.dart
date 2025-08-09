import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/plant.dart';
import '../models/reading.dart';
import '../providers/plants_provider.dart';
import '../services/reading_service.dart';
import '../services/network/default_network_service.dart';
import '../utils/aggregation.dart';

class PlantDetailScreen extends ConsumerStatefulWidget {
  const PlantDetailScreen({super.key, required this.plantId});
  final String plantId;

  @override
  ConsumerState<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends ConsumerState<PlantDetailScreen> {
  final _service = ReadingService(DefaultNetworkService());
  List<Reading> _readings = const [];
  bool _loading = false;
  String _range = 'Daily'; // Daily / Weekly / Monthly
  final _fmtD = DateFormat('MM/dd');
  final _fmtT = DateFormat('MM/dd HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  Future<void> _sync() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final plants = ref.read(plantsProvider);
      final plant = plants.firstWhere((p) => p.id == widget.plantId);
      final rs = await _service.fetchReadings(plant);
      setState(() => _readings = rs);
      _toast('Synced ${rs.length} points');
    } catch (e) {
      _toast('Sync failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plants = ref.watch(plantsProvider);
    final plant = plants.firstWhere((p) => p.id == widget.plantId);

    final series = switch (_range) {
      'Daily' => aggregateDaily(_readings),
      'Weekly' => aggregateWeekly(_readings),
      _ => aggregateMonthly(_readings),
    };
    final stats = calcStats(series);

    return Scaffold(
      appBar: AppBar(
        title: Text(plant.name),
        actions: [
          IconButton(
            tooltip: 'Open site',
            icon: const Icon(Icons.open_in_new),
            onPressed: () async {
              final uri = Uri.tryParse(
                plant.url.startsWith('http')
                    ? plant.url
                    : 'https://${plant.url}',
              );
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                _toast('Invalid URL');
              }
            },
          ),
          IconButton(
            tooltip: 'Sync',
            icon:
                _loading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.sync),
            onPressed: _loading ? null : _sync,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Daily', label: Text('Daily')),
                    ButtonSegment(value: 'Weekly', label: Text('Weekly')),
                    ButtonSegment(value: 'Monthly', label: Text('Monthly')),
                  ],
                  selected: {_range},
                  onSelectionChanged: (s) => setState(() => _range = s.first),
                ),
                const Spacer(),
                _StatChip(
                  label: 'Max',
                  value: '${stats.max.toStringAsFixed(2)} kW',
                  icon: Icons.trending_up,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Avg',
                  value: '${stats.avg.toStringAsFixed(2)} kW',
                  icon: Icons.show_chart,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  series.isEmpty
                      ? const Center(child: Text('No data. Tap Sync.'))
                      : LineChart(_buildLineData(series)),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                series.isEmpty ? '' : 'Last: ${_fmtT.format(series.last.t)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildLineData(List<TimePoint> pts) {
    final spots =
        pts
            .map((e) => FlSpot(e.t.millisecondsSinceEpoch.toDouble(), e.v))
            .toList();
    final minX = spots.first.x;
    final maxX = spots.last.x;
    final maxY = (pts.map((e) => e.v).fold<double>(0, (a, b) => a > b ? a : b) *
            1.2)
        .clamp(1.0, double.infinity);

    return LineChartData(
      minX: minX,
      maxX: maxX,
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(show: true, horizontalInterval: maxY / 4),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: (maxX - minX) / 4,
            getTitlesWidget: (v, meta) {
              final dt = DateTime.fromMillisecondsSinceEpoch(v.toInt());
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _fmtD.format(dt),
                  style: const TextStyle(fontSize: 11),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: maxY / 4,
            getTitlesWidget:
                (v, meta) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(v.toStringAsFixed(0)),
                ),
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
      ],
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text('$label: $value'),
      side: BorderSide(color: Theme.of(context).dividerColor),
    );
  }
}
