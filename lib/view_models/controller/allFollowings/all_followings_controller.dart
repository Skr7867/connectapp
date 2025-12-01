import 'dart:developer';

import 'package:get/get.dart';

import '../../../data/response/status.dart';
import '../../../models/AllFollowing/all_following_model.dart';
import '../../../repository/AllFollowing/all_following_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class AllFollowingsController extends GetxController {
  final _api = AllFollowingRepository();
  final _prefs = UserPreferencesViewmodel();

  final rxRequestStatus = Status.LOADING.obs;
  final followings = <Following>[].obs;
  final error = ''.obs;

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setFollowings(List<Following> value) => followings.assignAll(value);

  @override
  void onInit() {
    super.onInit();
    fetchFollowings();
  }

  Future<void> fetchFollowings() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      // log("TOKEN: ${loginData.token}");

      final response = await _api.allFollowing(loginData.token);
      // log("API Response: ${response.following?.map((following) => following.toJson()).toList()}");
      setRxRequestStatus(Status.COMPLETED);
      setFollowings(response.following ?? []);
    } catch (error, stackTrace) {
      log("API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }

  Future<void> refreshFollowings() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      log("Refresh TOKEN: ${loginData.token}");

      final response = await _api.allFollowing(loginData.token);
      log("Refresh API Response: ${response.following?.map((following) => following.toJson()).toList()}");
      setRxRequestStatus(Status.COMPLETED);
      setFollowings(response.following ?? []);
    } catch (error, stackTrace) {
      log("Refresh API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }
}
