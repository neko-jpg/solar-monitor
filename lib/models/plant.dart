import 'dart:ui';

import 'package:flutter/material.dart';

class Plant {
  final String id;
  final String name;
  final String url;
  final String username;
  final String password;
  final Color themeColor;
  final String icon;

  const Plant({
    required this.id,
    required this.name,
    required this.url,
    required this.username,
    required this.password,
    required this.themeColor,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'username': username,
        'password': password,
        'themeColor': themeColor.value,
        'icon': icon,
      };

  static Plant fromJson(Map<String, dynamic> json) => Plant(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
        username: json['username'] as String,
        password: json['password'] as String,
        themeColor: Color(json['themeColor'] as int),
        icon: json['icon'] as String,
      );
}
