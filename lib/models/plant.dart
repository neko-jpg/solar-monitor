import 'package:flutter/material.dart';

class Plant {
  final String id;
  final String name;
  final String siteUrl;
  final Color theme; // ここを Color に
  final double latestKw;
  final double todayMaxKw;
  final DateTime updatedAt;

  const Plant({
    required this.id,
    required this.name,
    required this.siteUrl,
    required this.theme,
    required this.latestKw,
    required this.todayMaxKw,
    required this.updatedAt,
  });

  Plant copyWith({
    String? id,
    String? name,
    String? siteUrl,
    Color? theme,
    double? latestKw,
    double? todayMaxKw,
    DateTime? updatedAt,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      siteUrl: siteUrl ?? this.siteUrl,
      theme: theme ?? this.theme,
      latestKw: latestKw ?? this.latestKw,
      todayMaxKw: todayMaxKw ?? this.todayMaxKw,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
