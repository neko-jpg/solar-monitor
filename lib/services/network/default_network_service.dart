import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../storage/secure_cookie_store.dart';

class DefaultNetworkService {
  final Dio _dio; final CookieJar _jar; final SecureCookieStore _sec;
  DefaultNetworkService._(this._dio, this._jar, this._sec);

  static Future<DefaultNetworkService> create({Duration timeout = const Duration(seconds: 8)}) async {
    final dio = Dio(BaseOptions(
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: {'User-Agent': 'SolarMonitor/1.0'},
    ));
    final jar = CookieJar();
    final sec = SecureCookieStore();
    dio.interceptors.add(CookieManager(jar));
    return DefaultNetworkService._(dio, jar, sec);
  }

  Future<Response<T>> getJson<T>(Uri url) => _dio.get<T>(url.toString());

  /// 初回ログイン後のCookieを安全保存
  Future<void> persistCookies(Uri base) async {
    final cookies = await _jar.loadForRequest(base);
    final map = { for (final c in cookies) c.name: c.value };
    await _sec.save(base.host, map);
  }

  /// 2回目以降：保存Cookieを復元
  Future<void> restoreCookies(Uri base) async {
    final saved = await _sec.load(base.host);
    if (saved.isEmpty) return;
    final cookies = saved.entries.map((e) => Cookie(e.key, e.value)).toList();
    await _jar.saveFromResponse(base, cookies);
  }
}
