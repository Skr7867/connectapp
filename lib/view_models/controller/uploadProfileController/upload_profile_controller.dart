import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';

import '../../../repository/UploadProfile/upload_profile_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class UploadProfileController extends GetxController {
  final UploadProfileRepository _repository = UploadProfileRepository();
  final UserPreferencesViewmodel _prefs = UserPreferencesViewmodel();

  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxBool uploadSuccess = false.obs;

  /// ⭐ Add this
  Rx<File?> selectedImage = Rx<File?>(null);

  /// Upload Profile Image
  Future<void> uploadProfile(dynamic data, {File? file}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      uploadSuccess.value = false;

      /// Show image instantly
      if (file != null) {
        selectedImage.value = file;
      }

      String? token = await _prefs.getToken();

      if (token == null || token.isEmpty) {
        errorMessage.value = "User token not found.";
        return;
      }

      final response = await _repository.uploadProfileApi(token, data);

      log("UPLOAD RESPONSE: $response");

      uploadSuccess.value = true;

      Get.snackbar("Success", "Profile uploaded successfully");
    } catch (e) {
      log("UPLOAD ERROR: $e");
      errorMessage.value = e.toString();
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
