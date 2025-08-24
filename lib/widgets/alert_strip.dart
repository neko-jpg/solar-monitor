import 'package:flutter/material.dart';
class AlertStrip extends StatelessWidget {
  final String message; final Color color; final VoidCallback? onRetry;
  const AlertStrip({super.key, required this.message, required this.color, this.onRetry});
  @override Widget build(BuildContext context) {
    return Card(child: Row(children: [
      Container(width: 4, height: 56, color: color), const SizedBox(width: 12),
      Expanded(child: Text(message)), if (onRetry!=null) TextButton(onPressed: onRetry, child: const Text('再試行'))
    ]));
  }
}
