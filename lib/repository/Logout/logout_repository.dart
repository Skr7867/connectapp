import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:connectapp/res/api_urls/api_urls.dart';

class LogoutRepository {
  Future<dynamic> logoutUser(String token) async {
    final url = Uri.parse(ApiUrls.logoutApi);

    log("POST DATA: $url");
    log("🔑 Logging out with token: $token");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      log("Response Code: ${response.statusCode}");
      log("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        log("❌ Unauthorized: Token expired or invalid");
        throw Exception("Unauthorized: Token expired or invalid");
      } else {
        throw Exception("Logout failed: ${response.body}");
      }
    } catch (e) {
      log("❌ Logout failed: Unexpected error: $e");
      rethrow;
    }
  }
}
