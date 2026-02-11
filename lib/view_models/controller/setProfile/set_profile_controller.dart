import 'dart:developer';
import 'package:get/get.dart';

import '../../../repository/SetProfile/set_profile_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class SetProfileController extends GetxController {
  final SetProfileRepository _repository = SetProfileRepository();
  final UserPreferencesViewmodel _prefs = UserPreferencesViewmodel();

  /// Loading
  RxBool isLoading = false.obs;

  /// Error
  RxString errorMessage = ''.obs;

  /// Success
  RxBool isSuccess = false.obs;

  /// ⭐ Selected Active Profile (Single Value Now)
  RxString selectedProfile = "".obs;

  /// Select profile
  void selectProfile(String profile) {
    selectedProfile.value = profile;
    log("Selected Profile: ${selectedProfile.value}");
  }

  /// Set Active Profile API Call
  Future<void> setActiveProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      isSuccess.value = false;

      /// Get Token
      String? token = await _prefs.getToken();

      if (token == null || token.isEmpty) {
        errorMessage.value = "User token not found.";
        return;
      }

      /// ⭐ API Body (Single String)
      final body = {
        "activeProfile": selectedProfile.value,
      };

      log("SET PROFILE BODY: $body");

      /// Call API
      final response = await _repository.setProfileApi(token, body);

      log("SET PROFILE RESPONSE: $response");

      isSuccess.value = true;

      Get.snackbar("Success", "Active profile updated");
    } catch (e) {
      log("SET PROFILE ERROR: $e");
      errorMessage.value = e.toString();
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
