import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String title; final String? subtitle; final Widget? action;
  const EmptyState({super.key, required this.title, this.subtitle, this.action});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (subtitle!=null) Padding(padding: const EdgeInsets.only(top:8), child: Text(subtitle!)),
            if (action!=null) Padding(padding: const EdgeInsets.only(top:16), child: action!),
          ],
        ),
      ),
    );
  }
}
