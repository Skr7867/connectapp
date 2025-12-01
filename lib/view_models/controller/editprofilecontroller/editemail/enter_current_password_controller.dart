// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../repository/UpdateProfile/UpdateEmail/enter_current_password_repository.dart';
import '../../../../res/routes/routes_name.dart';
import '../../userPreferences/user_preferences_screen.dart';

class EnterCurrentPasswordController extends GetxController {
  final EnterCurrentPasswordRepository _repository =
      EnterCurrentPasswordRepository();
  final UserPreferencesViewmodel _userPreferences = UserPreferencesViewmodel();
  final currentPasswordController = TextEditingController().obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isPasswordVerified = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize SharedPreferences when the controller is created
    _userPreferences.init();
  }

  Future<void> verifyCurrentPassword(String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Fetch the token from UserPreferencesViewmodel
      final user = await _userPreferences.getUser();
      if (user == null || user.token == null) {
        errorMessage.value =
            'Authentication token not found. Please log in again.';
        Get.offAllNamed(RouteName.loginScreen);
        return;
      }

      final Map<String, dynamic> data = {
        "password": password,
      };

      // Pass the token to the repository
      final response =
          await _repository.enterCurrentPassword(data, token: user.token);

      if (response != null && response['status'] == true) {
        isPasswordVerified.value = true;
      } else {
        errorMessage.value =
            response?['message'] ?? 'Password verification failed';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      isPasswordVerified.value = false;
    } finally {
      isLoading.value = false;
    }
  }
}
