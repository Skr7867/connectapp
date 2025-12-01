import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/ForgetPassword/reset_password_model.dart';
import '../../../repository/ForgetPassword/reset_password_repository.dart';

class ResetPasswordController extends GetxController {
  final passwordController = TextEditingController().obs;
  final confirmPasswordController = TextEditingController().obs;
  final ResetPasswordRepository _repository = ResetPasswordRepository();
  var isLoading = false.obs;
  var resetResponse = Rxn<ResetPasswordResponse>();
  var errorMessage = ''.obs;
  @override
  void onClose() {
    passwordController.value.dispose();
    super.onClose();
  }

  Future<bool> resetPassword(
      String email, String otp, String newPassword) async {
    try {
      isLoading(true);
      errorMessage('');

      final data = {
        'email': email.trim(),
        'otp': otp.trim(),
        'newPassword': newPassword.trim(),
      };

      print('Sending reset password request: $data');
      final response = await _repository.resetPassword(data);
      print('Raw response: $response');

      if (response.containsKey('message') &&
          response['message'] == 'Password reset successfully') {
        resetResponse.value = ResetPasswordResponse.fromJson(response);
        Get.snackbar(
          'Success',
          'Password reset successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return true;
      } else {
        errorMessage(response['message'] ?? 'Failed to reset password');
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to reset password',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      print('Error in resetPassword: $e');
      errorMessage('Failed to reset password: $e');
      Get.snackbar(
        'Error',
        'Failed to reset password: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isLoading(false);
    }
  }
}
