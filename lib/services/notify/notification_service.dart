abstract class NotificationService {
  Future<void> init();
  Future<void> notifyNow({required String title, required String body});
}
