import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NotificationService extends GetxService {
  
  /// 🛠️ Updated: Styles notifications to look like system alerts or texts
  void showNotification(String title, String body, {bool isUrgent = false}) {
    Get.snackbar(
      title.toUpperCase(),
      body,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      backgroundColor: isUrgent ? Colors.red.withOpacity(0.9) : Colors.black87,
      colorText: Colors.white,
      borderRadius: 0, // Makes it look like a sleek terminal alert
      margin: const EdgeInsets.all(0),
      icon: Icon(
        isUrgent ? Icons.warning_amber_rounded : Icons.message_outlined, 
        color: Colors.white70
      ),
    );
  }
}
