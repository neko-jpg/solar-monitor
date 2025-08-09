// lib/services/reading_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/plant.dart';
import '../models/reading.dart';
import '../models/connector_config.dart';
import 'discovery_service.dart';

class Summary {
  final double powerKw;
  final DateTime timestamp;
  final double? energyTodayKwh;
  final double? energyTotalMwh;

  Summary({
    required this.powerKw,
    required this.timestamp,
    this.energyTodayKwh,
    this.energyTotalMwh,
  });
}

/// ConnectorConfig を優先して取得するリーディング層。
/// Configが未登録の場合は「従来の自動推測（JSON→CSV→HTML）」でフォールバック。
class ReadingService {
  ReadingService(Object _net, {Duration? timeout})
    : _timeout = timeout ?? const Duration(seconds: 8);

  final Duration _timeout;
  final _store = ConnectorConfigStore();

  // -------- Public API --------

  Future<Summary?> fetchSummary(Plant plant) async {
    final cfg = await _store.load(plant.id);
    if (cfg != null) {
      final s = await _summaryByConfig(cfg, plant);
      if (s != null) return s;
    }
    // fallback: 自動推測（最低限）
    return _fallbackSummary(plant);
  }

  Future<List<Reading>> fetchReadings(Plant plant) async {
    final cfg = await _store.load(plant.id);
    if (cfg != null) {
      final r = await _readingsByConfig(cfg, plant);
      if (r.isNotEmpty) return r;
    }
    // fallback
    return _fallbackReadings(plant);
  }

  // -------- By Config --------

  Future<Summary?> _summaryByConfig(ConnectorConfig cfg, Plant plant) async {
    switch (cfg.mode) {
      case ConnectorMode.jsonApi:
        if (cfg.summaryUrl != null) {
          final j = await _getJson(
            cfg.summaryUrl!,
            plant.username,
            plant.password,
          );
          final s = _summaryFromJson(j);
          if (s != null) return s;
        }
        // summaryが無い場合、readingsの最後を現在値扱い
        final rs = await _readingsByConfig(cfg, plant);
        if (rs.isNotEmpty) {
          final last = rs.last;
          return Summary(powerKw: last.power, timestamp: last.timestamp);
        }
        return null;

      case ConnectorMode.csv:
      case ConnectorMode.sheets:
        if (cfg.readingsUrl != null) {
          final text = await _getText(
            cfg.readingsUrl!,
            plant.username,
            plant.password,
          );
          if (text != null) {
            final list = _readingsFromCsv(text, cfg.csvMap);
            if (list.isNotEmpty) {
              final last = list.last;
              return Summary(powerKw: last.power, timestamp: last.timestamp);
            }
          }
        }
        return null;

      case ConnectorMode.html:
        if (cfg.htmlUrl != null) {
          final html = await _getText(
            cfg.htmlUrl!,
            plant.username,
            plant.password,
          );
          final p = _extractPowerFromHtml(html ?? '', cfg.htmlRegex);
          if (p != null) {
            return Summary(powerKw: p, timestamp: DateTime.now());
          }
        }
        return null;
    }
  }

  Future<List<Reading>> _readingsByConfig(
    ConnectorConfig cfg,
    Plant plant,
  ) async {
    if (cfg.mode == ConnectorMode.jsonApi && cfg.readingsUrl != null) {
      final j = await _getJson(
        cfg.readingsUrl!,
        plant.username,
        plant.password,
      );
      return _readingsFromJson(j);
    }
    if ((cfg.mode == ConnectorMode.csv || cfg.mode == ConnectorMode.sheets) &&
        cfg.readingsUrl != null) {
      final text = await _getText(
        cfg.readingsUrl!,
        plant.username,
        plant.password,
      );
      if (text != null) return _readingsFromCsv(text, cfg.csvMap);
    }
    return const <Reading>[];
  }

  // -------- Fallback (legacy auto) --------

