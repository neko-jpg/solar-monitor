import 'package:flutter/material.dart';
class SkeletonTile extends StatelessWidget {
  const SkeletonTile({super.key});
  @override Widget build(BuildContext context) {
    return Card(child: ListTile(
      leading: Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(16))),
      title: Container(height: 12, color: Colors.black12),
      subtitle: Padding(padding: const EdgeInsets.only(top:6), child: Container(height: 10, color: Colors.black12)),
    ));
  }
}
