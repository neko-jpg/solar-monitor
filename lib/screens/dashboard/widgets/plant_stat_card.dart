import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../models/plant.dart';

class PlantStatCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback? onTap;
  const PlantStatCard({super.key, required this.plant, this.onTap});

  double get _latest =>
      plant.readings.isNotEmpty ? plant.readings.last.power : 0.0;
  double get _todayMax =>
      plant.readings.isEmpty
          ? 0.0
          : plant.readings.map((e) => e.power).reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTok.darkMini,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plant.name,
                style: const TextStyle(
                  color: AppTok.onDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _latest.toStringAsFixed(0),
                      style: const TextStyle(
                        color: AppTok.onDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                    const TextSpan(
                      text: ' kW',
                      style: TextStyle(
                        color: AppTok.onDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Today\'s Max\n${_todayMax.toStringAsFixed(0)} kW',
                style: TextStyle(color: Colors.white.withOpacity(0.9)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
