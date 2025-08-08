import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../models/plant.dart';

class PlantCarouselCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback? onTap;
  const PlantCarouselCard({super.key, required this.plant, this.onTap});

  double get _latest =>
      plant.readings.isNotEmpty ? plant.readings.last.power : 0.0;
  double get _todayMax =>
      plant.readings.isEmpty
          ? 0.0
          : plant.readings.map((e) => e.power).reduce((a, b) => a > b ? a : b);

  String get _updatedAgo {
    if (plant.readings.isEmpty) return '—';
    final d = DateTime.now().difference(plant.readings.last.timestamp);
    if (d.inMinutes < 1) return 'Updated just now';
    if (d.inMinutes < 60) return 'Updated ${d.inMinutes} min ago';
    return 'Updated ${d.inHours} h ago';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTok.darkCard,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plant.name,
                      style: const TextStyle(
                        color: AppTok.onDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.wb_sunny_rounded,
                    color: Colors.amberAccent,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${NumberFormat("#,##0.#").format(_latest)} kW',
                style: const TextStyle(
                  color: AppTok.onDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 44,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: Colors.white.withOpacity(0.2)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _metric(
                      'Today\'s Max',
                      '${_todayMax.toStringAsFixed(0)} kW',
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _updatedAgo,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.85))),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppTok.onDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