  Future<Summary?> _fallbackSummary(Plant plant) async {
    // JSONサマリ候補
    final base = _normalizeBase(plant.url);
    for (final path in const ['api/summary', 'summary.json', 'status.json']) {
      final u = _join(base, path);
      final j = await _getJson(u, plant.username, plant.password);
      final s = _summaryFromJson(j);
      if (s != null) return s;
    }
    // readings → 最後を現在値
    final rs = await _fallbackReadings(plant);
    if (rs.isNotEmpty)
      return Summary(powerKw: rs.last.power, timestamp: rs.last.timestamp);
    // HTML
    final html = await _getText(base, plant.username, plant.password);
    final p = _extractPowerFromHtml(html ?? '', null);
    if (p != null) return Summary(powerKw: p, timestamp: DateTime.now());
    return null;
  }

  Future<List<Reading>> _fallbackReadings(Plant plant) async {
    final base = _normalizeBase(plant.url);
    for (final path in const [
      'api/readings',
      'readings.json',
      'data/readings.json',
    ]) {
      final u = _join(base, path);
      final j = await _getJson(u, plant.username, plant.password);
      final list = _readingsFromJson(j);
      if (list.isNotEmpty) return list;
    }
    for (final path in const [
      'readings.csv',
      'api/readings.csv',
      'data/readings.csv',
    ]) {
      final u = _join(base, path);
      final t = await _getText(u, plant.username, plant.password);
      if (t != null) {
        final list = _readingsFromCsv(t, null);
        if (list.isNotEmpty) return list;
      }
    }
    return const <Reading>[];
  }

  // -------- HTTP --------

  String _normalizeBase(String raw) {
    var r = raw.trim();
    if (!r.startsWith('http://') && !r.startsWith('https://')) r = 'https://$r';
    if (!r.endsWith('/')) r = '$r/';
    return r;
  }

  String _join(String base, String path) {
    if (base.endsWith('/') && path.startsWith('/'))
      return base + path.substring(1);
    if (!base.endsWith('/') && !path.startsWith('/')) return '$base/$path';
    return base + path;
  }

  Future<Map<String, dynamic>?> _getJson(
    String url,
    String? user,
    String? pass,
  ) async {
    try {
      final headers = <String, String>{'Accept': 'application/json'};
      if ((user ?? '').isNotEmpty || (pass ?? '').isNotEmpty) {
        final auth = base64.encode(utf8.encode('${user ?? ''}:${pass ?? ''}'));
        headers['Authorization'] = 'Basic $auth';
      }
      final res = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(_timeout);
      if (res.statusCode >= 200 &&
          res.statusCode < 300 &&
          res.body.isNotEmpty) {
        final d = json.decode(res.body);
        if (d is Map<String, dynamic>) return d;
        if (d is List) return {'readings': d};
      }
    } on TimeoutException {
    } on HandshakeException {
    } on SocketException {
    } catch (_) {}
    return null;
  }

  Future<String?> _getText(String url, String? user, String? pass) async {
    try {
      final headers = <String, String>{'Accept': '*/*'};
      if ((user ?? '').isNotEmpty || (pass ?? '').isNotEmpty) {
        final auth = base64.encode(utf8.encode('${user ?? ''}:${pass ?? ''}'));
        headers['Authorization'] = 'Basic $auth';
      }
      final res = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(_timeout);
      if (res.statusCode >= 200 && res.statusCode < 300) return res.body;
    } on TimeoutException {
    } on HandshakeException {
    } on SocketException {
    } catch (_) {}
    return null;
  }

  // -------- Parsers --------

  Summary? _summaryFromJson(Map<String, dynamic>? j) {
    if (j == null) return null;
    if (j['summary'] is Map<String, dynamic>) {
      return _summaryFromJson(j['summary'] as Map<String, dynamic>);
    }
    double? power = _asDouble(
      j['power_kw'] ?? j['power'] ?? j['current_power'],
    );
    double? today = _asDouble(
      j['energy_today_kwh'] ?? j['today_kwh'] ?? j['energy_today'],
    );
    double? total = _asDouble(
      j['energy_total_mwh'] ?? j['energy_total_kwh'] ?? j['total_energy'],
    );
    DateTime ts =
        _asDateTime(
          j['timestamp'] ?? j['time'] ?? j['updated_at'] ?? j['last_update'],
        ) ??
        DateTime.now();
    if (power == null) return null;
    return Summary(
      powerKw: power,
      timestamp: ts,
      energyTodayKwh: today,
      energyTotalMwh: total,
    );
  }

