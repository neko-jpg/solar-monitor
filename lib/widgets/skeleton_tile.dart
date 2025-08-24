import 'package:flutter/material.dart';

class SkeletonTile extends StatelessWidget {
  const SkeletonTile({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(width: 32, height: 32, color: Colors.black.withAlpha(25)),
        title: Container(height: 14, color: Colors.black.withAlpha(25)),
        subtitle: Container(height: 12, margin: const EdgeInsets.only(top: 6), color: Colors.black.withAlpha(25)),
      ),
    );
  }
}
