import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/ForgetPassword/otp_verification_response.model.dart';
import '../../../repository/ForgetPassword/verify_otp_response_repository.dart';

class OtpVerificationController extends GetxController {
  final otpController = TextEditingController().obs;
  final OtpVerificationRepository _repository = OtpVerificationRepository();
  var isLoading = false.obs;
  var verificationResponse = Rxn<OtpVerificationResponse>();
  var errorMessage = ''.obs;

  Future<bool> verifyOtp(String otp, {String? email}) async {
    try {
      isLoading(true);
      errorMessage('');

      final trimmedOtp = otp.trim();

      final data = {
        'otp': trimmedOtp,
        if (email != null) 'email': email.trim(),
      };
      // log('Sending OTP verification request: $data');
      final response = await _repository.verifyOtp(data);
      // log('Raw response: $response');

      if (response.containsKey('message') &&
          response['message'] == 'OTP verified successfully') {
        verificationResponse.value = OtpVerificationResponse.fromJson(response);
        Get.snackbar(
          'Success',
          'OTP verified successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return true;
      } else {
        errorMessage(response['message'] ?? 'Failed to verify OTP');
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to verify OTP',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      // log('Error in verifyOtp: $e');
      errorMessage('Failed to verify OTP: $e');
      Get.snackbar(
        'Error',
        'Failed to verify OTP: $e',
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
