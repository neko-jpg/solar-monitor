import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/reading.dart';
import '../../../providers/plants_provider.dart';
import '../../../providers/reading_provider.dart';
import '../../../utils/aggregation.dart';

class GenerationByPlantChart extends ConsumerWidget {
  const GenerationByPlantChart({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plants = ref.watch(plantsProvider);
    final async = ref.watch(allReadingsProvider);
    return async.when(
      loading: ()=> const Center(child: CircularProgressIndicator()),
      error: (e,_)=>(Center(child: Text('取得失敗'))),
      data: (byPlant){
        final entries = plants.map((p)=> (p.name, p.color, totalEnergyKwh(byPlant[p.id]??const <Reading>[]))).toList();
        final bars = <BarChartGroupData>[];
        for (var i=0;i<entries.length;i++){
          final (name,color,kwh)=entries[i];
          bars.add(BarChartGroupData(x:i, barRods:[
            BarChartRodData(
              toY:kwh,
              width:16,
              color: Color(color),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ]));
        }
        return SizedBox(height:260, child: BarChart(BarChartData(
          barGroups: bars,
          gridData: const FlGridData(show:false),
          borderData: FlBorderData(show:false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles:true, reservedSize:42)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles:false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles:false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles:true, getTitlesWidget:(v,meta){
              final idx=v.toInt(); if(idx<0||idx>=entries.length) return const SizedBox.shrink();
              final label=entries[idx].$1; return Padding(padding: const EdgeInsets.only(top:6), child: Text(label.length>6? '${label.substring(0,6)}…':label, style: const TextStyle(fontSize:11)));
            })),
          )));
      },
    );
  }
}
