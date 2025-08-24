import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/reading.dart';

/// A widget to display a list of historical power readings.
class HistoryList extends StatelessWidget {
  final List<Reading> readings;

  const HistoryList({super.key, required this.readings});

  @override
  Widget build(BuildContext context) {
    // 新しい順に表示するためにリストを逆順にする
    final reversedReadings = readings.reversed.toList();

    if (reversedReadings.isEmpty) {
      return const Center(child: Text('No historical data available.'));
    }

    return ListView.builder(
      itemCount: reversedReadings.length,
      itemBuilder: (context, index) {
        final reading = reversedReadings[index];
        return ListTile(
          leading: const Icon(Icons.history, color: Colors.grey),
          title: Text(
            '${reading.power.toStringAsFixed(2)} kW',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            DateFormat('yyyy/MM/dd HH:mm').format(reading.timestamp),
          ),
        );
      },
    );
  }
}
