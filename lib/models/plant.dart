import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'reading.dart';

class Plant extends Equatable {
  final String id;
  final String name;
  final String url;
  final String username;
  final String password;
  final Color themeColor; // Color(value)
  final String icon; // Material icon codePoint を文字列で保存
  final List<Reading> readings;

  const Plant({
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

  // JSON -> Plant
  factory Plant.fromJson(Map<String, dynamic> j) {
    return Plant(
      id: j['id'] as String,
      name: j['name'] as String,
      url: j['url'] as String? ?? '',
      username: j['username'] as String? ?? '',
      password: j['password'] as String? ?? '',
      themeColor: Color(
        (j['themeColor'] as num?)?.toInt() ?? const Color(0xFF1E6BFF).value,
      ),
      icon: j['icon'] as String? ?? '0',
      readings:
          (j['readings'] as List? ?? const [])
              .map((e) => Reading.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(),
    );
  }

  // Plant -> JSON
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

  @override
  List<Object?> get props => [
    id,
    name,
    url,
    username,
    password,
    themeColor,
    icon,
    readings,
  ];
}
