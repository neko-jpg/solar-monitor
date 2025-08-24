import 'package:flutter/material.dart';

class WarningCard extends StatelessWidget {
  final String title; final String subtitle; final Color color; final VoidCallback? onRetry;
  const WarningCard({super.key, required this.title, required this.subtitle, required this.color, this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(
      leading: Container(width: 6, height: double.infinity, color: color),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle),
      trailing: onRetry==null? null : TextButton(onPressed: onRetry, child: const Text('再試行')),
    ));
  }
}
