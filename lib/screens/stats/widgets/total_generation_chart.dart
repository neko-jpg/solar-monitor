import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/reading_provider.dart';
import '../../../utils/aggregation.dart';

class TotalGenerationChart extends ConsumerWidget {
  const TotalGenerationChart({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allReadingsProvider);
    return async.when(
      loading: ()=> const Center(child: CircularProgressIndicator()),
      error: (e,_)=>(Center(child: Text('取得失敗'))),
      data: (byPlant){
        final daily = aggregateDaily(byPlant); // List<MapEntry<DateTime,double>>
        if (daily.isEmpty) return const SizedBox(height: 220, child: Center(child: Text('データなし')));
        final spots = <FlSpot>[];
        for (var i=0;i<daily.length;i++) {
          final d = daily[i];
          spots.add(FlSpot(i.toDouble(), d.value));
        }
        return SizedBox(
          height: 260,
          child: LineChart(LineChartData(
            minX: 0, maxX: (spots.length-1).toDouble(),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 2,
              )
            ],
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 42)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta){
                final idx = v.toInt(); if (idx<0 || idx>=daily.length) return const SizedBox.shrink();
                final d = daily[idx].key; return Padding(padding: const EdgeInsets.only(top:6), child: Text('${d.month}/${d.day}', style: const TextStyle(fontSize: 11)));
              })),
          )),
        );
      },
    );
  }
}
