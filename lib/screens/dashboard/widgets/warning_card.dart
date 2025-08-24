import 'package:flutter/material.dart';

class WarningCard extends StatelessWidget {
  final String title;
  final String message;
  final List<String> problematicItems;
  final VoidCallback? onRetry;
  final Color color;

  const WarningCard({
    super.key,
    required this.title,
    required this.message,
    this.problematicItems = const [],
    this.onRetry,
    this.color = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: color),
                const SizedBox(width: 12),
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(message),
            if (problematicItems.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...problematicItems.map((item) => Text('• $item', style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry All'),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
