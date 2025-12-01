import 'dart:developer';
import 'package:get/get.dart';

import '../../../data/response/status.dart';
import '../../../models/UserSocialProfileModel/user_social_profile_model.dart';
import '../../../repository/UserSocialProfile/user_social_profile_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class UserSocialProfileController extends GetxController {
  final _api = UserSocialProfileRepository();
  final _prefs = UserPreferencesViewmodel();

  final rxRequestStatus = Status.LOADING.obs;
  final userProfile = Rxn<Profile>();
  final error = ''.obs;

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setUserProfile(Profile? value) => userProfile.value = value;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  /// Shared function to load profile
  Future<void> _loadUserProfile({bool isRefresh = false}) async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      final userId = Get.arguments ?? "";
      if (userId == null || userId.isEmpty) {
        setError("Invalid user ID.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      // log("${isRefresh ? "Refresh" : "Fetch"} TOKEN: ${loginData.token}, USER ID: $userId");

      final response = await _api.userSocialProfile(loginData.token, userId);
      // log("${isRefresh ? "Refresh" : "Fetch"} API Response Parsed: ${response.profile.toJson()}");

      setUserProfile(response.profile);
      setRxRequestStatus(Status.COMPLETED);
    } catch (err, stackTrace) {
      log("${isRefresh ? "Refresh" : "Fetch"} API Error: $err",
          stackTrace: stackTrace);
      setError(err.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }

  // First load
  Future<void> fetchUserProfile() async {
    await _loadUserProfile();
  }

  // Manual refresh
  Future<void> refreshUserProfile() async {
    await _loadUserProfile(isRefresh: true);
  }
}
