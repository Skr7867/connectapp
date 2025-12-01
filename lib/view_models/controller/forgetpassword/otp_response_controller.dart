import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/ForgetPassword/otp_response_model.dart';
import '../../../repository/ForgetPassword/otp_response_repository.dart';

class OtpResponseController extends GetxController {
  final emailController = TextEditingController().obs;
  final OtpResponseRepository _repository = OtpResponseRepository();
  var isLoading = false.obs;
  var otpResponse = Rxn<OtpResponse>();
  var errorMessage = ''.obs;

  Future<bool> sendOtp(String email) async {
    try {
      isLoading(true);
      errorMessage('');

      // Trim the email to remove leading/trailing whitespace
      final trimmedEmail = email.trim();
      final data = {'email': trimmedEmail};

      final response = await _repository.otpResponse(data);
      // log('Raw response: $response');

      if (response.containsKey('message') &&
          response['message'] == 'OTP sent to your email.') {
        otpResponse.value = OtpResponse.fromJson(response);
        Get.snackbar(
          'Success',
          'OTP sent successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return true;
      } else {
        errorMessage(response['message'] ?? 'Failed to send OTP');
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to send OTP',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      print('Error in sendOtp: $e');
      errorMessage('Failed to send OTP: $e');
      Get.snackbar(
        'Error',
        'Failed to send OTP: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      return false;
    } finally {
      isLoading(false);
    }
  }
}
