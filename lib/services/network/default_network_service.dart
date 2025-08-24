import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../storage/secure_cookie_store.dart';
import '../../core/exceptions.dart';
import 'network_service.dart';

class DefaultNetworkService implements NetworkService {
  final Dio _dio; final CookieJar _jar; final SecureCookieStore _sec;
  DefaultNetworkService._(this._dio, this._jar, this._sec);

  static Future<DefaultNetworkService> create({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final dio = Dio(BaseOptions(
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: { 'Accept': 'application/json, text/plain, */*' },
    ));
    final jar = CookieJar();
    final sec = SecureCookieStore();
    dio.interceptors.add(CookieManager(jar));
    return DefaultNetworkService._(dio, jar, sec);
  }

  @override
  Future<Response<T>> getJson<T>(Uri url) async {
    await restoreCookies(url);
    try {
      final res = await _dio.get<T>(url.toString());
      await persistCookies(url);
      return res;
    } on DioException catch (e) { throw _convertDioError(e); }
  }

  @override
  Future<Response<T>> getText<T>(Uri url) async {
    await restoreCookies(url);
    try {
      final res = await _dio.get<T>(url.toString(), options: Options(responseType: ResponseType.plain));
      await persistCookies(url);
      return res;
    } on DioException catch (e) { throw _convertDioError(e); }
  }

  @override
  Future<void> login(Uri baseUrl, String username, String password) async {
    // 任意：必要になったら POST 実装
    // await _dio.post('${baseUrl}/login', data: {...});
  }

  @override
  Future<void> persistCookies(Uri base) async {
    final cookies = await _jar.loadForRequest(base);
    final map = <String, String>{ for (final c in cookies) c.name : c.value };
    await _sec.save(base.host, map);
  }

  @override
  Future<void> restoreCookies(Uri base) async {
    final map = await _sec.load(base.host);
    if (map.isEmpty) return;
    final list = map.entries.map((e) => Cookie(e.key, e.value)).toList();
    await _jar.saveFromResponse(base, list);
  }

  AppException _convertDioError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout || DioExceptionType.sendTimeout || DioExceptionType.receiveTimeout
        => AppException(AppExceptionKind.timeout, 'Connection timed out.'),
      DioExceptionType.badResponse when e.response?.statusCode == 401
        => AppException(AppExceptionKind.auth, 'Authentication failed.'),
      DioExceptionType.badResponse
        => AppException(AppExceptionKind.server, 'Server error: ${e.response?.statusCode}'),
      DioExceptionType.connectionError
        => AppException(AppExceptionKind.dns, 'Connection error. Check network or hostname.'),
      _ => AppException(AppExceptionKind.unknown, 'An unknown network error occurred.', e),
    };
  }
}
