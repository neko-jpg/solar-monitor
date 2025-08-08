abstract class NetworkService {
  /// 資格情報付きでURLにアクセスできるか（MVPはHTTP 200想定のモック）
  Future<bool> testConnection({
    required String url,
    required String username,
    required String password,
  });
}
