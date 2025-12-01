import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../repository/UpdateProfile/UpdateEmail/verify_otp_email_repository.dart';
import '../../../../res/routes/routes_name.dart';
import '../../userPreferences/user_preferences_screen.dart';

class VerifyOtpEmailController extends GetxController {
  final VerifyOtpEmailRepository _repository = VerifyOtpEmailRepository();
  final UserPreferencesViewmodel _userPreferences = UserPreferencesViewmodel();
  final otpController = TextEditingController().obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isOtpVerified = false.obs;

  @override
  void onInit() {
    super.onInit();
    _userPreferences.init();
  }

  Future<void> verifyOtpEmail(String otp, String newEmail) async {
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
        "otp": otp,
        "newEmail": newEmail,
      };

      final response =
          await _repository.verifyOtpEmail(data, token: user.token);

      // Adjust based on your API's success response (e.g., {"message": "OTP verified"})
      if (response != null &&
          response['message']?.toLowerCase().contains('verified') == true) {
        isOtpVerified.value = true;
        Get.snackbar('Success', 'OTP verified successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP);
      } else {
        errorMessage.value = response?['message'] ?? 'OTP verification failed';
        Get.snackbar('Error', errorMessage.value,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      String error = e.toString();
      if (error.contains('FetchDataException')) {
        errorMessage.value = error
            .split(': ')
            .last; // Extract message like "Invalid or expired OTP"
      } else {
        errorMessage.value = 'An error occurred: $error';
      }
      Get.snackbar('Error', errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      isOtpVerified.value = false;
    } finally {
      isLoading.value = false;
    }
  }
}
