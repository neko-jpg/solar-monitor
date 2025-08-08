import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/plant.dart';

class PlantGridCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback? onTap;
  const PlantGridCard({super.key, required this.plant, this.onTap});

  double get _latest =>
      plant.readings.isNotEmpty ? plant.readings.last.power : 0.0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plant.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            // 52.3 kW の大きい表示
            RichText(
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
}
