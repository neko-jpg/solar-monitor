// lib/models/connector_config.dart
import 'dart:convert';

enum ConnectorMode { jsonApi, csv, html, sheets }

class ConnectorConfig {
  final ConnectorMode mode;
  final String? summaryUrl; // 現在値エンドポイント(JSON/CSV/Sheets)
  final String? readingsUrl; // 時系列エンドポイント(JSON/CSV/Sheets)
  final String? htmlUrl; // HTMLから抽出する場合のURL
  final String? htmlRegex; // 抽出正規表現（キーワード周辺の数値など）
  final Map<String, String>? csvMap; // CSVの列名マッピング

  const ConnectorConfig({
    required this.mode,
    this.summaryUrl,
    this.readingsUrl,
    this.htmlUrl,
    this.htmlRegex,
    this.csvMap,
  });

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'summaryUrl': summaryUrl,
    'readingsUrl': readingsUrl,
    'htmlUrl': htmlUrl,
    'htmlRegex': htmlRegex,
    'csvMap': csvMap,
  };

  static ConnectorConfig? fromJson(Map<String, dynamic>? j) {
    if (j == null) return null;
    final m = _modeFromName(j['mode'] as String?);
    if (m == null) return null;
    return ConnectorConfig(
      mode: m,
      summaryUrl: j['summaryUrl'] as String?,
      readingsUrl: j['readingsUrl'] as String?,
      htmlUrl: j['htmlUrl'] as String?,
      htmlRegex: j['htmlRegex'] as String?,
      csvMap: (j['csvMap'] as Map?)?.cast<String, String>(),
    );
  }

  static ConnectorMode? _modeFromName(String? s) {
    for (final v in ConnectorMode.values) {
      if (v.name == s) return v;
    }
    return null;
  }

  @override
  String toString() => jsonEncode(toJson());
}
