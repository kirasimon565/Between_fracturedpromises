import 'package:get/get.dart';

class NotificationService extends GetxService {
  // Placeholder for local notifications
  // In a real app, use `flutter_local_notifications`

  void showNotification(String title, String body) {
    print("NOTIFICATION: $title - $body");
    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 3),
      backgroundColor: Get.theme.cardColor.withOpacity(0.9),
      colorText: Get.theme.textTheme.bodyLarge?.color,
    );
  }
}
