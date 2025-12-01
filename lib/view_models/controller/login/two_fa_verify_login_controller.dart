import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/UserLogin/user_login_model.dart';
import '../../../models/UserProfile/user_profile_model.dart';
import '../../../res/api_urls/api_urls.dart';
import '../../../res/routes/routes_name.dart';
import '../userPreferences/user_preferences_screen.dart';

class TwoFaVerifyLoginController extends GetxController {
  final otpController = TextEditingController().obs;
  RxBool isLoading = false.obs;
  var errorMessage = ''.obs;

  final UserPreferencesViewmodel _userPreferencesViewmodel =
      UserPreferencesViewmodel();

  Future<void> verifyOtp() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final tempToken = prefs.getString('tempToken') ?? '';

      if (tempToken.isEmpty) {
        errorMessage.value = 'No temporary token found';
        Utils.snackBar(errorMessage.value.tr, 'Error');
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiUrls.baseUrl}/connect/v1/api/user/verify/2fa-login'),
        headers: {
          'Authorization': 'Bearer $tempToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'otp': otpController.value.text.trim()}),
      );

      // log('Verify OTP Response: ${response.statusCode} ${response.body}');

      if (response.headers['content-type']?.contains('application/json') ??
          false) {
        final jsonResponse = jsonDecode(response.body);

        if (response.statusCode == 200) {
          if (jsonResponse['message'] == '2FA verification successful' ||
              jsonResponse['message'] ==
                  '2FA verified. Logged in successfully.') {
            await handleSuccessfulVerification(jsonResponse, prefs);
            return; // Add this to exit after successful handling
          } else {
            errorMessage.value = jsonResponse['message'] ?? 'Invalid OTP';
            Utils.snackBar(errorMessage.value.tr, 'Error');
          }
        } else {
          errorMessage.value = jsonResponse['message'] ?? 'Verification failed';
          Utils.snackBar(errorMessage.value.tr, 'Error');
        }
      } else {
        errorMessage.value = 'Server returned unexpected response';
        Utils.snackBar(errorMessage.value.tr, 'Error');
      }
    } catch (e) {
      errorMessage.value = 'Verification failed. Please try again.';
      Utils.snackBar(errorMessage.value.tr, 'Error');
      // log('OTP Verification Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleSuccessfulVerification(
      Map<String, dynamic> jsonResponse, SharedPreferences prefs) async {
    try {
      final loginResponse = LoginResponseModel.fromJson(jsonResponse);

      // Save final token
      await prefs.setString('userToken', loginResponse.token);
      await _userPreferencesViewmodel.saveUser(loginResponse);

      // Fetch and save profile
      final profileResponse = await http.get(
        Uri.parse('${ApiUrls.baseUrl}/connect/v1/api/user/profile'),
        headers: {'Authorization': 'Bearer ${loginResponse.token}'},
      );

      if (profileResponse.statusCode == 200) {
        final profileJson = jsonDecode(profileResponse.body);
        final userProfile = UserProfileModel.fromJson(profileJson);
        await _userPreferencesViewmodel.saveUserProfile(userProfile);
      } else {
        // log('Failed to fetch profile: ${profileResponse.statusCode}');
        Utils.snackBar(
            'Logged in, but failed to fetch profile data', 'Warning');
      }

      await prefs.remove('tempToken');
      Utils.snackBar('User Login Successful', 'Success');

      // Ensure navigation happens

      Get.offAllNamed(RouteName.bottomNavbar);
    } catch (e) {
      Utils.snackBar('Error completing login process', 'Error');
    }
  }

  @override
  void onClose() {
    otpController.value.dispose();
    super.onClose();
  }
}
