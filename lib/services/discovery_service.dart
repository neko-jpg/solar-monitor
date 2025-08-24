// // lib/services/discovery_service.dart
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

// import '../models/connector_config.dart';

// class ConnectorConfigStore {
//   static const _prefix = 'connector_config:';

//   Future<void> save(String plantId, ConnectorConfig config) async {
//     final sp = await SharedPreferences.getInstance();
//     await sp.setString('$_prefix$plantId', jsonEncode(config.toJson()));
//   }

//   Future<ConnectorConfig?> load(String plantId) async {
//     final sp = await SharedPreferences.getInstance();
//     final s = sp.getString('$_prefix$plantId');
//     if (s == null) return null;
//     return ConnectorConfig.fromJson(jsonDecode(s) as Map<String, dynamic>);
//   }

//   Future<void> delete(String plantId) async {
//     final sp = await SharedPreferences.getInstance();
//     await sp.remove('$_prefix$plantId');
//   }
// }

// class DiscoveryResult {
//   final ConnectorConfig? config;
//   final String message;
//   const DiscoveryResult(this.config, this.message);
// }

// class DiscoveryService {
//   DiscoveryService({Duration? timeout})
//     : _timeout = timeout ?? const Duration(seconds: 8);

//   final Duration _timeout;
//   final _store = ConnectorConfigStore();

//   Future<DiscoveryResult> discoverAndSave({
//     required String plantId,
//     required String baseUrl,
//     String? username,
//     String? password,
//   }) async {
//     final cfg = await discover(
//       baseUrl: baseUrl,
//       username: username,
//       password: password,
//     );
//     if (cfg != null) {
//       await _store.save(plantId, cfg);
//       return DiscoveryResult(cfg, 'Found: ${cfg.mode.name}');
//     }
//     return const DiscoveryResult(null, 'No suitable endpoint found');
//   }

//   Future<ConnectorConfig?> discover({
//     required String baseUrl,
//     String? username,
//     String? password,
//   }) async {
//     final base = _normalizeBase(baseUrl);

//     // 1) JSON summary
//     for (final path in const ['api/summary', 'summary.json', 'status.json']) {
//       final u = _join(base, path);
//       final j = await _getJson(u, username, password);
//       if (_looksSummary(j)) {
//         final r = await _findReadings(base, username, password);
//         return ConnectorConfig(
//           mode: ConnectorMode.jsonApi,
//           summaryUrl: u,
//           readingsUrl: r,
//         );
//       }
//     }

//     // 2) Readings (JSON/CSV) が見つかればOK
//     final r = await _findReadings(base, username, password);
//     if (r != null) {
//       final mode =
//           r.endsWith('.csv') ? ConnectorMode.csv : ConnectorMode.jsonApi;
//       return ConnectorConfig(mode: mode, readingsUrl: r);
//     }

//     // 3) HTML（トップ）から現在値だけ抽出
//     final html = await _getText(base, username, password);
//     final power = _extractPowerFromHtml(html ?? '');
//     if (power != null) {
//       return ConnectorConfig(
//         mode: ConnectorMode.html,
//         htmlUrl: base,
//         htmlRegex: r'(現在|今|出力|power).{0,30}?([0-9]+(?:\.[0-9]+)?)\s*kW',
//       );
//     }

//     return null;
//   }

//   // ---- helpers ----

//   Future<String?> _findReadings(String base, String? u, String? p) async {
//     // JSON first
//     for (final path in const [
//       'api/readings',
//       'readings.json',
//       'data/readings.json',
//     ]) {
//       final url = _join(base, path);
//       final j = await _getJson(url, u, p);
//       if (_looksReadings(j)) return url;
//     }
//     // CSV next
//     for (final path in const [
//       'readings.csv',
//       'api/readings.csv',
//       'data/readings.csv',
//     ]) {
//       final url = _join(base, path);
//       final t = await _getText(url, u, p);
//       if (t != null && t.contains(',')) return url;
//     }
//     return null;
//   }

//   bool _looksSummary(Map<String, dynamic>? j) {
//     if (j == null) return false;
//     final v = j['power_kw'] ?? j['power'] ?? j['current_power'];
//     return v is num ||
//         (v is String && double.tryParse(v) != null) ||
//         j['summary'] is Map;
//   }

//   bool _looksReadings(Map<String, dynamic>? j) {
//     if (j == null) return false;
//     final a = j['readings'] ?? j['data'] ?? j['items'];
//     return a is List && a.isNotEmpty;
//   }

//   String _normalizeBase(String raw) {
//     var r = raw.trim();
//     if (!r.startsWith('http://') && !r.startsWith('https://')) r = 'https://$r';
//     if (!r.endsWith('/')) r = '$r/';
//     return r;
//   }

//   String _join(String base, String path) {
//     if (base.endsWith('/') && path.startsWith('/')) {
//       return base + path.substring(1);
//     }
//     if (!base.endsWith('/') && !path.startsWith('/')) {
//       return '$base/$path';
//     }
//     return base + path;
//   }

//   Future<Map<String, dynamic>?> _getJson(
//     String url,
//     String? user,
//     String? pass,
//   ) async {
//     try {
//       final headers = <String, String>{'Accept': 'application/json'};
//       if ((user ?? '').isNotEmpty || (pass ?? '').isNotEmpty) {
//         final auth = base64.encode(utf8.encode('${user ?? ''}:${pass ?? ''}'));
//         headers['Authorization'] = 'Basic $auth';
//       }
//       final res = await http
//           .get(Uri.parse(url), headers: headers)
//           .timeout(_timeout);
//       if (res.statusCode >= 200 &&
//           res.statusCode < 300 &&
//           res.body.isNotEmpty) {
//         final d = json.decode(res.body);
//         if (d is Map<String, dynamic>) return d;
//         if (d is List) return {'readings': d};
//       }
//     } on TimeoutException {
//     } on HandshakeException {
//     } on SocketException {
//     } catch (_) {}
//     return null;
//   }

//   Future<String?> _getText(String url, String? user, String? pass) async {
//     try {
//       final headers = <String, String>{'Accept': '*/*'};
//       if ((user ?? '').isNotEmpty || (pass ?? '').isNotEmpty) {
//         final auth = base64.encode(utf8.encode('${user ?? ''}:${pass ?? ''}'));
//         headers['Authorization'] = 'Basic $auth';
//       }
//       final res = await http
//           .get(Uri.parse(url), headers: headers)
//           .timeout(_timeout);
//       if (res.statusCode >= 200 && res.statusCode < 300) return res.body;
//     } on TimeoutException {
//     } on HandshakeException {
//     } on SocketException {
//     } catch (_) {}
//     return null;
//   }

//   double? _extractPowerFromHtml(String html) {
//     final s = html
//         .replaceAll(RegExp(r'[\r\n]+'), ' ')
//         .replaceAll('ｋＷ', 'kW')
//         .replaceAll('ＫＷ', 'kW');
//     final re = RegExp(
//       r'(現在|今|出力|power|Power|POWER).{0,30}?([0-9]+(?:\.[0-9]+)?)\s*kW',
//     );
//     final m = re.firstMatch(s);
//     if (m != null && m.groupCount >= 2) return double.tryParse(m.group(2)!);
//     final re2 = RegExp(r'([0-9]+(?:\.[0-9]+)?)\s*kW');
//     final m2 = re2.firstMatch(s);
//     if (m2 != null) return double.tryParse(m2.group(1)!);
//     return null;
//   }
// }
