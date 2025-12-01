import 'dart:async';
import 'package:connectapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links5/uni_links.dart';
import '../../../models/UserProfile/user_profile_model.dart';
import '../../../models/UserRegistration/user_registration_model.dart';
import '../../../repository/UserRegistration/user_registration_repository.dart';
import '../../../res/api_urls/api_urls.dart';
import '../../../res/routes/routes_name.dart';
import '../userName/user_name_controller.dart';
import '../userPreferences/user_preferences_screen.dart';

class SignupController extends GetxController {
  final nameController = TextEditingController().obs;
  final emailController = TextEditingController().obs;
  final passwordController = TextEditingController().obs;
  final referralCodeController = TextEditingController().obs;
  var confirmPasswordController = TextEditingController().obs;
  RxString tempName = "".obs;
  RxString tempEmail = "".obs;
  RxString tempUsername = "".obs;
  RxBool isLoading = false.obs;
  var errorMessage = ''.obs;

  final UserRegistrationRepository _userRegistrationRepository =
      UserRegistrationRepository();
  final UserPreferencesViewmodel _userPreferencesViewmodel =
      UserPreferencesViewmodel();

  @override
  void onInit() {
    super.onInit();
    initDeepLinks();
    _loadReferralCode();
  }

  // Load referral code from SharedPreferences
  Future<void> _loadReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    final storedRefCode = prefs.getString('referralCode');
    if (storedRefCode != null) {
      referralCodeController.value.text = storedRefCode;
    }
  }

  // Save referral code to SharedPreferences
  Future<void> saveReferralCode(String refCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('referralCode', refCode);
    referralCodeController.value.text = refCode;
  }

  // Fetch referral code from stored profile or API
  Future<String> fetchReferralCode() async {
    try {
      // Try to get from stored profile
      final profile = await _userPreferencesViewmodel.getUserProfile();
      if (profile != null) {
        final referralCode = profile.referrals!.referralCode;
        if (referralCode != null && referralCode.isNotEmpty) {
          // log('Referral code from profile: $referralCode');
          return referralCode;
        } else if (profile.fullName!.isNotEmpty) {
          final fallbackCode =
              profile.fullName!.replaceAll(' ', '').toLowerCase();
          // log('Using fallback referral code: $fallbackCode');
          return fallbackCode;
        }
      }

      // Fallback: Fetch profile from API
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken') ?? '';
      if (token.isEmpty) {
        throw Exception('User not logged in');
      }

      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}/connect/v1/api/user/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      // log('Profile API Response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final userProfile = UserProfileModel.fromJson(jsonResponse);
        await _userPreferencesViewmodel.saveUserProfile(userProfile);
        final referralCode = userProfile.referrals!.referralCode;
        if (referralCode != null && referralCode.isNotEmpty) {
          return referralCode;
        } else if (userProfile.fullName!.isNotEmpty) {
          final fallbackCode =
              userProfile.fullName!.replaceAll(' ', '').toLowerCase();
          return fallbackCode;
        }
      }
      throw Exception('Unable to fetch referral code');
    } catch (e) {
      // log('Fetch Referral Code Error: $e');
      throw Exception('Failed to fetch referral code: $e');
    }
  }

  // Share referral link
  Future<void> shareReferralLink() async {
    try {
      final referralCode = await fetchReferralCode();
      final link =
          'https://connect-frontend-1ogx.onrender.com/app/register?ref=$referralCode';
      // 'https://play.google.com/store/apps/details?id=app.connectapp.com&pcampaignid=web_share$referralCode';

      // log('Sharing link: $link');
      await Share.share(
        'Join my app using my referral link: $link',
        subject: 'Invite to Join',
      );
    } catch (e) {
      Utils.snackBar('Failed to share referral link: $e', 'Error');
    }
  }

  // Handle deep links
  StreamSubscription? _sub;

  void initDeepLinks() {
    _sub = uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null &&
            uri.host == ApiUrls.baseUrl &&
            uri.path == '/app/register') {
          final refCode = uri.queryParameters['ref'];
          if (refCode != null) {
            saveReferralCode(refCode);
            Get.toNamed(RouteName.signupScreen);
          }
        }
      },
    );

    // Handle initial link
    getInitialUri().then((uri) {
      if (uri != null &&
          uri.host == 'connect-frontend-1ogx.onrender.com' &&
          uri.path == '/app/register') {
        final refCode = uri.queryParameters['ref'];
        if (refCode != null) {
          saveReferralCode(refCode);
          Get.toNamed(RouteName.signupScreen);
        }
      }
    });
  }

  Future<void> registerUser(signupData) async {
    try {
      final usernameController = Get.find<UserNameController>();
      if (usernameController.isUsernameAvailable.value != true) {
        Utils.snackBar('Please select a valid username', 'Error');
        return;
      }

      isLoading.value = true;
      errorMessage.value = '';

      final registerRequest = RegisterRequestModel(
        username: usernameController.username.value.trim(),
        fullName: nameController.value.text.trim(),
        email: emailController.value.text.trim(),
        password: passwordController.value.text.trim(),
        referralCode: referralCodeController.value.text.trim().isEmpty
            ? null
            : referralCodeController.value.text.trim(),
      );

      final response = await _userRegistrationRepository
          .registerRequestModel(registerRequest.toJson());

      final registerResponse = RegisterResponseModel.fromJson(response);

      if (registerResponse.message == 'User registered successfully') {
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userToken', registerResponse.token);

        // Fetch and save profile
        final profileResponse = await http.get(
          Uri.parse('${ApiUrls.baseUrl}/connect/v1/api/user/profile'),
          headers: {'Authorization': 'Bearer ${registerResponse.token}'},
        );
        // log('Profile API Response: ${profileResponse.statusCode} ${profileResponse.body}');
        if (profileResponse.statusCode == 200) {
          final jsonResponse = jsonDecode(profileResponse.body);
          final userProfile = UserProfileModel.fromJson(jsonResponse);
          await _userPreferencesViewmodel.saveUserProfile(userProfile);
        } else {
          // log('Failed to fetch profile: ${profileResponse.statusCode}');
          Utils.snackBar(
            'Registered, but failed to fetch profile data',
            'Warning',
          );
        }

        Utils.snackBar(
          registerResponse.message.tr,
          'Success',
        );

        // log('Token: ${registerResponse.token}');

        // Clear incoming referral code after registration
        await prefs.remove('referralCode');
        referralCodeController.value.clear();

        Get.offNamed(RouteName.loginScreen);
      } else {
        errorMessage.value = registerResponse.message;
        Utils.snackBar(
          errorMessage.value.tr,
          'Error',
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Utils.snackBar(
        errorMessage.value.tr,
        'Error',
      );
      // log('Registration Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.value.dispose();
    emailController.value.dispose();
    passwordController.value.dispose();
    referralCodeController.value.dispose();
    _sub?.cancel();
    super.onClose();
  }
}
