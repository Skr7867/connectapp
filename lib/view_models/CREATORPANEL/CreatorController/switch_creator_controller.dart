import 'dart:convert';
import 'dart:developer';
import 'package:connectapp/models/UserProfile/user_profile_model.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../res/routes/routes_name.dart';
import '../../controller/profile/user_profile_controller.dart';
import '../../controller/userPreferences/user_preferences_screen.dart';

class CreatorModeController extends GetxController {
  final isCreatorMode = false.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    final userData = Get.find<UserProfileController>();
    isCreatorMode.value = userData.userList.value.role == "Creator";
  }

  Future<void> toggleCreatorMode() async {
    try {
      isLoading.value = true;

      final token = await UserPreferencesViewmodel().getToken();

      if (token == null || token.isEmpty) {
        Get.snackbar(
          "Error",
          "User not logged in.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final response = await http.patch(
        Uri.parse(
          "${ApiUrls.baseUrl}/connect/v1/api/creator/toggle-creator-role",
        ),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      log("Toggle API Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String? newRole = data["role"];

        if (newRole == null && data["message"] is String) {
          final message = data["message"].toString().toLowerCase();
          if (message.contains("creator")) {
            newRole = "Creator";
          } else if (message.contains("user")) {
            newRole = "User";
          }
        }

        final prefs = await SharedPreferences.getInstance();

        if (newRole != null) {
          await prefs.setString("userRole", newRole);

          isCreatorMode.value = newRole == "Creator";

          final updatedProfileResponse = await http.get(
            Uri.parse("${ApiUrls.baseUrl}/connect/v1/api/user/profile"),
            headers: {"Authorization": "Bearer $token"},
          );

          if (updatedProfileResponse.statusCode == 200) {
            final jsonResponse = jsonDecode(updatedProfileResponse.body);
            final userProfile = UserProfileModel.fromJson(jsonResponse);

            await UserPreferencesViewmodel().saveUserProfile(userProfile);

            Get.find<UserProfileController>();
          }

          if (newRole == "Creator") {
            Get.offAllNamed(RouteName.creatorBottomBar);
          } else if (newRole == "User") {
            Get.offAllNamed(RouteName.bottomNavbar);
          }

          Get.snackbar(
            "Success",
            "Switched to $newRole mode.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          log("⚠️ toggleCreatorRole response missing role field. Using fallback.");

          await prefs.setString("userRole", "User");
          isCreatorMode.value = false;

          Get.offAllNamed(RouteName.bottomNavbar);

          Get.snackbar(
            "Success",
            data["message"] ?? "Switched mode.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to toggle creator mode.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log("Toggle creator mode error: $e");
      Get.snackbar(
        "Error",
        "Something went wrong.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
