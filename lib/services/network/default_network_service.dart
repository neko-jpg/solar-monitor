// lib/services/network/default_network_service.dart（置換用）
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'network_service.dart';

class DefaultNetworkService implements NetworkService {
  DefaultNetworkService({Duration? timeout})
    : _timeout = timeout ?? const Duration(seconds: 8);

  final Duration _timeout;

  @override
  Future<bool> testConnection({
    required String url,
    String? username,
    String? password,
  }) async {
    // URL整形（スキーム補完）
    Uri uri;
    try {
      uri = Uri.parse(url.trim());
      if (!uri.hasScheme) {
        uri = Uri.parse('https://$url');
      }
    } catch (_) {
      return false;
    }

    try {
      final headers = <String, String>{'Accept': 'text/html,application/json'};
      if ((username ?? '').isNotEmpty || (password ?? '').isNotEmpty) {
        final auth = base64.encode(
          utf8.encode('${username ?? ''}:${password ?? ''}'),
        );
        headers['Authorization'] = 'Basic $auth';
      }

      final res = await http.get(uri, headers: headers).timeout(_timeout);
      return res.statusCode >= 200 && res.statusCode < 300;
    } on HandshakeException {
      // SSL
      return false;
    } on SocketException {
      // DNS/接続不可
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
