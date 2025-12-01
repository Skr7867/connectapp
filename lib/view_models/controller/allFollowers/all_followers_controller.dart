import 'dart:developer';

import 'package:get/get.dart';

import '../../../data/response/status.dart';
import '../../../models/AllFollowers/all_followers_model.dart';
import '../../../repository/AllFollowers/all_followers_repository.dart';
import '../userPreferences/user_preferences_screen.dart';

class AllFollowersController extends GetxController {
  final _api = AllFollowersRepository();
  final _prefs = UserPreferencesViewmodel();

  final rxRequestStatus = Status.LOADING.obs;
  final followers = <Followers>[].obs;
  final error = ''.obs;

  void setError(String value) => error.value = value;
  void setRxRequestStatus(Status value) => rxRequestStatus.value = value;
  void setFollowers(List<Followers> value) => followers.assignAll(value);

  @override
  void onInit() {
    super.onInit();
    fetchFollowers();
  }

  Future<void> fetchFollowers() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      // log("TOKEN: ${loginData.token}");

      final response = await _api.allFollowers(loginData.token);
      // log("API Response: ${response.followers?.map((follower) => follower.toJson()).toList()}");
      setRxRequestStatus(Status.COMPLETED);
      setFollowers(response.followers ?? []);
    } catch (error, stackTrace) {
      log("API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }

  Future<void> refreshFollowers() async {
    setRxRequestStatus(Status.LOADING);

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        setError("User not authenticated. Token not found.");
        setRxRequestStatus(Status.ERROR);
        return;
      }

      log("Refresh TOKEN: ${loginData.token}");

      final response = await _api.allFollowers(loginData.token);
      log("Refresh API Response: ${response.followers?.map((follower) => follower.toJson()).toList()}");
      setRxRequestStatus(Status.COMPLETED);
      setFollowers(response.followers ?? []);
    } catch (error, stackTrace) {
      log("Refresh API Error: $error", stackTrace: stackTrace);
      setError(error.toString());
      setRxRequestStatus(Status.ERROR);
    }
  }
}
