import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureCookieStore {
  final _store = const FlutterSecureStorage();
  String _key(String host) => 'cookie_$host';

  Future<void> save(String host, Map<String, String> cookies) async {
    await _store.write(key: _key(host), value: jsonEncode(cookies));
  }
  Future<Map<String, String>> load(String host) async {
    final v = await _store.read(key: _key(host));
    if (v == null) return {};
    final map = (jsonDecode(v) as Map).cast<String, dynamic>();
    return map.map((k, v) => MapEntry(k, v as String));
  }
  Future<void> clear(String host) => _store.delete(key: _key(host));
}
