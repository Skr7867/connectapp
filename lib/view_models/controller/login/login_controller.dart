import 'dart:developer';

import 'package:connectapp/models/2FA/two_fa_login_response_model.dart';
import 'package:connectapp/repository/UserLogin/two_fa_login_repository.dart';
import 'package:connectapp/res/api_urls/api_urls.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:connectapp/view_models/controller/userPreferences/user_preferences_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/UserLogin/user_login_model.dart';
import '../../../repository/UserLogin/user_login_repository.dart';
import '../../../res/routes/routes_name.dart';
import '../profile/user_profile_controller.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController().obs;
  final passwordController = TextEditingController().obs;
  final nameController = TextEditingController().obs;

  RxBool isLoading = false.obs;
  final isGoogleLoading = false.obs;

  var errorMessage = ''.obs;

  final UserLoginRepository _userLoginRepository = UserLoginRepository();
  final TwoFaLoginRepository _twoFaLoginRepository = TwoFaLoginRepository();
  final UserPreferencesViewmodel _userPreferencesViewmodel =
      UserPreferencesViewmodel();

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    try {
      final userData = await _userPreferencesViewmodel.getUser();
      if (userData != null && userData.token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('userToken') ?? userData.token;
        final profileResponse = await http.get(
          Uri.parse('${ApiUrls.baseUrl}/connect/v1/api/user/profile'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (profileResponse.statusCode == 200) {
          Get.offAllNamed(RouteName.bottomNavbar);
        } else {
          await _userPreferencesViewmodel.removeUser();
          await _userPreferencesViewmodel.removeUserProfile();
          await prefs.remove('userToken');
        }
      }
    } catch (e) {
      // log('Error checking login status: $e');
    }
  }

  Future<void> loginUser() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final loginRequest = LoginRequestModel(
        email: emailController.value.text.trim(),
        password: passwordController.value.text.trim(),
      );

      // First try normal login
      try {
        final response =
            await _userLoginRepository.userLoginModel(loginRequest.toJson());
        final loginResponse = LoginResponseModel.fromJson(response);

        if (loginResponse.message == 'User logged in successfully') {
          await handleSuccessfulLogin(loginResponse);
          return;
        }
      } catch (e) {
        // log('Normal login attempt failed: $e');

        Utils.snackBar('Invalid email Or Password', 'Network Error');
      }

      // If normal login fails, try 2FA check
      try {
        final twoFaresponse = await _twoFaLoginRepository
            .twofauserLoginModel(loginRequest.toJson());

        // log('2FA Response: $twoFaresponse');

        final twofaLoginResponse =
            TwofaLoginResponseModel.fromJson(twoFaresponse);

        if (twofaLoginResponse.message
                ?.toLowerCase()
                .contains('authenticator') ??
            false) {
          // log('Redirecting to 2FA screen');

          // Save temp token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'tempToken', twofaLoginResponse.tempToken ?? '');
          await prefs.setString('2faMethod', twofaLoginResponse.method ?? '');

          // Navigate to 2FA screen
          Get.toNamed(RouteName.loginAuthenticator);
          return;
        } else {
          errorMessage.value =
              twofaLoginResponse.message ?? 'Authentication failed';
          // Utils.snackBar(errorMessage.value.tr, 'Error');
        }
      } catch (e) {
        errorMessage.value = '$e';
        // Utils.snackBar(errorMessage.value.tr, 'Error');
        // log('2FA Check Error: $e');
      }

      errorMessage.value = 'Authentication failed. Please try again.';
      // Utils.snackBar(errorMessage.value.tr, 'Error');
    } finally {
      isLoading.value = false;
    }
  }

//*********************************here for google login ************************ */

  Future<Map<String, dynamic>?> verifyGoogleToken(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiUrls.baseUrl}/connect/v1/api/auth/verify"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "idToken": idToken,
        }),
      );

      // log("Verify response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return jsonDecode(response.body);
      }
    } catch (e) {
      log("Error verifying Google token: $e");
      return null;
    }
  }

  Future<void> handleSuccessfulLogin(LoginResponseModel loginResponse) async {
    await _userPreferencesViewmodel.saveUser(loginResponse);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userToken', loginResponse.token);

    // ✅ CREATE CONTROLLER HERE (AFTER TOKEN IS READY)
    final userProfileController =
        Get.put(UserProfileController(), permanent: true);

    // ✅ FORCE FETCH PROFILE ONCE
    await userProfileController.refreshApi();

    // Navigate
    final role = loginResponse.user.role;
    if (role == 'Creator') {
      Get.offAllNamed(RouteName.creatorBottomBar);
    } else {
      Get.offAllNamed(RouteName.bottomNavbar);
    }

    Get.delete<LoginController>();
  }

  @override
  void onClose() {
    emailController.value.dispose();
    passwordController.value.dispose();
    super.onClose();
  }
}