  List<Reading> _readingsFromJson(Map<String, dynamic>? j) {
    if (j == null) return const <Reading>[];
    final raw = j['readings'] ?? j['data'] ?? j['items'];
    if (raw is! List) return const <Reading>[];
    final out = <Reading>[];
    for (final e in raw) {
      if (e is Map<String, dynamic>) {
        final dt = _asDateTime(e['timestamp'] ?? e['time'] ?? e['t']);
        final p = _asDouble(e['power'] ?? e['kw'] ?? e['value']);
        if (dt != null && p != null)
          out.add(Reading(timestamp: dt, power: p.toDouble()));
      }
    }
    out.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return out;
  }

  List<Reading> _readingsFromCsv(String text, Map<String, String>? csvMap) {
    var t = text;
    if (t.isNotEmpty && t.codeUnitAt(0) == 0xFEFF) t = t.substring(1); // BOM
    final delim = t.contains(';') && !t.contains(',') ? ';' : ',';
    final lines =
        t.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return const <Reading>[];

    final header =
        lines.first.split(delim).map((s) => s.trim().toLowerCase()).toList();
    int idxT = _indexOf(header, const [
      'timestamp',
      'time',
      'date',
      'datetime',
      't',
    ]);
    int idxP = _indexOf(header, const [
      'power',
      'kw',
      'value',
      'power_kw',
      'p',
    ]);
    if (csvMap != null) {
      if (csvMap['timestamp'] != null)
        idxT = header.indexOf(csvMap['timestamp']!.toLowerCase());
      if (csvMap['power'] != null)
        idxP = header.indexOf(csvMap['power']!.toLowerCase());
    }
    if (idxT < 0 || idxP < 0) return const <Reading>[];

    final out = <Reading>[];
    for (var i = 1; i < lines.length; i++) {
      final cols = lines[i].split(delim);
      if (cols.length <= idxT || cols.length <= idxP) continue;
      final dt = _asDateTime(cols[idxT]);
      final p = _asDouble(cols[idxP]);
      if (dt != null && p != null)
        out.add(Reading(timestamp: dt, power: p.toDouble()));
    }
    out.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return out;
  }

  double? _extractPowerFromHtml(String html, String? pattern) {
    final s = html
        .replaceAll(RegExp(r'[\r\n]+'), ' ')
        .replaceAll('ｋＷ', 'kW')
        .replaceAll('ＫＷ', 'kW');
    if (pattern != null && pattern.isNotEmpty) {
      final re = RegExp(pattern);
      final m = re.firstMatch(s);
      if (m != null && m.groupCount >= 2) return double.tryParse(m.group(2)!);
    }
    final re = RegExp(
      r'(現在|今|出力|power|Power|POWER).{0,30}?([0-9]+(?:\.[0-9]+)?)\s*kW',
    );
    final m = re.firstMatch(s);
    if (m != null && m.groupCount >= 2) return double.tryParse(m.group(2)!);
    final re2 = RegExp(r'([0-9]+(?:\.[0-9]+)?)\s*kW');
    final m2 = re2.firstMatch(s);
    if (m2 != null) return double.tryParse(m2.group(1)!);
    return null;
  }

  // -------- utils --------

  int _indexOf(List<String> header, List<String> keys) {
    for (final k in keys) {
      final i = header.indexOf(k);
      if (i >= 0) return i;
    }
    return -1;
  }

  double? _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '').trim());
    return null;
  }

  DateTime? _asDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v.toLocal();
    if (v is int) {
      final isSec = v < 2000000000;
      final dt =
          isSec
              ? DateTime.fromMillisecondsSinceEpoch(v * 1000, isUtc: true)
              : DateTime.fromMillisecondsSinceEpoch(v, isUtc: true);
      return dt.toLocal();
    }
    if (v is String) {
      try {
        return DateTime.parse(v).toLocal();
      } catch (_) {}
    }
    return null;
  }
}
