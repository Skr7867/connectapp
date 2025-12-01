import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_settings/app_settings.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log("✅ User granted full permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log("⚠️ User granted provisional permission");
    } else {
      log("❌ User denied permission, opening settings...");
      AppSettings.openAppSettings();
    }
  }
}
