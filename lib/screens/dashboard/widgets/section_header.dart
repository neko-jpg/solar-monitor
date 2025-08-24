import 'package:flutter/material.dart';
class SectionHeader extends StatelessWidget {
  final String title; const SectionHeader({super.key, required this.title});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(title, style: Theme.of(context).textTheme.titleLarge),
  );
}
