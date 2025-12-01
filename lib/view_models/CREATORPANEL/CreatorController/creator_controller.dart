import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../res/api_urls/api_urls.dart';
import 'package:http/http.dart' as http;
import '../../controller/userPreferences/user_preferences_screen.dart';

class CreatorController extends GetxController {
  final isRequestSubmitted = false.obs;
  final isLoading = false.obs;

  Future<void> becomeCreator({required String reason}) async {
    try {
      isLoading.value = true;

      final token = await UserPreferencesViewmodel().getToken();

      if (token == null || token.isEmpty) {
        isLoading.value = false;
        Get.snackbar(
          "Error",
          "User not logged in.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final response = await http.post(
        Uri.parse("${ApiUrls.baseUrl}/connect/v1/api/creator/become-a-creator"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "creatorRequestReason": reason,
        }),
      );

      log("API Response: ${response.statusCode} ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        isRequestSubmitted.value = true;
        Get.snackbar(
          "Success",
          "Request submitted. Wait for admin approval.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else if (response.statusCode == 400 &&
          responseData["message"] ==
              "You have already submitted a creator request") {
        isRequestSubmitted.value = true;
        Get.snackbar(
          "Info",
          "You have already submitted a creator request.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Info",
          responseData["message"] ?? "Something went wrong.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log("Error submitting creator request: $e");
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
