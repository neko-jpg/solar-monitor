import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/plants_provider.dart';
import '../../../models/plant.dart';
import '../../../services/reading_service.dart';
import '../../../services/network/default_network_service.dart';
import '../../../providers/plants_provider.dart'
    show plantsIssuesProvider, healthyPlantsProvider, PlantIssue, IssueKind;

show plantsIssuesProvider, healthyPlantsProvider, PlantIssue, IssueKind;

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _fmtTime = DateFormat('MM/dd HH:mm');
  final _readingService = ReadingService(DefaultNetworkService());
  final Map<String, double> _latestPower = {};
  final Map<String, DateTime> _latestAt = {};
  bool _loading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshAll());
    _timer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted && !_loading) {
        _refreshAll();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    if (_loading) return;
    setState(() => _loading = true);

    final plants = ref.read(plantsProvider);
    int ok = 0, ng = 0;
    for (final p in plants) {
      try {
        final summary = await _readingService.fetchSummary(p);
        if (summary != null) {
          _latestPower[p.id] = summary.powerKw;
          _latestAt[p.id] = summary.timestamp;
          ok++;
        } else {
          ng++;
        }
      } catch (_) {
        ng++;
      }
      if (!mounted) break;
      setState(() {}); // 順次反映
    }

    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Synced: $ok success, $ng failed')),
      );
    }
  }

  Future<void> _refreshOne(Plant p) async {
    try {
      final summary = await _readingService.fetchSummary(p);
      if (summary != null) {
        setState(() {
          _latestPower[p.id] = summary.powerKw;
          _latestAt[p.id] = summary.timestamp;
        });
        _toast('Updated ${p.name}');
      } else {
        _toast('No data: ${p.name}');
      }
    } catch (_) {
      _toast('Failed: ${p.name}');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final issues = ref.watch(plantsIssuesProvider);
    final healthy = ref.watch(healthyPlantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh all',
            onPressed: _loading ? null : _refreshAll,
            icon:
                _loading
                    ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : const Icon(Icons.sync),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          children: [
            if (issues.isNotEmpty) ...[
              Text(
                'Plants with Issues',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...issues.map((i) => _plantTile(i.plant, issue: i)),
              const SizedBox(height: 16),
            ],
            Text(
              'Other Plants',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (healthy.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No plants yet. Add one to start.'),
                ),
              )
            else
              ...healthy.map((p) => _plantTile(p)),
          ],
        ),
      ),
    );
  }

  Widget _plantTile(Plant p, {PlantIssue? issue}) {
    final v = _latestPower[p.id];
    final t = _latestAt[p.id];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: p.themeColor.withOpacity(0.2),
          child: Icon(
            IconData(
              int.tryParse(p.icon) ?? Icons.wb_sunny_rounded.codePoint,
              fontFamily: 'MaterialIcons',
            ),
            color: p.themeColor,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                p.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (issue != null) _issueBadge(issue),
          ],
        ),
        subtitle:
            v == null
                ? const Text('Tap refresh to fetch power')
                : Text(
                  '${v.toStringAsFixed(2)} kW  •  ${t == null ? '-' : _fmtTime.format(t)}',
                ),
        trailing: IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: () => _refreshOne(p),
        ),
        onTap: () {
          // 既存のルーターに合わせて遷移（必要なら有効化）
          // context.go('/plant/${p.id}');
        },
      ),
    );
  }

  Widget _issueBadge(PlantIssue i) {
    switch (i.kind) {
      case IssueKind.stale:
        return const Chip(
          backgroundColor: Color(0xFFFFF3CD),
          label: Text('STALE', style: TextStyle(color: Color(0xFF856404))),
          avatar: Icon(Icons.schedule, size: 18, color: Color(0xFF856404)),
        );
      case IssueKind.low:
        return const Chip(
          backgroundColor: Color(0xFFF8D7DA),
          label: Text('LOW', style: TextStyle(color: Color(0xFF721C24))),
          avatar: Icon(Icons.trending_down, size: 18, color: Color(0xFF721C24)),
        );
      case IssueKind.drop:
        return const Chip(
          backgroundColor: Color(0xFFD1ECF1),
          label: Text('DROP', style: TextStyle(color: Color(0xFF0C5460))),
          avatar: Icon(Icons.show_chart, size: 18, color: Color(0xFF0C5460)),
        );
    }
  }
}
