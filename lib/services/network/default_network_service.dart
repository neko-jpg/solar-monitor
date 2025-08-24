import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../storage/secure_cookie_store.dart';
import '../../core/exceptions.dart'; // Will create this next

class DefaultNetworkService {
  final Dio _dio;
  final CookieJar _jar;
  final SecureCookieStore _sec;

  DefaultNetworkService._(this._dio, this._jar, this._sec);

  static Future<DefaultNetworkService> create({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final dio = Dio(BaseOptions(
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: {'User-Agent': 'SolarTrack/1.0'},
    ));
    final jar = CookieJar();
    final sec = SecureCookieStore();
    dio.interceptors.add(CookieManager(jar));
    // Add an interceptor for logging/error handling later if needed
    return DefaultNetworkService._(dio, jar, sec);
  }

  /// Performs a login request and persists the cookies upon success.
  Future<void> login(Uri baseUrl, String username, String password) async {
    try {
      // Assume login endpoint is at the base URL path
      final response = await _dio.postUri(
        baseUrl,
        data: {'username': username, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode != 200) {
        throw AuthException('Login failed: Invalid status code ${response.statusCode}');
      }

      // Persist cookies on successful login
      await persistCookies(baseUrl);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw AppException('An unknown login error occurred: $e');
    }
  }

  /// Makes a GET request, automatically handling cookie restoration.
  Future<Response<T>> get<T>(Uri url) async {
    try {
      await restoreCookies(url);
      final response = await _dio.get<T>(url.toString());
      return response;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      throw AppException('An unknown GET error occurred: $e');
    }
  }

  /// Saves cookies from the jar to secure storage for a given host.
  Future<void> persistCookies(Uri base) async {
    final cookies = await _jar.loadForRequest(base);
    if (cookies.isNotEmpty) {
      final map = {for (final c in cookies) c.name: c.value};
      await _sec.save(base.host, map);
    }
  }

  /// Loads cookies from secure storage into the jar for a given host.
  Future<void> restoreCookies(Uri base) async {
    final saved = await _sec.load(base.host);
    if (saved.isNotEmpty) {
      final cookies = saved.entries.map((e) => Cookie(e.key, e.value)).toList();
      await _jar.saveFromResponse(base, cookies);
    }
  }
}
