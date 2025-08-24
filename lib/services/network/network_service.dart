import 'package:dio/dio.dart';

abstract class NetworkService {
  Future<Response<T>> getJson<T>(Uri url);
  Future<Response<T>> getText<T>(Uri url);
  Future<void> persistCookies(Uri base);
  Future<void> restoreCookies(Uri base);
  Future<void> login(Uri baseUrl, String username, String password);
}
