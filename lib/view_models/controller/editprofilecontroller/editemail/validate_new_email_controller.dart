import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../repository/UpdateProfile/UpdateEmail/validate_email_repository.dart';
import '../../../../res/routes/routes_name.dart';
import '../../userPreferences/user_preferences_screen.dart';

class ValidateEmailController extends GetxController {
  final ValidateEmailRepository _repository = ValidateEmailRepository();
  final UserPreferencesViewmodel _userPreferences = UserPreferencesViewmodel();
  final newEmailController = TextEditingController().obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isEmailValidated = false.obs;

  @override
  void onInit() {
    super.onInit();
    _userPreferences.init();
  }

  Future<void> validateNewEmail(String newEmail) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await _userPreferences.getUser();
      if (user == null) {
        errorMessage.value =
            'Authentication token not found. Please log in again.';
        Get.snackbar('Error', errorMessage.value,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP);
        Get.offAllNamed(RouteName.loginScreen);
        return;
      }

      final Map<String, dynamic> data = {
        "newEmail": newEmail,
      };

      final response = await _repository.validateEmail(data, token: user.token);

      if (response != null && response['message'] == true) {
        isEmailValidated.value = true;
        Get.snackbar('Success', 'Email validated successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP);
      } else {
        errorMessage.value = response?['message'] ?? 'Email validation failed';
        Utils.snackBar(
          errorMessage.value,
          'Info',
        );
      }
    } catch (e) {
      errorMessage.value = e.toString().contains('FetchDataException')
          ? e.toString().split(': ').last
          : 'Unexpected error occurred';
      Get.snackbar('Error', errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      isEmailValidated.value = false;
    } finally {
      isLoading.value = false;
    }
  }
}
