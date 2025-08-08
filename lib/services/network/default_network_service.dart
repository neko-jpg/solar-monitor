import 'dart:async';
import 'network_service.dart';

class DefaultNetworkService implements NetworkService {
  @override
  Future<bool> testConnection({
    required String url,
    required String username,
    required String password,
  }) async {
    // TODO: v2で実HTTP実装に差し替え
    await Future.delayed(const Duration(milliseconds: 800));
    final okUrl = url.startsWith('http://') || url.startsWith('https://');
    final okCred = username.isNotEmpty && password.isNotEmpty;
    return okUrl && okCred; // モック：形式が正しければOK
  }
}
