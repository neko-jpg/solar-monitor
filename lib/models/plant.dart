import 'package:flutter/material.dart';

import 'reading.dart';

class Plant {
  final String id;
  final String name;
  final String url;
  final String username;
  final String password;
  final Color themeColor;
  final String icon;
  final List<Reading> readings;

  Plant({
    required this.id,
    required this.name,
    required this.url,
    required this.username,
    required this.password,
    required this.themeColor,
    required this.icon,
    required this.readings,
  });

  Plant copyWith({
    String? id,
    String? name,
    String? url,
    String? username,
    String? password,
    Color? themeColor,
    String? icon,
    List<Reading>? readings,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      username: username ?? this.username,
      password: password ?? this.password,
      themeColor: themeColor ?? this.themeColor,
      icon: icon ?? this.icon,
      readings: readings ?? this.readings,
    );
  }

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      themeColor: Color(json['themeColor'] as int),
      icon: json['icon'] as String,
      readings: (json['readings'] as List<dynamic>)
          .map((e) => Reading.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'username': username,
        'password': password,
        'themeColor': themeColor.value,
        'icon': icon,
        'readings': readings.map((r) => r.toJson()).toList(),
      };
}
