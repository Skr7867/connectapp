import 'dart:developer';

import 'package:connectapp/res/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectapp/models/2FA/two_fa_model.dart';
import '../../../data/2FA/http_services.dart';
import '../../../utils/utils.dart';

class TwoFAController extends GetxController {
  final HttpService _httpService = HttpService();
  var qrCode = ''.obs;
  var secretKey = ''.obs;
  var isLoading = false.obs;
  var otpSent = false.obs;
  var isSetupComplete = false.obs;
  var errorMessage = ''.obs;

  Future<bool> _validateToken(String token) async {
    try {
      await _httpService
          .getApi('/connect/v1/api/user/profile', token: token)
          .timeout(const Duration(seconds: 5));
      // log('Token validated successfully');
      return true;
    } catch (e) {
      // log('Token validation failed: $e');
      return false;
    }
  }

  Future<void> fetchQrCode(String token) async {
    try {
      isLoading.value = true;
      if (!await _validateToken(token)) {
        throw Exception('Invalid or expired token');
      }
      final response = await _httpService
          .getApi(
            '/connect/v1/api/user/2fa/authenticator/setup',
            token: token,
          )
          .timeout(const Duration(seconds: 10));
      final qrCodeModel = TwoFAQrCodeModel.fromJson(response);
      qrCode.value = qrCodeModel.qrCode ?? '';
      secretKey.value = qrCodeModel.secretKey ?? '';
      if (qrCode.value.isEmpty) {
        throw Exception('QR code data is empty');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      if (e.toString().contains('2FA is already enabled')) {
        Utils.snackBar('2FA is already enabled', 'Info');
      } else {
        Get.snackbar('Error', '$e',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            isDismissible: true);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOtp(String token, String method) async {
    try {
      isLoading.value = true;
      if (!await _validateToken(token)) {
        throw Exception('Invalid or expired token');
      }
      final endpoint = method == 'email'
          ? '/connect/v1/api/user/2fa/email/send-otp'
          : '/connect/v1/api/user/2fa/sms/send-otp';
      await _httpService
          .postApi(endpoint, {}, token: token)
          .timeout(const Duration(seconds: 10));
      otpSent.value = true;
      Get.snackbar('Success', 'OTP sent to your $method',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5));
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to send OTP: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String token, String code, String method) async {
    try {
      isLoading.value = true;
      if (!await _validateToken(token)) {
        throw Exception('Invalid or expired token. Please log in again.');
      }

      final endpoint = method == 'authenticator'
          ? '/connect/v1/api/user/2fa/authenticator/verify'
          : method == 'email'
              ? '/connect/v1/api/user/2fa/email/verify'
              : '/connect/v1/api/user/2fa/sms/verify';

      final Map<String, dynamic> body;

      if (method == 'authenticator') {
        body = {'token': code};
      } else {
        body = {'otp': code};
      }

      // log('Verifying OTP: endpoint=$endpoint, payload=$body, token=${token.substring(0, 10)}...');

      final response = await _httpService
          .postApi(
            endpoint,
            body,
            token: token,
          )
          .timeout(const Duration(seconds: 10));

      log('Verification response: $response');
      isSetupComplete.value = true;
      Get.snackbar('Success', '2FA enabled successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
          isDismissible: true);
    } catch (e) {
      errorMessage.value = e.toString();
      // log('Verification error: $e');
      String errorMsg = 'Verification failed: $e';
      if (e.toString().contains('400')) {
        errorMsg = 'Invalid OTP code or token. Please check and try again.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMsg =
            'Request timed out. Please check your network and try again.';
      }
      Get.snackbar('Error', errorMsg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          isDismissible: true,
          overlayBlur: 2);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTwoFactorSettings(String token, String method) async {
    try {
      isLoading.value = true;
      if (!await _validateToken(token)) {
        throw Exception('Invalid or expired token');
      }
      final response = await _httpService
          .patchApi(
            '/connect/v1/api/user/settings/update-two-factor-auth-setting',
            {'method': method},
            token: token,
          )
          .timeout(const Duration(seconds: 10));
      if (response['message'] == '2FA method set. Now verify to enable.') {
        // log('2FA method set successfully, awaiting verification');
      } else {
        throw Exception(response['message'] ?? 'Failed to set 2FA method');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      // log('Error updating 2FA settings: $e');
      if (!e.toString().contains('2FA method set')) {
        Get.snackbar('Error', 'Failed to update 2FA settings: $e',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5));
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> is2FAEnabled(String token) async {
    try {
      final response = await _httpService
          .getApi(
            '/connect/v1/api/user/profile',
            token: token,
          )
          .timeout(const Duration(seconds: 10));
      final twoFactorEnabled =
          response['settings']?['twoFactorAuth']?['enabled'] ?? false;
      isSetupComplete.value = twoFactorEnabled;
      // log('2FA enabled status: $twoFactorEnabled');
      return twoFactorEnabled;
    } catch (e) {
      // log('Error checking 2FA status: $e');
      return false;
    }
  }

  Future<void> disable2FA(String token, String password) async {
    try {
      isLoading.value = true;
      if (!await _validateToken(token)) {
        throw Exception('Invalid or expired token');
      }
      if (password.isEmpty) {
        throw Exception('Please enter your password to disable 2FA');
      }
      final response = await _httpService
          .patchApi(
            '/connect/v1/api/user/2fa/disable',
            {'password': password},
            token: token,
          )
          .timeout(const Duration(seconds: 10));
      if (response['message'] != '2FA has been disabled successfully') {
        throw Exception(response['message'] ?? 'Failed to disable 2FA');
      }
      isSetupComplete.value = false;
      Utils.snackBar('2FA has been disabled successfully', 'Success');
      Get.toNamed(RouteName.settingScreen);
    } catch (e) {
      errorMessage.value = e.toString();
      // log('Error disabling 2FA: $e');
      String errorMsg = e.toString();
      if (e.toString().contains('400')) {
        errorMsg = 'Invalid password. Please check and try again.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMsg =
            'Request timed out. Please check your network and try again.';
      } else if (e.toString().contains('Invalid or expired token')) {
        errorMsg = 'Session expired. Please log in again.';
      }
      Get.snackbar('Error', errorMsg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          isDismissible: true);
    } finally {
      isLoading.value = false;
    }
  }
}
