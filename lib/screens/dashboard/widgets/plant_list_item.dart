import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/plant.dart';

class PlantListItem extends StatelessWidget {
  final Plant plant;
  final VoidCallback? onTap;
  final EdgeInsets margin;
  const PlantListItem({
    super.key,
    required this.plant,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  double get _latest =>
      plant.readings.isNotEmpty ? plant.readings.last.power : 0.0;
  double get _todayMax =>
      plant.readings.isEmpty
          ? 0.0
          : plant.readings.map((e) => e.power).reduce((a, b) => a > b ? a : b);
  DateTime? get _updatedAt =>
      plant.readings.isEmpty ? null : plant.readings.last.timestamp;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: margin,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 左：名前＋Max/日付/時刻
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Max ${_todayMax.toStringAsFixed(1)} kW • Today • ${_updatedAt == null ? '--:--' : _time(_updatedAt!)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // 右：現在値をでかく
            RichText(
              textAlign: TextAlign.right,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: NumberFormat("#,##0.#").format(_latest),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const TextSpan(
                    text: ' kW',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _time(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}
