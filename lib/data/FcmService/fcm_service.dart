import 'dart:convert';
import 'dart:developer';
import 'package:connectapp/res/api_urls/api_urls.dart';
import 'package:http/http.dart' as http;

class FCMService {
  static Future<void> registerFCMToken(
      String? fcmToken, String authToken) async {
    if (fcmToken == null || fcmToken.isEmpty) {
      return;
    }

    final url =
        Uri.parse('${ApiUrls.baseUrl}/connect/v1/api/user/update-fcm-token');

    try {
      final body = jsonEncode({
        'fcmToken': fcmToken,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        log('FCM Token registered successfully!');
      } else {
        log('Failed to register FCM Token (${response.statusCode}): ${response.body}');
      }
    } catch (e, st) {
      log('Error sending FCM token: $e');
      log('Stack trace: $st');
    }
  }
}
