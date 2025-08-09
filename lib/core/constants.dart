import 'package:flutter/material.dart';

/// アプリ共通トークン
class AppTok {
  // Colors
  static const darkBg = Color(0xFF0E1116); // ダーク背景
  static const blue = Color(0xFF1E6BFF); // プライマリ
  static const onDark = Colors.white;
  static const cardBg = Colors.white;

  // ↓↓↓ 不足していた定義を追加 ↓↓↓
  static const darkCard = Color(0xFF1C2129); // ダークテーマのカード背景
  static const darkMini = Color(0xFF2D3440); // ダークテーマのミニカード背景

  // Card shadow（軽め）
  static const shadow = <BoxShadow>[
    BoxShadow(
      color: Color(0x14000000), // 8%黒
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
